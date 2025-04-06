output "subnet_id" {
  value = azurerm_subnet.subnet_appservice.id
}

output "subnet_id_private" {
  value = azurerm_subnet.subnet_private.id
}