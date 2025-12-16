# Azure Region
variable "azure_region" {
  description = "Azure region to deploy resources"
  type        = string
  default     = "eastus"
}

# Project Configuration
variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  default     = "devops"
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
  default     = "dev"
}

# VNet Configuration
variable "vnet_cidr" {
  description = "CIDR block for VNet"
  type        = string
  default     = "10.1.0.0/16"
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for private subnets"
  type        = bool
  default     = false  # Set to false to save costs
}

# AKS Configuration
variable "cluster_name" {
  description = "AKS cluster name"
  type        = string
  default     = "devops-aks-cluster"
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.28"
}

variable "node_vm_size" {
  description = "VM size for AKS nodes"
  type        = string
  default     = "Standard_B2ms"  # 2 vCPU, 8GB RAM
}

variable "node_count" {
  description = "Initial node count"
  type        = number
  default     = 1
}

variable "node_min_count" {
  description = "Minimum number of nodes"
  type        = number
  default     = 1
}

variable "node_max_count" {
  description = "Maximum number of nodes"
  type        = number
  default     = 3
}

variable "node_disk_size" {
  description = "Node OS disk size in GB"
  type        = number
  default     = 128
}

# Database Configuration
variable "db_sku_name" {
  description = "MySQL SKU name"
  type        = string
  default     = "B_Standard_B1s"  # Burstable, cost-effective
}

variable "db_storage_gb" {
  description = "MySQL storage size in GB"
  type        = number
  default     = 20
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Database administrator username"
  type        = string
  default     = "azureuser"
  sensitive   = true
}

variable "db_password" {
  description = "Database administrator password"
  type        = string
  sensitive   = true
}
