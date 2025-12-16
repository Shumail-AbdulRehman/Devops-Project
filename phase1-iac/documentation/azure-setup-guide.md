# Azure Free Tier Setup Guide

## Overview

This guide provides step-by-step instructions for setting up a Microsoft Azure free account for this DevOps project.

## Prerequisites

- Microsoft account (or create a new one)
- Credit/debit card for verification
- Phone number for verification
- Valid email address

## Step 1: Create Azure Account

1. **Visit Azure**: Go to [azure.microsoft.com/free](https://azure.microsoft.com/free)
2. **Click "Start free"**
3. **Sign in with Microsoft Account** or create a new one

## Step 2: Account Information

1. **Enter Personal Information**:
   - Country/Region
   - First and last name
   - Email address
   - Phone number

2. **Identity Verification by Phone**:
   - Enter phone number
   - Choose verification method (text or call)
   - Enter verification code

3. **Identity Verification by Card**:
   - Enter credit/debit card information
   - Azure charges $1 for verification (refunded)
   - This card won't be charged unless you upgrade

4. **Agreement**:
   - Read and accept the subscription agreement
   - Click "Sign up"

## Step 3: Access Azure Portal

1. **Navigate to Portal**: Go to [portal.azure.com](https://portal.azure.com)
2. **Sign In**: Use your Microsoft account credentials
3. **Explore Dashboard**: Familiarize yourself with the Azure Portal interface

## Step 4: Install Azure CLI

### Linux Installation

```bash
# Install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

# Verify installation
az --version
```

### Alternative Installation Methods

```bash
# Using pip
pip install azure-cli

# Using snap
sudo snap install azure-cli --classic
```

## Step 5: Azure CLI Authentication

```bash
# Login to Azure
az login

# This will open a browser window for authentication
# Select your account and grant permissions

# Verify login
az account show

# List all subscriptions
az account list --output table

# Set default subscription (if you have multiple)
az account set --subscription "Your Subscription Name"
```

## Step 6: Create Service Principal for Terraform

```bash
# Create a service principal
az ad sp create-for-rbac \
  --name "terraform-sp" \
  --role="Contributor" \
  --scopes="/subscriptions/YOUR_SUBSCRIPTION_ID"

# Output will look like:
# {
#   "appId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
#   "displayName": "terraform-sp",
#   "password": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
#   "tenant": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
# }

# Save these credentials securely - you'll need them for Terraform
```

## Step 7: Configure Environment Variables

```bash
# Add to your ~/.bashrc or ~/.zshrc
export ARM_CLIENT_ID="<appId from above>"
export ARM_CLIENT_SECRET="<password from above>"
export ARM_SUBSCRIPTION_ID="<your subscription id>"
export ARM_TENANT_ID="<tenant from above>"

# Reload shell configuration
source ~/.bashrc  # or source ~/.zshrc
```

## Step 8: Verify Configuration

```bash
# Test Azure CLI with subscription
az group list

# Create a test resource group
az group create --name test-rg --location eastus

# List resource groups
az group list --output table

# Delete test resource group
az group delete --name test-rg --yes --no-wait
```

## Azure Free Tier Resources Used in This Project

### Compute
- **Virtual Machines**: 750 hours/month of B1s Burstable VM (Linux)
- **AKS**: Free cluster management (pay only for VMs, storage, and networking)

### Storage
- **Blob Storage**: 5 GB locally redundant storage (LRS)
- **Managed Disks**: 64 GB P6 SSD

### Database
- **Azure SQL Database**: 250 GB storage

### Networking
- **Virtual Network**: Free
- **Load Balancer**: Free tier available
- **Bandwidth**: 15 GB outbound data transfer

### Free Tier Duration
- **12 Months Free**: VMs, Blob Storage, SQL Database
- **Always Free**: VNet, specific services within limits

## Important Notes

### Avoid Unexpected Charges

1. **Set Up Cost Alerts**:
   ```bash
   # Navigate to Cost Management + Billing in Azure Portal
   # Set up budget alerts
   ```

2. **Monitor Spending**:
   - Use Azure Cost Management dashboard
   - Check "Cost Analysis" regularly
   - Set budget limits

3. **Clean Up Resources**:
   ```bash
   # Always destroy resources when done
   terraform destroy
   
   # Or delete resource group (deletes all resources inside)
   az group delete --name <resource-group-name> --yes
   ```

### Free Tier Limits to Watch

- **AKS**: Free cluster management, but VM costs apply
- **Public IP Addresses**: Limited free static IPs
- **Load Balancer**: Basic tier is free, Standard tier has costs
- **Bandwidth**: 15 GB outbound free, then $0.05-0.087/GB

### Cost-Saving Tips

1. **Use B-series VMs** (burstable, cost-effective)
2. **Use Basic tier services** where possible
3. **Deallocate VMs** when not in use
   ```bash
   az vm deallocate --resource-group myRG --name myVM
   ```
4. **Use single region** for development
5. **Enable auto-shutdown** for VMs
6. **Delete unused disks** and snapshots

## Resource Naming Conventions

Azure has specific naming requirements:

```bash
# Resource Group: 1-90 alphanumeric, periods, underscores, hyphens, parentheses
rg-devops-eastus

# Virtual Network: 2-64 alphanumeric, underscores, hyphens, periods
vnet-devops-eastus

# Storage Account: 3-24 lowercase alphanumeric
stdevopsmulticloud001

# AKS Cluster: 1-63 alphanumeric and hyphens
aks-devops-cluster
```

## Regional Considerations

### Recommended Regions
- **East US** - Broadest service availability
- **West Europe** - Good for European projects
- **Southeast Asia** - Good for Asian projects

### Check Service Availability
```bash
# List all locations
az account list-locations --output table

# Check if a service is available in a region
az provider show --namespace Microsoft.Compute --query "resourceTypes[?resourceType=='virtualMachines'].locations"
```

## Troubleshooting

### Issue: Authentication Failed
```bash
# Clear Azure CLI cache
az account clear
az login
```

### Issue: Subscription Not Found
```bash
# List all subscriptions
az account list --output table

# Set correct subscription
az account set --subscription "subscription-id"
```

### Issue: Insufficient Permissions
```bash
# Check current role assignments
az role assignment list --assignee <your-email> --output table

# May need to contact subscription administrator
```

### Issue: Quota Exceeded
```bash
# Check quotas
az vm list-usage --location eastus --output table

# Request quota increase through Azure Portal
```

## Security Best Practices

1. **Enable Azure AD MFA** for all users
2. **Use Managed Identities** instead of service principals when possible
3. **Implement RBAC** (Role-Based Access Control)
4. **Enable Azure Security Center** (free tier available)
5. **Use Azure Key Vault** for secrets management
6. **Enable Network Security Groups** (NSGs)
7. **Enable Azure Monitor** for logging
8. **Regular security audits** using Azure Advisor

## Azure Resource Manager (ARM) Tags

Use tags to organize and track resources:

```bash
# Create resource with tags
az group create \
  --name rg-devops \
  --location eastus \
  --tags Environment=Development Project=DevOps Owner=YourName
```

## Next Steps

Once your Azure account is configured:

1. Review the Terraform code in `terraform/azure/`
2. Update variables in `terraform.tfvars`
3. Initialize Terraform: `terraform init`
4. Plan deployment: `terraform plan`
5. Apply configuration: `terraform apply`

## Additional Resources

- [Azure Free Account FAQ](https://azure.microsoft.com/free/free-account-faq/)
- [Azure Documentation](https://docs.microsoft.com/azure/)
- [Azure Pricing Calculator](https://azure.microsoft.com/pricing/calculator/)
- [Azure Architecture Center](https://docs.microsoft.com/azure/architecture/)
- [Azure CLI Documentation](https://docs.microsoft.com/cli/azure/)

## Support

For Azure-related issues:
- Azure Support (available with free account)
- Microsoft Q&A forums
- Azure Community Support
- Stack Overflow (tag: azure)
