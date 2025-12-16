# Storage Account
resource "azurerm_storage_account" "main" {
  name                     = "${var.project_name}${var.environment}st${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  
  blob_properties {
    versioning_enabled = true
    
    delete_retention_policy {
      days = 7
    }
    
    container_delete_retention_policy {
      days = 7
    }
  }
  
  tags = {
    Name = "${var.project_name}-storage"
  }
}

# Blob Container
resource "azurerm_storage_container" "main" {
  name                  = "${var.project_name}-container"
  storage_account_name  = azurerm_storage_account.main.name
  container_access_type = "private"
}

# Storage Account Network Rules
resource "azurerm_storage_account_network_rules" "main" {
  storage_account_id = azurerm_storage_account.main.id
  
  default_action             = "Deny"
  ip_rules                   = []
  virtual_network_subnet_ids = [azurerm_subnet.aks.id]
  bypass                     = ["AzureServices"]
}
