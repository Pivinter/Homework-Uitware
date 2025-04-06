provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "BeStrong-resource-group"
  location = "westeurope"
}

resource "azurerm_storage_account" "tfstate" {
  name                     = "tfstate${random_string.suffix.result}"  # максимум 24 символи
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_id  = azurerm_storage_account.tfstate.id
  container_access_type = "private"
}

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}
