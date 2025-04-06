variable "sku_acr" {
  description = "Existing azurerm container registry"
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

variable "principal_id" {}