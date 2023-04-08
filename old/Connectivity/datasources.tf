data "azuread_user" "ad_users" {
    for_each = { for user in distinct(flatten([for role_assignment in var.role_assignments : role_assignment.users])) : user => user }
    user_principal_name = each.key
}
data "azurerm_policy_definition" "policy_definitions" {
    for_each = { for subscription_policy_assignment in var.subscription_policy_assignments : subscription_policy_assignment.policy_name => subscription_policy_assignment }
    name     = each.key
}