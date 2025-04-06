terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.25.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "BeStrong-resource-group"
    storage_account_name = "tfstatebestrong324"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
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
  address_space       = [var.address_space_vnetwork]
}

# Subnet for App Service
resource "azurerm_subnet" "subnet_appservice" {
  name                 = "subnet-appservice"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnetwork.name
  address_prefixes     = [var.address_prefixes_subnet_appservice]

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
  address_prefixes     = [var.address_prefixes_subnet_private]

  service_endpoints = ["Microsoft.KeyVault"]
}

# App Service Plan
resource "azurerm_service_plan" "asp" {
  name                = "my-appservice-plan"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = var.os_type
  sku_name            = var.sku_name_asp
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

  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY"           = azurerm_application_insights.app_insights.instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING"    = azurerm_application_insights.app_insights.connection_string
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE"      = "true"
    "AZURE_STORAGE_ACCOUNT_NAME"               = azurerm_storage_account.storage.name
    "AZURE_STORAGE_ACCOUNT_KEY"                = azurerm_storage_account.storage.primary_access_key
    "WEBSITE_CONTENTAZUREFILECONNECTIONSTRING" = "DefaultEndpointsProtocol=https;AccountName=${azurerm_storage_account.storage.name};AccountKey=${azurerm_storage_account.storage.primary_access_key}"
    "WEBSITE_CONTENTSHARE"                     = azurerm_storage_share.fileshare.name
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
  application_type    = var.application_type_app_insights
}

# Azure Container Registry
resource "azurerm_container_registry" "acr" {
  name                = "acr${random_string.random_suffix.result}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = var.sku_acr
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
  sku_name            = var.sku_name_kv
  tenant_id           = var.tenant_id

  network_acls {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    virtual_network_subnet_ids = [azurerm_subnet.subnet_private.id]
  }

}

resource "azurerm_key_vault_access_policy" "kv_policy" {
  key_vault_id       = azurerm_key_vault.kv.id
  tenant_id          = var.tenant_id
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
  administrator_login          = var.sql_admin_user
  administrator_login_password = var.sql_admin_password
  version                      = "12.0"
}

resource "azurerm_mssql_database" "sqldb" {
  name      = "my-database"
  server_id = azurerm_mssql_server.sql.id
  sku_name  = var.sku_name_sqldb
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
  name                     = "tfstatebestrong324"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = var.account_tier_terraform_state
  account_replication_type = var.account_replication_type_terraform_state
}

# Storage Account and Private Endpoint for File Share
resource "azurerm_storage_account" "storage" {
  name                     = "storage${random_string.random_suffix.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = var.account_tier_storage
  account_replication_type = var.account_replication_type_terraform_state
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"
  storage_account_id  = azurerm_storage_account.terraform_state.id
  container_access_type = "private"
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
