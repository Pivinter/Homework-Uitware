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

variable "resource_group_name" {
  description = "Existing Resource Group Name"
  type        = string
}

variable "resource_group_location" {
  description = "Existing Resource Group Location"
  type        = string
}
variable "subnet_id_private" {}
variable "random_string" {}