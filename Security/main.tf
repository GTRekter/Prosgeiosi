terraform {
#   backend "azurerm" {}
}
provider "azurerm" {
  features {}
  subscription_id            = var.provider_settings.subscription_id
  tenant_id                  = var.provider_settings.tenant_id
  skip_provider_registration = true
}