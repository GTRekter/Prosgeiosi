provider_settings = {
    subscription_id = "36e90881-8db4-4f13-aa7a-8e9d83febdf4"
    tenant_id       = "00434baa-68ec-4d73-b0a2-fec5bac28891"
}
resource_group = {
    name = "rg-lz-id-uks-01"
    location = "uksouth"
}
key_vault = {
    name                        = "kv-identity"
    enabled_for_disk_encryption = false
    soft_delete_retention_days  = 7
    purge_protection_enabled    = true
    sku_name                    = "standard" # standard and premium.
    

    enabled_for_deployment = true
    enabled_for_template_deployment = true
    public_network_access_enabled = true

    access_policies = [
        # {
        #     # he object ID of a user, service principal or security group in the Azure Active Directory tenant for the vault.
        #     key_permissions         = ["Get"] # Backup, Create, Decrypt, Delete, Encrypt, Get, Import, List, Purge, Recover, Restore, Sign, UnwrapKey, Update, Verify, WrapKey, Release, Rotate, GetRotationPolicy and SetRotationPolicy.
        #     certificate_permissions = ["Get"] # Backup, Create, Delete, DeleteIssuers, Get, GetIssuers, Import, List, ListIssuers, ManageContacts, ManageIssuers, Purge, Recover, Restore, SetIssuers and Update.
        #     secret_permissions      = ["Get"] # Backup, Delete, Get, List, Purge, Recover, Restore and Set.
        #     storage_permissions     = ["Get"] # ackup, Delete, DeleteSAS, Get, GetSAS, List, ListSAS, Purge, Recover, RegenerateKey, Restore, Set, SetSAS and Update.
        # }
    ]
}