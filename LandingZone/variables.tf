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
variable "virtual_network" {
  type = object({
    name                = string
    address_space       = list(string)
    dns_servers         = list(string)
    is_ddos_enabled     = bool
  })
  description = "Virtual network settings"
}
variable "subnet" {
  type = object({
    name                                           = string
    address_prefixes                               = list(string)
    private_endpoint_network_policies_enabled      = bool
  })
  description = "Subnet settings"
}