provider_settings = {
    subscription_id = "36e90881-8db4-4f13-aa7a-8e9d83febdf4"
    tenant_id       = "00434baa-68ec-4d73-b0a2-fec5bac28891"
}
resource_group = {
    name = "rg-lz-cn-uks-01"
    location = "uksouth"
}
dns_zone = {
    name =  "lz-cn-uks-01.com"
    soa_record = null
    # soa_record = {
    #     email         = "hostmaster.lz-cn-uks-01.com"
    #     expire_time   = 0
    #     minimum_ttl   = 0
    #     host_name     =
    #     refresh_time  = 0
    #     retry_time    = 0
    #     serial_number = 0
    #     ttl           = 0
    # }
}
virtual_network = {
    name            = "vnet-lz-cn-uks-01"
    address_space   = ["172.16.0.0/12"]
    dns_servers     = null
    is_ddos_enabled = true
}
subnet = {
    name                                           = "GatewaySubnet"
    address_prefixes                               = ["172.16.0.0/24"]
    private_endpoint_network_policies_enabled      = true
}
public_ip = {
    name                = "pip-lz-cn-uks-01"
    sku                 = "Basic"
    allocation_method   = "Dynamic"
}
express_route_circuit = {
    name                     = "er-lz-cn-uks-01"   
    allow_classic_operations = false
    # express_route_port_id 
    # bandwidth_in_gbps     
    service_provider_name    = "Equinix" 
    peering_location         = "Silicon Valley"     
    bandwidth_in_mbps        = 10000
    tier                     = "Standard"
    family                   = "MeteredData"
}
express_route_peering = {
    name                          = "erpeer-lz-cn-uks-01"
    peering_type                  = "AzurePrivatePeering"
    peer_asn                      = 100
    primary_peer_address_prefix   = "10.0.0.0/30"
    secondary_peer_address_prefix = "10.0.0.0/30"
    vlan_id                       = 100
}
virtual_network_gateway =  {
    name                          = "vnetgw-lz-cn-uks-01"
    type                          = "ExpressRoute"
    vpn_type                      = "PolicyBased"
    active_active                 = false
    enable_bgp                    = false
    sku                           = "HighPerformance"
    ip_configuration_name         = "IPConfiguration"
    private_ip_address_allocation = "Dynamic"
}
virtual_network_gateway_connection = {
    name = "vnetgwconn-lz-cn-uks-01"
    type = "ExpressRoute"
}
network_watcher = {
    name = "nw-lz-cn-uks-01"
}
role_assignments = [
    {
        role_definition_name = "Contributor"
        users                = ["Sample@ivanportaweboutlook.onmicrosoft.com"]
    },
    {
        role_definition_name = "Reader"
        users                = ["Sample@ivanportaweboutlook.onmicrosoft.com"]
    }
]
subscription_policy_assignments = [
    {
        name         = "Audit virtual machines without disaster recovery configured"
        policy_name  = "0015ea4d-51ff-4ce3-8d8c-f3f8f0179a56"
        parameters   = null
        description  = "Audit virtual machines which do not have disaster recovery configured. To learn more about disaster recovery, visit https://aka.ms/asr-doc."
        display_name = "Audit virtual machines without disaster recovery configured"
    }
]
defender_for_cloud = {
    subscription_pricings = [
        {
            tier          = "Free" # Free or Standard
            resource_type = "AppServices" # AppServices, ContainerRegistry, KeyVaults, KubernetesService, SqlServers, SqlServerVirtualMachines, StorageAccounts, VirtualMachines, Arm, Dns, OpenSourceRelationalDatabases, Containers, CosmosDbs and CloudPosture. Defaults to VirtualMachines
        },
        {
            tier          = "Free"
            resource_type = "ContainerRegistry"
        },
        {
            tier          = "Free"
            resource_type = "KeyVaults"
        },
        {
            tier          = "Free"
            resource_type = "KubernetesService"
        },{
            tier          = "Free"
            resource_type = "SqlServers"
        },
        {
            tier          = "Free"
            resource_type = "SqlServerVirtualMachines"
        },
        {
            tier          = "Free"
            resource_type = "StorageAccounts"
        },
        {
            tier          = "Free"
            resource_type = "VirtualMachines"
        },
        {
            tier          = "Free"
            resource_type = "Arm"
        },
        {
            tier          = "Free"
            resource_type = "Dns"
        },
        {
            tier          = "Free"
            resource_type = "OpenSourceRelationalDatabases"
        },
        {
            tier          = "Free"
            resource_type = "Containers"
        },
        {
            tier          = "Free"
            resource_type = "CosmosDbs"
        },
        {
            tier          = "Free"
            resource_type = "CloudPosture"
        }
    ]
    settings = {
        mcas     = false
        wdatp    = false
        sentinel = false
    }
    contact = {
        name                = "Ivan Porta"
        email               = "porta.ivan@outlook.com"
        phone               = "123456789"
        alert_notifications = true
        alerts_to_admins    = true
    }
    auto_provision = "On"

}