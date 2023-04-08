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