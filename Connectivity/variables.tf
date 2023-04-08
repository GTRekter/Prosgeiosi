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
variable "dns_zone" {
  type = object({
    name = string
    soa_record = object({
      email         = string
      host_name     = string
      expire_time   = number
      minimum_ttl   = number
      refresh_time  = number
      retry_time    = number
      serial_number = number
      ttl           = number
    })
  })
  description = "DNS zone settings"
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
variable "public_ip" {
  type = object({
    name              = string
    sku               = string
    allocation_method = string
  })
  description = "Public IP settings"
}
variable "express_route_circuit" {
  type = object({
    name                     = string
    allow_classic_operations = bool
    service_provider_name    = string
    peering_location         = string
    bandwidth_in_mbps        = number
    tier                     = string
    family                   = string
  })
  description = "Express Route Circuit settings"
}
variable "express_route_peering" {
  type = object({
    name                          = string
    peering_type                  = string
    peer_asn                      = number
    primary_peer_address_prefix   = string
    secondary_peer_address_prefix = string
    vlan_id                       = number
  })
  description = "Express Route Peering settings"
}
variable "virtual_network_gateway" {
  type = object({
    name                          = string
    type                          = string 
    vpn_type                      = string
    active_active                 = bool 
    enable_bgp                    = bool 
    sku                           = string 
    ip_configuration_name         = string 
    private_ip_address_allocation = string 
  })
  description = "Virtual Network Gateway settings"
}
variable "virtual_network_gateway_connection" {
  type = object({
    name = string
    type = string
  })
  description = "Virtual Network Gateway Connection settings"
}
variable "network_watcher" {
    type = object({
        name = string
    })
    description = "Network Watcher settings"
}
variable "role_assignments" {
  type = list(object({
    role_definition_name = string
    users                = list(string)
  }))
  description = "Role assignments"
}
variable "subscription_policy_assignments" {
  type = list(object({
    name         = string
    policy_name  = string
    parameters   = string
    description  = string
    display_name = string
  }))
  description = "Subscritpion policy assignments"
}
variable "defender_for_cloud" {
  type = object({
    subscription_pricings = list(object({
      tier          = string
      resource_type = string
    }))
    settings = map(string)
    contact = object({
      name                = string
      email               = string
      phone               = string
      alert_notifications = bool
      alerts_to_admins    = bool
    })
    auto_provision = string
  })
}