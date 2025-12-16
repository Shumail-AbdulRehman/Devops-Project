# GCP Project
variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "gcp_region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "gcp_zone" {
  description = "GCP zone"
  type        = string
  default     = "us-central1-a"
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

# VPC Configuration
variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.2.0.0/16"
}

variable "enable_nat_gateway" {
  description = "Enable Cloud NAT for private subnets"
  type        = bool
  default     = true
}

# GKE Configuration
variable "cluster_name" {
  description = "GKE cluster name"
  type        = string
  default     = "devops-gke-cluster"
}

variable "use_autopilot" {
  description = "Use GKE Autopilot mode (recommended for cost optimization)"
  type        = bool
  default     = true
}

variable "node_machine_type" {
  description = "Machine type for GKE nodes"
  type        = string
  default     = "e2-standard-2"  # 2 vCPU, 8GB RAM
}

variable "node_count" {
  description = "Initial number of nodes"
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
  description = "Node disk size in GB"
  type        = number
  default     = 50
}

variable "use_preemptible" {
  description = "Use preemptible VMs for nodes (80% cost savings)"
  type        = bool
  default     = false
}

# Cloud SQL Configuration
variable "db_tier" {
  description = "Cloud SQL instance tier"
  type        = string
  default     = "db-f1-micro"  # Smallest tier
}

variable "db_disk_size" {
  description = "Database disk size in GB"
  type        = number
  default     = 10
}

variable "db_name" {
  description = "Database name"
  type        = string
  default     = "appdb"
}

variable "db_username" {
  description = "Database user name"
  type        = string
  default     = "dbuser"
  sensitive   = true
}

variable "db_password" {
  description = "Database user password"
  type        = string
  sensitive   = true
}
