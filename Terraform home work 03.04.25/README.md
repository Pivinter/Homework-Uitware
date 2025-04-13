# Terraform Infrastructure Setup for Azure

## Overview

This project performs the task of creating a complete Terraform infrastructure on Azure, including:

 - 1 App Service Plan
 - 1 App Service - integrate with VNet, enable System Managed Identity
 - 1 Application Insights - linked to App Service
 - 1 ACR - Azure Container Registry, grant App Service Identity access to it
 - 1 Key Vault - grant permissions to App Service Identity, integrate with VNet
 - 1 VNet
 - 1 MS SQL Server DB - Private Endpoint needs to be configured
 - 1 Storage account - configure Private Endpoint with VNET and mount Fileshare to App Service
 - 1 Storage account for Terraform state

---

## Step-by-Step Process

### Initial Setup

Created the following Terraform files:

- `main.tf`
- `variables.tf`
- `terraform.tfvars`
- `.gitignore`

---

### Base Resources
Created Resource Group and Virtual Network with two subnets:
  - Public Subnet  
  - Subnet for Private Endpoints  

---

### App Service Infrastructure
Created App Service Plan and App Service with:
  - VNet Integration  
  - System Assigned Managed Identity  
  - Application Insights (via instrumentation key)

---

### Application Insights
Created `azurerm_application_insights` with the help of which the toolkit key is transferred to the App Service.

---

### Azure Container Registry (ACR)
Created ACR and assigned `AcrPull` role to the App Service Managed Identity.

---

### Azure Key Vault
Created Key Vault, access granted to App Service Identity via `azurerm_key_vault_access_policy` and configured Private Endpoint  

---

### Azure SQL Server + Private Endpoint
Created SQL Server and SQL Database and setup Private Endpoint.

---

### Storage Account for App Service File Share
Created Storage Account, File Share and configured Private Endpoint.

---

### Storage Account for Terraform State
Created anouther Storage Account for Terraform State.

---

### Access Control
Used `azurerm_role_assignment` for assigning roles App Service to ACR (`AcrPull`)  

---

### Modularity

After setting up everything in `main.tf`, the file was split into the following modules for better structure:

```
modules/
├── app_service
├── container_registry
├── database
├── key_vault
├── network
└── storage
```

Then, `main.tf` was updated to use these modules.

---

## Infrastructure Deployment Process

### Step 1: Initial Run (without backend)

```bash
terraform init
terraform apply \
  -target=azurerm_resource_group.rg \
  -target=azurerm_storage_account.tfstate \
  -target=azurerm_storage_container.tfstate
```

### Step 2: Backend Configuration

```bash
terraform init   # with backend
terraform apply
```

---

## Screenshots

### After Step 1:
 ![Resource group](Images%20for%20report/Resource-group.png)
  <p align="center">Resource group</p>
  
![Container](Images%20for%20report/Conteiner.png)
  <p align="center">Container</p>
  
![Container ftstate](Images%20for%20report/Conteiner-ftstate.png)
  <p align="center">Container ftstate</p>
  
![terraform.tfstate before backend](Images%20for%20report/terraform-ftstate.png)
  <p align="center">terraform.tfstate before backend</p>

### After Step 2:

![terraform.tfstate after backend](Images%20for%20report/terraform-ftstateafter.png)
<p align="center">terraform.tfstate after backend</p>

![Container ftstate with terraform.tfstate](Images%20for%20report/Cloud-terraform.ftstate.png)
<p align="center">Container ftstate with terraform.tfstate</p>

![terraform.tfstate settings](Images%20for%20report/terraform.ftstate-settings.png)
<p align="center">terraform.tfstate settings</p>

![All resources](Images%20for%20report/Аll-resources.png)
<p align="center">All resources</p>

![All resources (continued)](Images%20for%20report/All-resources2.png)
<p align="center">All resources (continued)</p>

---

# Write terraform pipline

# Write terraform pipline in Azure

# Write Azure conection



