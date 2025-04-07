# Storage Account and Private Endpoint for File Share
resource "azurerm_storage_account" "storage" {
  name                     = "storage${var.random_string}"
  resource_group_name      = var.resource_group_name
  location                 = var.resource_group_location
  account_tier             = var.account_tier_storage
  account_replication_type = var.account_replication_type_terraform_state
}

resource "azurerm_storage_share" "fileshare" {
  name               = "myfileshare"
  storage_account_id = azurerm_storage_account.storage.id
  quota              = 5
}

resource "azurerm_private_endpoint" "storage_private_endpoint" {
  name                = "storage-private-endpoint"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id_private

  private_service_connection {
    name                           = "storage-priv-connection"
    private_connection_resource_id = azurerm_storage_account.storage.id
    subresource_names              = ["file"]
    is_manual_connection           = false
  }
}
