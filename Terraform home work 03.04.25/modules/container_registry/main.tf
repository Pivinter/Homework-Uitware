# Azure Container Registry
resource "azurerm_container_registry" "acr" {
  name                = "acr${var.random_string}"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  sku                 = var.sku_acr
  admin_enabled       = false
}

# Assign ACR Pull Role to App Service Identity
resource "azurerm_role_assignment" "acr_pull" {
  principal_id         = var.principal_id
  role_definition_name = "AcrPull"
  scope                = azurerm_container_registry.acr.id
}