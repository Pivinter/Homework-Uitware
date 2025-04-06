resource "random_string" "random_suffix" {
  length  = 6
  special = false
  upper   = false
}
# Key Vault
resource "azurerm_key_vault" "kv" {
  name                = "kv-${random_string.random_suffix.result}"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  sku_name            = var.sku_name_kv
  tenant_id           = var.tenant_id

  network_acls {
    default_action             = "Deny"
    bypass                     = "AzureServices"
    virtual_network_subnet_ids = [var.subnet_id_private]
  }
}

resource "azurerm_key_vault_access_policy" "kv_policy" {
  key_vault_id       = azurerm_key_vault.kv.id
  tenant_id          = var.tenant_id
  object_id          = var.object_id
  secret_permissions = ["Get", "List"]
}

resource "azurerm_private_endpoint" "kv_private_endpoint" {
  name                = "kv-private-endpoint"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id_private

  private_service_connection {
    name                           = "kv-priv-connection"
    private_connection_resource_id = azurerm_key_vault.kv.id
    subresource_names              = ["vault"]
    is_manual_connection           = false
  }
}