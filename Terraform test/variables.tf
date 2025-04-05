variable "resource_group_name" {
  description = "Existing Resource Group Name"
  type        = string
}

variable "subscription_id" {
  description = "Existing Subscription Id"
  type        = string
}

variable "resource_group_location" {
  description = "Existing Resource Group Location"
  type        = string
}

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

variable "sql_admin_user" {
  description = "SQL Administrator Username"
  type        = string
}

variable "sql_admin_password" {
  description = "SQL Administrator Password"
  type        = string
  sensitive   = true
}
