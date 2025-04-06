resource "random_string" "random_suffix" {
  length  = 6
  special = false
  upper   = false
}
# Virtual Network
resource "azurerm_virtual_network" "vnetwork" {
  name                = "vnetwork-${random_string.random_suffix.result}"
  resource_group_name = var.resource_group_name
  location            = var.resource_group_location
  address_space       = [var.address_space_vnetwork]
}

# Subnet for App Service
resource "azurerm_subnet" "subnet_appservice" {
  name                 = "subnet-appservice"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnetwork.name
  address_prefixes     = [var.address_prefixes_subnet_appservice]

  delegation {
    name = "delegation"
    service_delegation {
      name = "Microsoft.Web/serverFarms"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action"
      ]
    }
  }
}

# Subnet for Private Endpoints
resource "azurerm_subnet" "subnet_private" {
  name                 = "subnet-private-endpoints"
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.vnetwork.name
  address_prefixes     = [var.address_prefixes_subnet_private]

  service_endpoints = ["Microsoft.KeyVault"]
}