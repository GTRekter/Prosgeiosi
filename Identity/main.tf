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









https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/landing-zone/design-area/identity-access-active-directory-hybrid-identity
resource "azurerm_virtual_network" "virtual_network" {
  name                = "example-network"
  address_space       = ["10.0.0.0/16"]
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
}

resource "azurerm_subnet" "subnet" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
}
resource "azurerm_network_interface" "network_interface" {
  name                            = "example-nic"
  resource_group_name             = azurerm_resource_group.resource_group.name
  location                        = azurerm_resource_group.resource_group.location
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.example.id
    private_ip_address_allocation = "Dynamic"
  }
}
resource "azurerm_linux_virtual_machine" "virtual_machine" {
    for_each                        = { for virtual_machine in var.virtual_machines : virtual_machine.name => virtual_machine if virtual_machine.os_type == "Linux" }
    name                            = each.key 
    resource_group_name             = azurerm_resource_group.resource_group.name
    location                        = azurerm_resource_group.resource_group.location
    admin_password                  = each.value.disable_password_authentication == false ? each.value.admin_password : null
    admin_username                  = each.value.admin_username
    allow_extension_operations      = try(each.value.allow_extension_operations, null)
    disable_password_authentication = each.value.disable_password_authentication
    encryption_at_host_enabled      = try(each.value.encryption_at_host_enabled, null)
    eviction_policy                 = try(each.value.eviction_policy, null)
    license_type                    = try(each.value.license_type, null)
    max_bid_price                   = try(each.value.max_bid_price, null)
    network_interface_ids           = [azurerm_network_interface.network_interface.id]
    priority                        = try(each.value.priority, null)
    provision_vm_agent              = try(each.value.provision_vm_agent, true)
    size                            = each.value.size
    tags                            = merge(local.tags, try(each.value.tags, null))
    zone                            = try(each.value.zone, null)
    dynamic "admin_ssh_key" {
        for_each = each.value.disable_password_authentication && each.value.ssh_public_key_file != null ? [1] : []
        content {
            username   = each.value.admin_username
            public_key = file(var.ssh_public_key_file)
        }
    }
    os_disk {
        caching                   = try(each.value.os_disk.caching, null)
        disk_size_gb              = try(each.value.os_disk.disk_size_gb, null)
        name                      = try(each.value.os_disk.name, null)
        storage_account_type      = try(each.value.os_disk.storage_account_type, null)
        write_accelerator_enabled = try(each.value.os_disk.write_accelerator_enabled, false)
        disk_encryption_set_id    = try(each.value.os_disk.disk_encryption_set_key, null) == null ? null : try(var.disk_encryption_sets[var.client_config.landingzone_key][each.value.os_disk.disk_encryption_set_key].id, var.disk_encryption_sets[each.value.os_disk.lz_key][each.value.os_disk.disk_encryption_set_key].id, null)
        dynamic "diff_disk_settings" {
            for_each = try(each.value.diff_disk_settings, false) == false ? [] : [1]
            content {
                option = each.value.diff_disk_settings.option
            }
        }
    }
    dynamic "source_image_reference" {
        for_each = try(each.value.source_image_reference, null) != null ? [1] : []
        content {
            publisher = try(each.value.source_image_reference.publisher, null)
            offer     = try(each.value.source_image_reference.offer, null)
            sku       = try(each.value.source_image_reference.sku, null)
            version   = try(each.value.source_image_reference.version, null)
        }
    }
    source_image_id = try(each.value.source_image_reference, null) == null ? format("%s%s", try(each.value.custom_image_id, var.image_definitions[try(each.value.custom_image_lz_key, var.client_config.landingzone_key)][each.value.custom_image_key].id), try("/versions/${each.value.custom_image_version}", "")) : null
    dynamic "identity" {
        for_each = try(each.value.identity, false) == false ? [] : [1]
        content {
            type         = each.value.identity.type
            identity_ids = local.managed_identities
        }
    }
    dynamic "boot_diagnostics" {
        for_each = try(var.boot_diagnostics_storage_account != null ? [1] : var.global_settings.resource_defaults.virtual_machines.use_azmanaged_storage_for_boot_diagnostics == true ? [1] : [], [])
        content {
            storage_account_uri = var.boot_diagnostics_storage_account == "" ? null : var.boot_diagnostics_storage_account
        }
    }
    dynamic "plan" {
        for_each = try(each.value.plan, false) == false ? [] : [1]
        content {
            name      = each.value.plan.name
            product   = each.value.plan.product
            publisher = each.value.plan.publisher
        }
    }
}