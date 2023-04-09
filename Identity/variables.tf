variable "provider_settings" {
  type = object({
    subscription_id = string
    tenant_id       = string
  })
  description = "Provider settings"
}
variable "resource_group" {
  type = object({
    name     = string
    location = string
  })
  description = "Resource group settings"
}
variable "key_vault" {
  type = object({
    name                            = string
    enabled_for_disk_encryption     = bool
    soft_delete_retention_days      = number
    purge_protection_enabled        = bool
    sku_name                        = string
    enabled_for_deployment          = bool
    enabled_for_template_deployment = bool
    public_network_access_enabled   = bool
    access_policies = list(object({
      object_id               = string
      key_permissions         = optional(list(string))
      certificate_permissions = optional(list(string))
      secret_permissions      = optional(list(string))
      storage_permissions     = optional(list(string))
    }))
  })
  description = "Key vault settings"
}




variable "virtual_machines" {
  type = map(object({
    name                           = string
    os_type                        = string
    admin_password                 = string
    admin_username                 = string
    disable_password_authentication = bool
    ssh_public_key_file            = string
    size                           = string
    os_disk = object({
      caching                  = string
      disk_size_gb             = number
      name                     = string
      storage_account_type     = string
      write_accelerator_enabled = bool
      disk_encryption_set_key   = string
    })
    diff_disk_settings = object({
      option = string
    })
    source_image_reference = object({
      publisher = string
      offer     = string
      sku       = string
      version   = string
    })
    custom_image_id       = string
    custom_image_version  = string
    identity = object({
      type = string
    })
    plan = object({
      name      = string
      product   = string
      publisher = string
    })
  }))
}