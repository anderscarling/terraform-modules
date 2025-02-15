/**
  * # Governance (Deprecated)
  *
  * DEPRECATED: Use `governance-global` and `governance-regional` instead.
  *
  * This module is used to create resource groups, service principals, Azure AD groups, Azure KeyVaults and delegation to all of those resources.
  */

terraform {
  required_version = "0.15.3"

  required_providers {
    azurerm = {
      version = "2.72.0"
      source  = "hashicorp/azurerm"
    }
    azuread = {
      version = "1.6.0"
      source  = "hashicorp/azuread"
    }
    random = {
      version = "3.1.0"
      source  = "hashicorp/random"
    }
    pal = {
      version = "0.2.4"
      source  = "xenitab/pal"
    }
  }
}

data "azurerm_subscription" "current" {}
data "azurerm_client_config" "current" {}
