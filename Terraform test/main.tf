terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.25.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.resource_group_location
}

resource "random_string" "random_suffix" {
  length  = 6
  special = false
  upper   = false
}

# Virtual Network
resource "azurerm_virtual_network" "vnetwork" {
  name                = "vnetwork-${random_string.random_suffix.result}"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  address_space       = ["10.0.0.0/16"]
}

# Subnet for App Service
resource "azurerm_subnet" "subnet_appservice" {
  name                 = "subnet-appservice"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnetwork.name
  address_prefixes     = ["10.0.1.0/24"]

  delegation {
    name = "delegation"
    service_delegation {
      name = "Microsoft.Web/serverFarms"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action"
      ]
    }
  }
}

# Subnet for Private Endpoints
resource "azurerm_subnet" "subnet_private" {
  name                 = "subnet-private-endpoints"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnetwork.name
  address_prefixes     = ["10.0.2.0/24"]
}

# App Service Plan
resource "azurerm_service_plan" "asp" {
  name                = "my-appservice-plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "P1mv3"
}

# App Service
resource "azurerm_linux_web_app" "app" {
  name                = "my-app-service-${random_string.random_suffix.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.asp.id

  identity {
    type = "SystemAssigned"
  }

  site_config {
    vnet_route_all_enabled = true
  }
}

resource "azurerm_app_service_virtual_network_swift_connection" "app_vnet_integration" {
  app_service_id = azurerm_linux_web_app.app.id
  subnet_id      = azurerm_subnet.subnet_appservice.id
}

# Application Insights
resource "azurerm_application_insights" "app_insights" {
  name                = "my-app-insights-${random_string.random_suffix.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  application_type    = "web"
}

# Azure Container Registry
resource "azurerm_container_registry" "acr" {
  name                = "acr${random_string.random_suffix.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Basic"
  admin_enabled       = false
}

# Assign ACR Pull Role to App Service Identity
resource "azurerm_role_assignment" "acr_pull" {
  principal_id         = azurerm_linux_web_app.app.identity[0].principal_id
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.acr.id
}

# Key Vault
resource "azurerm_key_vault" "kv" {
  name                = "kv-${random_string.random_suffix.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku_name            = "standard"
  tenant_id           = "aa0be88b-88a1-4032-800e-ef891c5d43c8"
}

resource "azurerm_key_vault_access_policy" "kv_policy" {
  key_vault_id       = azurerm_key_vault.kv.id
  tenant_id          = "aa0be88b-88a1-4032-800e-ef891c5d43c8"
  object_id          = azurerm_linux_web_app.app.identity[0].principal_id
  secret_permissions = ["Get", "List"]
}

resource "azurerm_private_endpoint" "kv_private_endpoint" {
  name                = "kv-private-endpoint"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.subnet_private.id

  private_service_connection {
    name                           = "kv-priv-connection"
    private_connection_resource_id = azurerm_key_vault.kv.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }
}

# SQL Server with Private Endpoint
resource "azurerm_mssql_server" "sql" {
  name                         = "sql-${random_string.random_suffix.result}"
  resource_group_name          = azurerm_resource_group.rg.name
  location                     = azurerm_resource_group.rg.location
  administrator_login          = "adminuser"
  administrator_login_password = var.sql_admin_password
  version                      = "12.0"
}

resource "azurerm_mssql_database" "sqldb" {
  name      = "my-database"
  server_id = azurerm_mssql_server.sql.id
  sku_name  = "S0"
}

resource "azurerm_private_endpoint" "sql_private_endpoint" {
  name                = "sql-private-endpoint"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.subnet_private.id

  private_service_connection {
    name                           = "sql-priv-connection"
    private_connection_resource_id = azurerm_mssql_server.sql.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }
}

# Storage Account for Terraform State
resource "azurerm_storage_account" "terraform_state" {
  name                     = "tfstate${random_string.random_suffix.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

# Storage Account and Private Endpoint for File Share
resource "azurerm_storage_account" "storage" {
  name                     = "storage${random_string.random_suffix.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_share" "fileshare" {
  name               = "myfileshare"
  storage_account_id = azurerm_storage_account.storage.id
  quota              = 5
}

resource "azurerm_private_endpoint" "storage_private_endpoint" {
  name                = "storage-private-endpoint"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.subnet_private.id

  private_service_connection {
    name                           = "storage-priv-connection"
    private_connection_resource_id = azurerm_storage_account.storage.id
    subresource_names              = ["file"]
    is_manual_connection           = false
  }
}
