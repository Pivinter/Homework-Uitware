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

variable "resource_group_name" {
  description = "Existing Resource Group Name"
  type        = string
}

variable "resource_group_location" {
  description = "Existing Resource Group Location"
  type        = string
}
variable "storage_account_name" {}
variable "storage_account_key" {}
variable "storage_share_name" {}
variable "subnet_id" {}
variable "random_string" {}