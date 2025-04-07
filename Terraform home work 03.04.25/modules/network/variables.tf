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

variable "resource_group_name" {
  description = "Existing Resource Group Name"
  type        = string
}

variable "resource_group_location" {
  description = "Existing Resource Group Location"
  type        = string
}
variable "random_string" {}