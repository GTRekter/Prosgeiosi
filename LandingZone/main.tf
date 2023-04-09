terraform {
#   backend "azurerm" {}
}
provider "azurerm" {
  features {}
  subscription_id            = var.provider_settings.subscription_id
  tenant_id                  = var.provider_settings.tenant_id
  skip_provider_registration = true
}
resource "azurerm_network_security_group" "example" {
  name                = "acceptanceTestSecurityGroup1"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  security_rule {
    name                       = "test123"
    priority                   = 100
    direction                  = "Inbound" # Inbound and Outbound.
    access                     = "Allow" # Allow and Deny.
    protocol                   = "Tcp" # Possible values include Tcp, Udp, Icmp, Esp, Ah or * (which matches all).
    source_port_range          = "*" # between 0 and 65535 or *
    destination_port_range     = "*" # between 0 and 65535 or *
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
resource "azurerm_route_table" "route_table" {
  name                          = "example-route-table"
  location                      = azurerm_resource_group.example.location
  resource_group_name           = azurerm_resource_group.example.name
  disable_bgp_route_propagation = false
  route {
    name           = "route1"
    address_prefix = "10.1.0.0/16"
    next_hop_type  = "VnetLocal" # VirtualNetworkGateway, VnetLocal, Internet, VirtualAppliance and None.
  }
}
resource "azurerm_key_vault" "key_vault" {
    name                        = var.key_vault.name
    resource_group_name         = azurerm_resource_group.resource_group.name
    location                    = azurerm_resource_group.resource_group.location
    enabled_for_disk_encryption = var.key_vault.enabled_for_disk_encryption
    tenant_id                   = data.azurerm_client_config.current.tenant_id
    soft_delete_retention_days  = var.key_vault.soft_delete_retention_days
    purge_protection_enabled    = var.key_vault.purge_protection_enabled
    sku_name                    = var.key_vault.sku_name
    access_policy {    
        tenant_id               = data.azurerm_client_config.current.tenant_id
        object_id               = data.azurerm_client_config.current.object_id 
        key_permissions         = ["Get"]
        certificate_permissions = ["Get"]
        secret_permissions      = ["Get"]
        storage_permissions     = ["Get"]
    }
    dynamic "access_policy" {
        for_each = { for access_policy in var.key_vault.access_policies : access_policy.object_id => access_policy }
        content {
            tenant_id               = data.azurerm_client_config.current.tenant_id
            object_id               = access_policy.value.object_id
            key_permissions         = access_policy.value.key_permissions
            certificate_permissions = access_policy.value.certificate_permissions
            secret_permissions      = access_policy.value.secret_permissions
            storage_permissions     = access_policy.value.storage_permissions
        }
    }
}
resource "azurerm_recovery_services_vault" "recovery_services_vault" {
  name                = "example-recovery-vault"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  sku                 = "Standard" # Standard, RS0.
  public_network_access_enabled = true
  immutability = "Disabled"  # Locked, Unlocked and Disabled.
  storage_mode_type = "GeoRedundant" # GeoRedundant, LocallyRedundant and ZoneRedundant. Defaults to GeoRedundant.
  cross_region_restore_enabled = false
  soft_delete_enabled = true
}