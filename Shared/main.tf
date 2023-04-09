terraform {
#   backend "azurerm" {}
}
provider "azurerm" {
  features {}
  subscription_id            = var.provider_settings.subscription_id
  tenant_id                  = var.provider_settings.tenant_id
  skip_provider_registration = true
}
resource "azurerm_management_group" "root_management_group" {
  for_each         = { for management_group in var.management_groups[0].management_groups : management_group.name => management_group }
  display_name     = each.key
  subscription_ids = each.value.subscription_ids
}
resource "azurerm_management_group" "first_level_management_group" {
  for_each                   = { for management_group in var.management_groups[1].management_groups : management_group.name => management_group }
  display_name               = each.key
  parent_management_group_id = azurerm_management_group.root_management_group[each.value.parent_name].id
  subscription_ids           = each.value.subscription_ids
}
resource "azurerm_management_group" "second_level_management_group" {
  for_each                   = { for management_group in var.management_groups[2].management_groups : management_group.name => management_group }
  display_name               = each.key
  parent_management_group_id = azurerm_management_group.first_level_management_group[each.value.parent_name].id
  subscription_ids           = each.value.subscription_ids
}