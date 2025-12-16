# VPC Outputs
output "vpc_name" {
  description = "Name of the VPC"
  value       = google_compute_network.main.name
}

output "vpc_id" {
  description = "ID of the VPC"
  value       = google_compute_network.main.id
}

output "public_subnet_name" {
  description = "Name of public subnet"
  value       = google_compute_subnetwork.public.name
}

output "gke_subnet_name" {
  description = "Name of GKE subnet"
  value       = google_compute_subnetwork.gke.name
}

# GKE Outputs
output "gke_cluster_name" {
  description = "GKE cluster name"
  value       = google_container_cluster.main.name
}

output "gke_cluster_endpoint" {
  description = "GKE cluster endpoint"
  value       = google_container_cluster.main.endpoint
  sensitive   = true
}

output "gke_cluster_ca_certificate" {
  description = "GKE cluster CA certificate"
  value       = google_container_cluster.main.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

output "gke_cluster_location" {
  description = "GKE cluster location"
  value       = google_container_cluster.main.location
}

# Storage Outputs
output "storage_bucket_name" {
  description = "Name of the Cloud Storage bucket"
  value       = google_storage_bucket.main.name
}

output "storage_bucket_url" {
  description = "URL of the Cloud Storage bucket"
  value       = google_storage_bucket.main.url
}

# Cloud SQL Outputs
output "cloudsql_instance_name" {
  description = "Name of the Cloud SQL instance"
  value       = google_sql_database_instance.main.name
}

output "cloudsql_connection_name" {
  description = "Connection name for Cloud SQL"
  value       = google_sql_database_instance.main.connection_name
}

output "cloudsql_private_ip" {
  description = "Private IP address of Cloud SQL instance"
  value       = google_sql_database_instance.main.private_ip_address
}

output "cloudsql_database_name" {
  description = "Name of the database"
  value       = google_sql_database.main.name
}

# General Outputs
output "project_id" {
  description = "GCP Project ID"
  value       = var.project_id
}

output "region" {
  description = "GCP region"
  value       = var.gcp_region
}

output "configure_kubectl" {
  description = "Command to configure kubectl"
  value       = "gcloud container clusters get-credentials ${google_container_cluster.main.name} --zone ${var.gcp_zone} --project ${var.project_id}"
}
