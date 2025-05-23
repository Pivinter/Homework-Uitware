output "storage_account_name" {
  value = azurerm_storage_account.storage.name
}

output "storage_account_key" {
  value = azurerm_storage_account.storage.primary_access_key
}

output "storage_share_name" {
  value = azurerm_storage_share.fileshare.name
}