variable "account_tier_storage" {
  description = "Azure Storage Account for Terraform State account tier"
  type        = string
}

variable "account_replication_type_terraform_state" {
  description = "Azure Storage Account and Private Endpoint for File Share account replication type"
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