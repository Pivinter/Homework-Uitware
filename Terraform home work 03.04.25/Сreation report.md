# Terraform Infrastructure Setup for Azure

## Overview

This project performs the task of creating a complete Terraform infrastructure on Azure, including:

- `1` App Service Plan  
- `1` App Service with:
  - VNet Integration  
  - System Managed Identity  
- `1` Application Insights (linked to App Service)  
- `1` Azure Container Registry (ACR) with access granted to App Service Identity  
- `1` Azure Key Vault with:
  - Permissions for App Service Identity  
  - Private Endpoint  
- `1` Virtual Network (VNet)  
- `1` Azure SQL Server Database with Private Endpoint  
- `1` Storage Account with:
  - Private Endpoint  
  - File Share mounted to App Service  
- `1` Separate Storage Account for Terraform State  

---

## Step-by-Step Process

### 🔹 Initial Setup

Created the following Terraform files:

- `main.tf`
- `variables.tf`
- `terraform.tfvars`
- `.gitignore`

---

### 🔹 Base Resources

- **Resource Group**
- **Virtual Network** with two subnets:
  - Public Subnet  
  - Subnet for Private Endpoints  

---

### 🔹 App Service Infrastructure

- **App Service Plan**
- **App Service** with:
  - VNet Integration  
  - System Assigned Managed Identity  
  - Application Insights (via instrumentation key)

---

### 🔹 Application Insights

- Created with `azurerm_application_insights`  
- Instrumentation key passed to App Service  

---

### 🔹 Azure Container Registry (ACR)

- ACR created  
- Assigned `AcrPull` role to the App Service Managed Identity  

---

### 🔹 Azure Key Vault

- Key Vault created  
- Access granted to App Service Identity via `azurerm_key_vault_access_policy`  
- Private Endpoint configured  

---

### 🔹 Azure SQL Server + Private Endpoint

- SQL Server and SQL Database created  
- Private Endpoint setup  

---

### 🔹 Storage Account for App Service File Share

- Storage Account created  
- File Share created  
- Private Endpoint configured  

---

### 🔹 Storage Account for Terraform State

- Separate Storage Account created  
- Used as backend for storing Terraform state  

---

### 🔹 RBAC & Access Control

- Used `azurerm_role_assignment` for assigning roles:
  - App Service → ACR (`AcrPull`)  

---

### 🔹 Modularity

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

## ⛏ Infrastructure Deployment Process

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

## 📷 Screenshots

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
