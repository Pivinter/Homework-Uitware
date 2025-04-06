variable "resource_group_name" {
  description = "Existing Resource Group Name"
  type        = string
}

variable "resource_group_location" {
  description = "Existing Resource Group Location"
  type        = string
}

variable "subscription_id" {
  description = "Existing Subscription Id"
  type        = string
  sensitive   = true
}
# App Service
variable "os_type" {
  description = "Existing App Service Plan OS"
  type        = string
}

variable "sku_name_asp" {
  description = "Existing App Service Plan Sku name"
  type        = string
}

variable "application_type_app_insights" {
  description = "Existing azurerm application insights"
  type        = string
}
# App Service End
# Container
variable "sku_acr" {
  description = "Existing azurerm container registry"
  type        = string
}
# Container End

#database
variable "sql_admin_user" {
  description = "SQL Administrator Username"
  type        = string
}

variable "sql_admin_password" {
  description = "SQL Administrator Password"
  type        = string
  sensitive   = true
}

variable "sku_name_sqldb" {
  description = "Existing azurerm mssql database sku name"
  type        = string
}
#database End

#Key vault
variable "sku_name_kv" {
  description = "Existing Key Vault Sku name"
  type        = string
}

variable "tenant_id" {
  description = "Azure Tenant Id"
  type        = string
  sensitive   = true
}
#Key vault end
# Storage
variable "account_tier_storage" {
  description = "Azure Storage Account for Terraform State account tier"
  type        = string
}

variable "account_replication_type_terraform_state" {
  description = "Azure Storage Account and Private Endpoint for File Share account replication type"
  type        = string
}
#storage end

variable "terraform_state_storage_account" {
  description = "Storage Account for Terraform state"
  type        = string
}

variable "app_service_name" {
  description = "App Service Name"
  type        = string
}

variable "app_service_plan_name" {
  description = "App Service Plan Name"
  type        = string
}

variable "acr_name" {
  description = "Azure Container Registry Name"
  type        = string
}

variable "account_replication_type_storage" {
  description = "Azure Storage Account for Terraform State account replication type"
  type        = string
}

variable "account_tier_terraform_state" {
  description = "Azure Storage Account and Private Endpoint for File Share account tier"
  type        = string
}
variable "key_vault_name" {
  description = "Azure Key Vault Name"
  type        = string
}

variable "sql_server_name" {
  description = "SQL Server Name"
  type        = string
}

variable "storage_account_name" {
  description = "Storage Account Name"
  type        = string
}

variable "address_space_vnetwork" {
  description = "Existing azurerm virtual network"
  type        = string
}

variable "address_prefixes_subnet_appservice" {
  description = "Existing Subnet for App Service"
  type        = string
}

variable "address_prefixes_subnet_private" {
  description = "Existing Subnet for Private Endpoints"
  type        = string
}
