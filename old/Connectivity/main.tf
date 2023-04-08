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
resource "azurerm_dns_zone" "dns_zone" {
    name                = var.dns_zone.name
    resource_group_name = azurerm_resource_group.resource_group.name
    dynamic "soa_record" {
        for_each = var.dns_zone.soa_record != null ? [1] : []
        content {
            email         = var.dns_zone.soa_record.email
            host_name     = var.dns_zone.soa_record.host_name
            expire_time   = var.dns_zone.soa_record.expire_time
            minimum_ttl   = var.dns_zone.soa_record.minimum_ttl
            refresh_time  = var.dns_zone.soa_record.refresh_time
            retry_time    = var.dns_zone.soa_record.retry_time
            serial_number = var.dns_zone.soa_record.serial_number
            ttl           = var.dns_zone.soa_record.ttl
            tags          = local.tags
        }
    }
    tags = local.tags
}
resource "azurerm_network_ddos_protection_plan" "ddos" {
    count               = var.virtual_network.is_ddos_enabled ? 1 : 0
    name                = format("%s-%s", var.virtual_network.name, "ddos")
    resource_group_name = azurerm_resource_group.resource_group.name
    location            = azurerm_resource_group.resource_group.location
}
resource "azurerm_virtual_network" "virtual_network" {
    name                = var.virtual_network.name
    resource_group_name = azurerm_resource_group.resource_group.name
    location            = azurerm_resource_group.resource_group.location
    address_space       = var.virtual_network.address_space
    dns_servers         = var.virtual_network.dns_servers
    tags                = local.tags
    dynamic "ddos_protection_plan" {
        for_each = var.virtual_network.is_ddos_enabled ? [{}] : []
        content {
            id     = azurerm_network_ddos_protection_plan.ddos[0].id
            enable = true
        }
    }
}
resource azurerm_subnet "subnet" {
    name                                           = var.subnet.name
    resource_group_name                            = azurerm_resource_group.resource_group.name
    virtual_network_name                           = azurerm_virtual_network.virtual_network.name
    address_prefixes                               = var.subnet.address_prefixes
    private_endpoint_network_policies_enabled      = var.subnet.private_endpoint_network_policies_enabled
}
resource azurerm_public_ip "public_ip" {
    name                = var.public_ip.name
    resource_group_name = azurerm_resource_group.resource_group.name
    location            = azurerm_resource_group.resource_group.location
    sku                 = var.public_ip.sku
    allocation_method   = var.public_ip.allocation_method
}
resource "azurerm_express_route_circuit" "express_route_circuit" {
    name                     = var.express_route_circuit.name
    resource_group_name      = azurerm_resource_group.resource_group.name
    location                 = azurerm_resource_group.resource_group.location
    allow_classic_operations = var.express_route_circuit.allow_classic_operations

    # The service_provider_name, the peering_location and the bandwidth_in_mbps should be 
    # set together and they conflict with express_route_port_id and bandwidth_in_gbps.
    # express_route_port_id = var.express_route_port_id
    # bandwidth_in_gbps     = 50
    service_provider_name = var.express_route_circuit.service_provider_name
    peering_location      = var.express_route_circuit.peering_location
    bandwidth_in_mbps     = var.express_route_circuit.bandwidth_in_mbps
    sku {
        tier   = var.express_route_circuit.tier # Basic, Local, Standard or Premium
        family = var.express_route_circuit.family # MeteredData or UnlimitedData
    }
    tags          = local.tags
}
resource azurerm_express_route_circuit_peering "express_route_peering" {
    resource_group_name           = azurerm_resource_group.resource_group.name
    express_route_circuit_name    = azurerm_express_route_circuit.express_route_circuit.name
    peering_type                  = var.express_route_peering.peering_type
    primary_peer_address_prefix   = var.express_route_peering.primary_peer_address_prefix
    secondary_peer_address_prefix = var.express_route_peering.secondary_peer_address_prefix
    vlan_id                       = var.express_route_peering.vlan_id
}
resource "azurerm_virtual_network_gateway" "virtual_network_gateway" {
    name                = var.virtual_network_gateway.name
    resource_group_name = azurerm_resource_group.resource_group.name
    location            = azurerm_resource_group.resource_group.location
    type                = var.virtual_network_gateway.type
    vpn_type            = var.virtual_network_gateway.vpn_type
    active_active       = var.virtual_network_gateway.active_active
    enable_bgp          = var.virtual_network_gateway.enable_bgp
    sku                 = var.virtual_network_gateway.sku
    ip_configuration {
        name                          = var.virtual_network_gateway.ip_configuration_name
        private_ip_address_allocation = var.virtual_network_gateway.private_ip_address_allocation
        subnet_id                     = azurerm_subnet.subnet.id
        public_ip_address_id          = azurerm_public_ip.public_ip.id
    }
}
resource azurerm_virtual_network_gateway_connection "virtual_network_gateway_connection" {
    name                       = var.virtual_network_gateway_connection.name
    resource_group_name        = azurerm_resource_group.resource_group.name
    location                   = azurerm_resource_group.resource_group.location
    type                       = var.virtual_network_gateway_connection.type
    virtual_network_gateway_id = azurerm_virtual_network_gateway.virtual_network_gateway.id
    express_route_circuit_id   = azurerm_express_route_circuit.express_route_circuit.id
}
# https://build5nines.com/terraform-deploy-azure-expressroute-circuit-with-vnet-gateway/
resource "azurerm_network_watcher" "network_watcher" {
  name                = var.network_watcher.name
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
}
resource "azurerm_role_assignment" "role_assignments" {
    for_each             = { for idx, r in flatten([for role_assignment in var.role_assignments : [for user in role_assignment.users : { role = role_assignment.role_definition_name, user = user }]]) : idx => r }
    scope                = azurerm_resource_group.resource_group.id  
    role_definition_name = each.value.role
    principal_id         = data.azuread_user.ad_users[each.value.user].id 
}
resource "azurerm_subscription_policy_assignment" "subscription_policy_assignments" {
    for_each             = { for subscription_policy_assignment in var.subscription_policy_assignments : subscription_policy_assignment.policy_name => subscription_policy_assignment }
    name                 = each.value.name
    display_name         = each.value.display_name
    subscription_id      = "/subscriptions/${var.provider_settings.subscription_id}"
    policy_definition_id = data.azurerm_policy_definition.policy_definitions[each.key].id
    parameters           = each.value.parameters
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