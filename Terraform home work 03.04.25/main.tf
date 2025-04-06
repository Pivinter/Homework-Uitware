terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.25.0"
    }
  }
  # backend "azurerm" {
  #   resource_group_name  = "BeStrong-resource-group"
  #   storage_account_name = "tfstatebestrong324"
  #   container_name       = "tfstate"
  #   key                  = "terraform.tfstate"
  # }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.resource_group_location
}

resource "azurerm_storage_account" "terraform_state" {
  name                     = "tfstatebestrong324"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = var.account_tier_terraform_state
  account_replication_type = var.account_replication_type_terraform_state
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.terraform_state.id
  container_access_type = "private"
}

module "network" {
  source                             = "./modules/network"
  address_space_vnetwork             = var.address_space_vnetwork
  address_prefixes_subnet_appservice = var.address_prefixes_subnet_appservice
  address_prefixes_subnet_private    = var.address_prefixes_subnet_private
  resource_group_name                = var.resource_group_name
  resource_group_location            = var.resource_group_location
}

module "app_service" {
  source                        = "./modules/app_service"
  application_type_app_insights = var.application_type_app_insights
  os_type                       = var.os_type
  sku_name_asp                  = var.sku_name_asp
  resource_group_name           = var.resource_group_name
  resource_group_location       = var.resource_group_location
  storage_account_name          = module.Storage.storage_account_name
  subnet_id                     = module.network.subnet_id
  storage_account_key           = module.Storage.storage_account_key
  storage_share_name            = module.Storage.storage_share_name
}

module "container_registry" {
  source                  = "./modules/container_registry"
  sku_acr                 = var.sku_acr
  principal_id            = module.app_service.principal_id
  resource_group_name     = var.resource_group_name
  resource_group_location = var.resource_group_location
}

module "database" {
  source                  = "./modules/database"
  sku_name_sqldb          = var.sku_name_sqldb
  sql_admin_password      = var.sql_admin_password
  sql_admin_user          = var.sql_admin_user
  subnet_id_private       = module.network.subnet_id_private
  resource_group_name     = var.resource_group_name
  resource_group_location = var.resource_group_location
}

module "key_Vault" {
  source                  = "./modules/key_vault"
  tenant_id               = var.tenant_id
  sku_name_kv             = var.sku_name_kv
  subnet_id_private       = module.network.subnet_id_private
  resource_group_name     = var.resource_group_name
  resource_group_location = var.resource_group_location
  object_id               = module.app_service.principal_id
}

module "Storage" {
  source                                   = "./modules/storage"
  account_replication_type_terraform_state = var.account_replication_type_terraform_state
  account_tier_storage                     = var.account_tier_storage
  subnet_id_private                        = module.network.subnet_id_private
  resource_group_name                      = var.resource_group_name
  resource_group_location                  = var.resource_group_location
}
