# Cloud SQL Instance
resource "google_sql_database_instance" "main" {
  name             = "${var.project_name}-${var.environment}-db-${random_string.suffix.result}"
  database_version = "MYSQL_8_0"
  region           = var.gcp_region
  
  settings {
    tier              = var.db_tier
    availability_type = "ZONAL"  # Use REGIONAL for high availability
    disk_size         = var.db_disk_size
    disk_type         = "PD_SSD"
    
    backup_configuration {
      enabled            = true
      start_time         = "03:00"
      binary_log_enabled = true
    }
    
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.main.id
      require_ssl     = false
    }
    
    maintenance_window {
      day          = 7  # Sunday
      hour         = 3
      update_track = "stable"
    }
    
    database_flags {
      name  = "character_set_server"
      value = "utf8mb4"
    }
  }
  
  deletion_protection = false
  
  depends_on = [google_service_networking_connection.private_vpc_connection]
}

# Private VPC connection for Cloud SQL
resource "google_compute_global_address" "private_ip_address" {
  name          = "${var.project_name}-private-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.main.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.main.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

# Cloud SQL Database
resource "google_sql_database" "main" {
  name     = var.db_name
  instance = google_sql_database_instance.main.name
  charset  = "utf8mb4"
  collation = "utf8mb4_unicode_ci"
}

# Cloud SQL User
resource "google_sql_user" "main" {
  name     = var.db_username
  instance = google_sql_database_instance.main.name
  password = var.db_password
}
