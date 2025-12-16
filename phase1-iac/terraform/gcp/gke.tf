# GKE Cluster
resource "google_container_cluster" "main" {
  name     = var.cluster_name
  location = var.gcp_zone
  
  # Use Autopilot mode for cost optimization and easier management
  enable_autopilot = var.use_autopilot
  
  # For standard mode configuration
  dynamic "node_config" {
    for_each = var.use_autopilot ? [] : [1]
    content {
      machine_type = var.node_machine_type
      disk_size_gb = var.node_disk_size
      oauth_scopes = [
        "https://www.googleapis.com/auth/cloud-platform"
      ]
    }
  }
  
  # We can't create a cluster with no node pool, so we create the smallest possible default node pool and immediately delete it
  dynamic "initial_node_count" {
    for_each = var.use_autopilot ? [] : [1]
    content {
      initial_node_count = 1
    }
  }
  
  network    = google_compute_network.main.name
  subnetwork = google_compute_subnetwork.gke.name
  
  # IP allocation policy for VPC-native cluster
  ip_allocation_policy {
    cluster_secondary_range_name  = "gke-pods"
    services_secondary_range_name = "gke-services"
  }
  
  # Private cluster configuration
  private_cluster_config {
    enable_private_nodes    = true
    enable_private_endpoint = false
    master_ipv4_cidr_block  = "172.18.0.0/28"
  }
  
  # Master authorized networks (allow access from anywhere for demo)
  master_authorized_networks_config {
    cidr_blocks {
      cidr_block   = "0.0.0.0/0"
      display_name = "All"
    }
  }
  
  # Maintenance window
  maintenance_policy {
    daily_maintenance_window {
      start_time = "03:00"
    }
  }
  
  # Logging and monitoring
  logging_service    = "logging.googleapis.com/kubernetes"
  monitoring_service = "monitoring.googleapis.com/kubernetes"
  
  # Addons
  addons_config {
    http_load_balancing {
      disabled = false
    }
    
    horizontal_pod_autoscaling {
      disabled = false
    }
  }
  
  # Release channel
  release_channel {
    channel = "STABLE"
  }
  
  # Network policy
  network_policy {
    enabled  = true
    provider = "PROVIDER_UNSPECIFIED"
  }
  
  # Workload identity
  workload_identity_config {
    workload_pool = "${var.project_id}.svc.id.goog"
  }
  
  # Remove default node pool
  remove_default_node_pool = var.use_autopilot ? false : true
}

# Separately managed node pool (only if not using Autopilot)
resource "google_container_node_pool" "main" {
  count      = var.use_autopilot ? 0 : 1
  name       = "${var.project_name}-node-pool"
  location   = var.gcp_zone
  cluster    = google_container_cluster.main.name
  node_count = var.node_count
  
  autoscaling {
    min_node_count = var.node_min_count
    max_node_count = var.node_max_count
  }
  
  management {
    auto_repair  = true
    auto_upgrade = true
  }
  
  node_config {
    preemptible  = var.use_preemptible
    machine_type = var.node_machine_type
    disk_size_gb = var.node_disk_size
    
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
    
    metadata = {
      disable-legacy-endpoints = "true"
    }
    
    labels = {
      environment = var.environment
      managed_by  = "terraform"
    }
    
    tags = ["gke-node", "${var.project_name}-node"]
  }
}
