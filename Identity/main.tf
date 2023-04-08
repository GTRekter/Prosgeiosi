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


resource "azurerm_linux_virtual_machine" "virtual_machine" {
    for_each = { for virtual_machine in var.virtual_machines : virtual_machine.name => virtual_machine if virtual_machine.os_type == "Linux" }
    admin_password                  = each.value.disable_password_authentication == false ? each.value.admin_password : null
    admin_username                  = each.value.admin_username
    allow_extension_operations      = try(each.value.allow_extension_operations, null)
    availability_set_id             = can(each.value.availability_set_key) || can(each.value.availability_set.key) ? var.availability_sets[try(var.client_config.landingzone_key, each.value.availability_set.lz_key)][try(each.value.availability_set_key, each.value.availability_set.key)].id : try(each.value.availability_set.id, each.value.availability_set_id, null)
    computer_name                   = azurecaf_name.linux_computer_name[each.key].result
    disable_password_authentication = try(each.value.disable_password_authentication, true)
    encryption_at_host_enabled      = try(each.value.encryption_at_host_enabled, null)
    eviction_policy                 = try(each.value.eviction_policy, null)
    license_type                    = try(each.value.license_type, null)
    location                        = local.location
    max_bid_price                   = try(each.value.max_bid_price, null)
    name                            = azurecaf_name.linux[each.key].result
    network_interface_ids           = local.nic_ids
    priority                        = try(each.value.priority, null)
    provision_vm_agent              = try(each.value.provision_vm_agent, true)
    proximity_placement_group_id    = can(each.value.proximity_placement_group_key) || can(each.value.proximity_placement_group.key) ? var.proximity_placement_groups[try(var.client_config.landingzone_key, var.client_config.landingzone_key)][try(each.value.proximity_placement_group_key, each.value.proximity_placement_group.key)].id : try(each.value.proximity_placement_group_id, each.value.proximity_placement_group.id, null)
    resource_group_name             = local.resource_group_name
    size                            = each.value.size
    tags                            = merge(local.tags, try(each.value.tags, null))
    zone                            = try(each.value.zone, null)
    # dynamic "admin_ssh_key" {
    #     for_each = lookup(each.value, "disable_password_authentication", true) == true && local.create_sshkeys ? [1] : []
    #     content {
    #         username   = each.value.admin_username
    #         public_key = local.create_sshkeys ? tls_private_key.ssh[each.key].public_key_openssh : file(var.settings.public_key_pem_file)
    #     }
    # }
    # dynamic "admin_ssh_key" {
    #     for_each = { for key, value in try(each.value.admin_ssh_keys, {}) : key => value if can(value.ssh_public_key_id) }
    #     content {
    #         username   = each.value.admin_username
    #         public_key = replace(data.external.ssh_public_key_id[admin_ssh_key.key].result.public_ssh_key, "\r\n", "")
    #     }
    # }
    # dynamic "admin_ssh_key" {
    #     for_each = { for key, value in try(each.value.admin_ssh_keys, {}) : key => value if can(value.secret_key_id) }
    #     content {
    #         username   = each.value.admin_username
    #         public_key = replace(data.external.secret_key_id[admin_ssh_key.key].result.public_ssh_key, "\r\n", "")
    #     }
    # }
    # dynamic "admin_ssh_key" {
    #     for_each = { for key, value in try(var.settings.virtual_machine_settings[var.settings.os_type].admin_ssh_keys, {}) : key => value if can(value.keyvault_key) }
    #     content {
    #         username   = each.value.admin_username
    #         public_key = replace(data.external.ssh_secret_keyvault[admin_ssh_key.key].result.public_ssh_key, "\r\n", "")
    #     }
    # }
    os_disk {
        caching                   = try(each.value.os_disk.caching, null)
        disk_size_gb              = try(each.value.os_disk.disk_size_gb, null)
        name                      = try(azurecaf_name.os_disk_linux[each.key].result, null)
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