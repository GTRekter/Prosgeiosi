variable "provider_settings" {
  type = object({
    subscription_id = string
    tenant_id       = string
  })
  description = "Provider settings"
}