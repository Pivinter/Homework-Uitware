Ran:
terraform init
terraform apply -target=azurerm_resource_group.rg -target=azurerm_storage_account.tfstate -target=azurerm_storage_container.tfstate

Run:
terraform init #з бекендом
terraform apply