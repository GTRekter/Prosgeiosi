terraform {
#   backend "azurerm" {}
}
provider "azurerm" {
    features {}
    subscription_id            = var.provider_settings.subscription_id
    tenant_id                  = var.provider_settings.tenant_id
    skip_provider_registration = true
}
resource "azurerm_resource_group" "resource_group" {
    name     = var.resource_group.name
    location = var.resource_group.location
}
resource "azurerm_portal_dashboard" "portal_dashboard" {
    for_each             = { for dashboard in var.dashboards : dashboard.name => dashboard }
    name                 = each.key
    resource_group_name  = azurerm_resource_group.resource_group.name
    location             = azurerm_resource_group.resource_group.location
    dashboard_properties = templatefile("./dashboards/${each.value.json_filename}.json", each.value.variables)
    tags                 = local.tags
}
resource "azurerm_automation_account" "automation_account" {
    name                = var.automation_account.name
    resource_group_name = azurerm_resource_group.resource_group.name
    location            = azurerm_resource_group.resource_group.location
    sku_name            = var.automation_account.sku_name
    tags                = local.tags
}
resource "azurerm_automation_software_update_configuration" "automation_software_update_configurations" {
    for_each              = { for software_update_configuration in var.automation_account.software_update_configurations : software_update_configuration.name => software_update_configuration }
    name                  = each.key
    automation_account_id = azurerm_automation_account.automation_account.id
    operating_system      = each.value.operating_system
    duration              = each.value.duration
    dynamic "linux" {
        for_each = each.value.operating_system == "linux" ? [1] : []    
        content {
            classification_included  = each.value.classification_included
            excluded_packages        = try(each.value.excluded_packages, null)
            included_packages        = try(each.value.included_packages, null)
            reboot                   = each.value.reboot        
        }
    }
    dynamic "windows" {
        for_each = each.value.operating_system == "windows" ? [1] : []
        content {
            classifications_included        = each.value.classifications_included
            excluded_knowledge_base_numbers = try(each.value.excluded_knowledge_base_numbers, null)
            included_knowledge_base_numbers = try(each.value.included_knowledge_base_numbers, null)
            reboot                          = each.value.reboot
        }
    }
}
resource "azurerm_automation_schedule" "automation_schedule" {
    name                    = var.automation_account.schedule.name
    resource_group_name     = azurerm_resource_group.resource_group.name
    automation_account_name = azurerm_automation_account.automation_account.name
    frequency               = var.automation_account.schedule.frequency
    interval                = var.automation_account.schedule.frequency != "OneTime" ? try(var.automation_account.schedule.interval, null) : null
    timezone                = try(var.automation_account.schedule.timezone, null)
    start_time              = try(var.automation_account.schedule.start_time, null)
    description             = try(var.automation_account.schedule.description, null)
    week_days               = var.automation_account.schedule.frequency == "Week" ? try(var.automation_account.schedule.week_days, null) : null
    month_days              = var.automation_account.schedule.frequency == "Month" ? try(var.automation_account.schedule.month_days, null) : null
    # dynamic "monthly_occurrence" {
    #     for_each = try(var.automation_account.schedule.monthly_occurrences, null) == null && var.automation_account.schedule.frequency == "Month" ? [] : [1]
    #     content {
    #         day        = monthly_occurrence.day
    #         occurrence = monthly_occurrence.occurrence
    #     }
    # }
}
resource "azurerm_automation_source_control" "automation_source_control" {
    name                  = var.automation_account.source_control.name
    automation_account_id = azurerm_automation_account.automation_account.id
    folder_path           = var.automation_account.source_control.folder_path
    repository_url        = var.automation_account.source_control.repository_url
    source_control_type   = var.automation_account.source_control.source_control_type
    branch                = var.automation_account.source_control.branch
    description           = var.automation_account.source_control.description
    security {
        token      = var.automation_account.source_control.token
        token_type = var.automation_account.source_control.token_type
    }
}
resource "azurerm_automation_dsc_configuration" "automation_dsc_configurations" {
    for_each                = { for dsc_configuration in var.automation_account.dsc_configurations : dsc_configuration.name => dsc_configuration }
    name                    = each.key
    resource_group_name     = azurerm_resource_group.resource_group.name
    location                = azurerm_resource_group.resource_group.location
    automation_account_name = azurerm_automation_account.automation_account.name
    content_embedded        = filebase64("./dsc_configurations/${each.value.content_embedded_filename}.ps1")
}
resource "azurerm_log_analytics_workspace" "log_analytics_workspace" {
    name                = var.log_analytics_workspace.name
    resource_group_name = azurerm_resource_group.resource_group.name
    location            = azurerm_resource_group.resource_group.location
    sku                 = var.log_analytics_workspace.sku
    retention_in_days   = var.log_analytics_workspace.retention_in_days
}
# ======================================================================== 
# Defender for Cloud
# ======================================================================== 
resource "azurerm_security_center_setting" "security_center_setting_mcas" {
  setting_name = "MCAS"
  enabled      = var.defender_for_cloud.settings.mcas
}
resource "azurerm_security_center_setting" "security_center_setting_wdatp" {
  setting_name = "WDATP"
  enabled      = var.defender_for_cloud.settings.wdatp
}
resource "azurerm_security_center_setting" "security_center_setting_sentinel" {
  setting_name = "SENTINEL"
  enabled      = var.defender_for_cloud.settings.sentinel
}
resource "azurerm_security_center_contact" "security_center_contact" {
  name                = var.defender_for_cloud.contact.name
  email               = var.defender_for_cloud.contact.email
  phone               = var.defender_for_cloud.contact.phone
  alert_notifications = var.defender_for_cloud.contact.alert_notifications
  alerts_to_admins    = var.defender_for_cloud.contact.alerts_to_admins
}
resource "azurerm_security_center_auto_provisioning" "security_center_auto_provisioning" {
  auto_provision = var.defender_for_cloud.auto_provision
}
resource "azurerm_security_center_subscription_pricing" "security_center_subscription_pricings" {
  for_each      = { for security_center_subscription_pricing in var.defender_for_cloud.subscription_pricings : security_center_subscription_pricing.resource_type => security_center_subscription_pricing }
  tier          = each.value.tier
  resource_type = each.key
}

# To double check if they are neccessary
# resource "azurerm_advanced_threat_protection" "example" {
#   target_resource_id = azurerm_storage_account.example.id # The ID of the Azure Resource which to enable Advanced Threat Protection on.
#   enabled            = true
# }
# resource "azurerm_security_center_server_vulnerability_assessment" "example" {
#   virtual_machine_id = azurerm_linux_virtual_machine.example.id # The ID of the virtual machine to be monitored by vulnerability assessment.
# }
# resource "azurerm_security_center_server_vulnerability_assessment_virtual_machine" "example" {
#   virtual_machine_id = azurerm_linux_virtual_machine.example.id # The ID of the virtual machine to be monitored by vulnerability assessment.
# }
# resource "azurerm_security_center_auto_provisioning" "security_center_auto_provisioning" {
#   auto_provision = var.defender_for_cloud.auto_provision # Should the security agent be automatically provisioned on Virtual Machines in this subscription
# }

# resource "azurerm_security_center_assessment_policy" "example" {
#   display_name = "Test Display Name"
#   severity     = "Medium"
#   description  = "Test Description"
# }
# resource "azurerm_security_center_assessment" "example" {
#   assessment_policy_id = azurerm_security_center_assessment_policy.example.id # The ID of the security Assessment policy to apply to this resource.
#   target_resource_id   = azurerm_linux_virtual_machine_scale_set.example.id # The ID of the target resource.
#   status {
#     code = "Healthy" # Healthy, Unhealthy and NotApplicable.
#   }
# }