# App Service Plan
resource "azurerm_service_plan" "asp" {
  name                = "my-appservice-plan"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  os_type             = var.os_type
  sku_name            = var.sku_name_asp
}

# App Service
resource "azurerm_linux_web_app" "app" {
  name                = "my-app-service-${var.random_string}"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  service_plan_id     = azurerm_service_plan.asp.id

  identity {
    type = "SystemAssigned"
  }

  site_config {
    vnet_route_all_enabled = true
  }

  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY"           = azurerm_application_insights.app_insights.instrumentation_key
    "APPLICATIONINSIGHTS_CONNECTION_STRING"    = azurerm_application_insights.app_insights.connection_string
    "WEBSITES_ENABLE_APP_SERVICE_STORAGE"      = "true"
    "AZURE_STORAGE_ACCOUNT_NAME"               = var.storage_account_name
    "AZURE_STORAGE_ACCOUNT_KEY"                = var.storage_account_key
    "WEBSITE_CONTENTAZUREFILECONNECTIONSTRING" = "DefaultEndpointsProtocol=https;AccountName=${var.storage_account_name};AccountKey=${var.storage_account_key}"
    "WEBSITE_CONTENTSHARE"                     = var.storage_share_name
  }

}

resource "azurerm_app_service_virtual_network_swift_connection" "app_vnet_integration" {
  app_service_id = azurerm_linux_web_app.app.id
  subnet_id      = var.subnet_id
}

# Application Insights
resource "azurerm_application_insights" "app_insights" {
  name                = "my-app-insights-${var.random_string}"
  location            = var.resource_group_location
  resource_group_name = var.resource_group_name
  application_type    = var.application_type_app_insights
}

