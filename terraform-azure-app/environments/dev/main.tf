module "networking" {
  source = "../../modules/networking"
  vnet_name = "dev-vnet"
  subnet_name = "dev-subnet"
  location = "East US"
  resource_group_name = "dev-rg"
}

module "app_service" {
  source = "../../modules/app_service"
  app_service_plan_name = "dev-app-plan"
  app_service_name = "dev-app"
  app_insights_name = "dev-insights"
  location = "East US"
  resource_group_name = "dev-rg"
}
