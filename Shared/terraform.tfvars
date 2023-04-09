provider_settings = {
    subscription_id = "36e90881-8db4-4f13-aa7a-8e9d83febdf4"
    tenant_id       = "00434baa-68ec-4d73-b0a2-fec5bac28891"
}
management_groups = [
    {
        name = "Root"
        management_groups = [
            {
                name = "Origin Technologies"
                subscription_ids = []
                parent_name = null
            }
        ]
    },
    {
        name = "First level"
        management_groups = [
            {
                name = "Platform"
                subscription_ids = []
                parent_name = "Origin Technologies"
            },
            {
                name = "Landing zones"
                subscription_ids = []
                parent_name = "Origin Technologies"
            },
            {
                name = "Decommissioned"
                subscription_ids = []
                parent_name = "Origin Technologies"
            },
            {
                name = "Sandbox"
                subscription_ids = []
                parent_name = "Origin Technologies"
            }
        ]
    },
    {
        name = "Landing zones"
        management_groups = [
            {
                name = "Management"
                subscription_ids = []
                parent_name = "Platform"
            },
            {
                name = "Identity"
                subscription_ids = []
                parent_name = "Platform"
            },
            {
                name = "Connectivity"
                subscription_ids = []
                parent_name = "Platform"
            },
            {
                name = "SAP"
                subscription_ids = []
                parent_name = "Landing zones"
            },
            {
                name = "Corporation"
                subscription_ids = []
                parent_name = "Landing zones"
            },
            {
                name = "Online"
                subscription_ids = []
                parent_name = "Landing zones"
            }
        ]
    }
]