variable "provider_settings" {
  type = object({
    subscription_id = string
    tenant_id       = string
  })
  description = "Provider settings"
}
variable "management_groups" {
  type = list(object({
    name              = string
    management_groups = list(object({
      name             = string
      subscription_ids = list(string)
      parent_name      = string
    }))
  }))
}