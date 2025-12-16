# Resource Group Outputs
output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_location" {
  description = "Location of the resource group"
  value       = azurerm_resource_group.main.location
}

# VNet Outputs
output "vnet_id" {
  description = "ID of the VNet"
  value       = azurerm_virtual_network.main.id
}

output "vnet_name" {
  description = "Name of the VNet"
  value       = azurerm_virtual_network.main.name
}

output "public_subnet_id" {
  description = "ID of public subnet"
  value       = azurerm_subnet.public.id
}

output "aks_subnet_id" {
  description = "ID of AKS subnet"
  value       = azurerm_subnet.aks.id
}

# AKS Outputs
output "aks_cluster_name" {
  description = "Name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.name
}

output "aks_cluster_id" {
  description = "ID of the AKS cluster"
  value       = azurerm_kubernetes_cluster.main.id
}

output "aks_kube_config" {
  description = "Kubernetes configuration"
  value       = azurerm_kubernetes_cluster.main.kube_config_raw
  sensitive   = true
}

output "aks_host" {
  description = "AKS cluster host"
  value       = azurerm_kubernetes_cluster.main.kube_config[0].host
  sensitive   = true
}

# Storage Outputs
output "storage_account_name" {
  description = "Name of the storage account"
  value       = azurerm_storage_account.main.name
}

output "storage_account_primary_key" {
  description = "Primary access key for storage account"
  value       = azurerm_storage_account.main.primary_access_key
  sensitive   = true
}

output "blob_container_name" {
  description = "Name of the blob container"
  value       = azurerm_storage_container.main.name
}

# Database Outputs
output "mysql_server_name" {
  description = "Name of the MySQL server"
  value       = azurerm_mysql_flexible_server.main.name
}

output "mysql_fqdn" {
  description = "FQDN of the MySQL server"
  value       = azurerm_mysql_flexible_server.main.fqdn
}

output "mysql_database_name" {
  description = "Name of the database"
  value       = azurerm_mysql_flexible_database.main.name
}

# General Outputs
output "configure_kubectl" {
  description = "Command to configure kubectl"
  value       = "az aks get-credentials --resource-group ${azurerm_resource_group.main.name} --name ${azurerm_kubernetes_cluster.main.name}"
}
