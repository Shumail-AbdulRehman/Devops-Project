# VPC Network
resource "google_compute_network" "main" {
  name                    = "${var.project_name}-vpc"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
}

# Public Subnet
resource "google_compute_subnetwork" "public" {
  name          = "${var.project_name}-public-subnet"
  ip_cidr_range = cidrsubnet(var.vpc_cidr, 4, 0)
  region        = var.gcp_region
  network       = google_compute_network.main.id
  
  secondary_ip_range {
    range_name    = "services-range"
    ip_cidr_range = "172.16.0.0/20"
  }
  
  secondary_ip_range {
    range_name    = "pods-range"
    ip_cidr_range = "172.17.0.0/16"
  }
}

# Private Subnet for GKE
resource "google_compute_subnetwork" "gke" {
  name          = "${var.project_name}-gke-subnet"
  ip_cidr_range = cidrsubnet(var.vpc_cidr, 4, 1)
  region        = var.gcp_region
  network       = google_compute_network.main.id
  
  private_ip_google_access = true
  
  secondary_ip_range {
    range_name    = "gke-pods"
    ip_cidr_range = "10.4.0.0/14"
  }
  
  secondary_ip_range {
    range_name    = "gke-services"
    ip_cidr_range = "10.8.0.0/20"
  }
}

# Cloud Router for NAT
resource "google_compute_router" "main" {
  count   = var.enable_nat_gateway ? 1 : 0
  name    = "${var.project_name}-router"
  region  = var.gcp_region
  network = google_compute_network.main.id
}

# Cloud NAT
resource "google_compute_router_nat" "main" {
  count  = var.enable_nat_gateway ? 1 : 0
  name   = "${var.project_name}-nat"
  router = google_compute_router.main[0].name
  region = var.gcp_region
  
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  
  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

# Firewall Rules - Allow Internal
resource "google_compute_firewall" "allow_internal" {
  name    = "${var.project_name}-allow-internal"
  network = google_compute_network.main.name
  
  allow {
    protocol = "icmp"
  }
  
  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  
  source_ranges = [var.vpc_cidr]
}

# Firewall Rules - Allow SSH
resource "google_compute_firewall" "allow_ssh" {
  name    = "${var.project_name}-allow-ssh"
  network = google_compute_network.main.name
  
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh-enabled"]
}

# Firewall Rules - Allow HTTP/HTTPS
resource "google_compute_firewall" "allow_http_https" {
  name    = "${var.project_name}-allow-http-https"
  network = google_compute_network.main.name
  
  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }
  
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["web-server"]
}
