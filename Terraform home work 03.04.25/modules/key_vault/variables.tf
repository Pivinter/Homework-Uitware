variable "sku_name_kv" {
  description = "Existing Key Vault Sku name"
  type        = string
}

variable "tenant_id" {
  description = "Azure Tenant Id"
  type        = string
  sensitive   = true
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
variable "object_id" {}