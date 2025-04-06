resource "random_string" "random_suffix" {
  length  = 6
  special = false
  upper   = false
}
# SQL Server with Private Endpoint
resource "azurerm_mssql_server" "sql" {
  name                         = "sql-${random_string.random_suffix.result}"
  resource_group_name          = var.resource_group_name
  location                     = var.resource_group_location
  administrator_login          = var.sql_admin_user
  administrator_login_password = var.sql_admin_password
  version                      = "12.0"
}

resource "azurerm_mssql_database" "sqldb" {
  name      = "my-database"
  server_id = azurerm_mssql_server.sql.id
  sku_name  = var.sku_name_sqldb
}

resource "azurerm_private_endpoint" "sql_private_endpoint" {
  name                = "sql-private-endpoint"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id_private

  private_service_connection {
    name                           = "sql-priv-connection"
    private_connection_resource_id = azurerm_mssql_server.sql.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }
}