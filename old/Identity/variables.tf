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