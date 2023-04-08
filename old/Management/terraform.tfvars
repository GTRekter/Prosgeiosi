provider_settings = {
    subscription_id = "36e90881-8db4-4f13-aa7a-8e9d83febdf4"
    tenant_id       = "00434baa-68ec-4d73-b0a2-fec5bac28891"
}
resource_group = {
    name = "rg-lz-mn-uks-01"
    location = "uksouth"
}
dashboards = [
    {
        name          = "default"
        json_filename = "default"
        variables     = {}
    }
]
automation_account = {
    name     = "automation-account"
    sku_name = "Basic"
    software_update_configurations = [
        {
            name                    = "linux-software-update-configuration"
            operating_system        = "Linux" # Windows and Linux.
            duration                = "PT2H2M2S" # PT[n]H[n]M[n]S
            classification_included = "Security" # Unclassified, Critical, Security and Other.
            excluded_packages       = []
            included_packages       = ["apt"]
            reboot                  = "IfRequired" # IfRequired, Never and Always
        },
        {
            name                     = "windows-software-update-configuration"
            operating_system         = "Windows" # Windows and Linux.
            duration                 = "PT2H2M2S" # PT[n]H[n]M[n]S
            classifications_included = ["Security", "Updates"] # Unclassified, Critical, Security, UpdateRollup, FeaturePack, ServicePack, Definition, Tools and Updates.
            excluded_packages        = []
            included_packages        = []
            reboot                   = "IfRequired" # IfRequired, Never and Always
        }
    ]
    schedule = {
        name                = "automation-schedule"
        description         = "This is an example schedule"
        frequency           = "OneTime"
        start_time          = "2023-01-01T00:00:00Z"
        interval            = 1
        week_days           = ["Monday", "Friday"]
        month_days          = [1, 4]
        monthly_occurrences = [
            {
                day        = "Monday"
                occurrence = 1
            },
            {
                day        = "Tuesday"
                occurrence = 2
            }
        ]
    }
    source_control = {
        name                = "automation-source-control"
        description         = " This is an example source control"
        branch              = "master"
        repository_url      = "https://github.com/GTRekter/Prosgeiosi.git"
        source_control_type = "GitHub" # VsoGit, VsoTfvc and GitHub
        folder_path         = "folder"
        token_type          = "PersonalAccessToken" # PersonalAccessToken and Oauth.
        token               = "ghp_xxx" # TODO: this is going to be read from the environment varibales. Definetly not hard coded.
    }
    dsc_configurations = [
        {
            name                      = "dsc_configuration"
            content_embedded_filename = "default"
        }
    ]
}
log_analytics_workspace = {
    name                = "log-analytics-workspace"
    sku                 = "Free" # Free, PerNode, Premium, Standard, Standalone, Unlimited, CapacityReservation, and PerGB2018. Defaults to PerGB2018.
    retention_in_days   = 30 # range between 30 and 730
}