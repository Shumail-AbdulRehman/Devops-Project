# Cloud Storage Bucket
resource "google_storage_bucket" "main" {
  name          = "${var.project_name}-${var.environment}-storage-${random_string.suffix.result}"
  location      = var.gcp_region
  force_destroy = true
  
  uniform_bucket_level_access = true
  
  versioning {
    enabled = true
  }
  
  lifecycle_rule {
    condition {
      age = 30
    }
    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
  }
  
  lifecycle_rule {
    condition {
      age = 90
    }
    action {
      type          = "SetStorageClass"
      storage_class = "COLDLINE"
    }
  }
  
  labels = {
    environment = var.environment
    managed_by  = "terraform"
  }
}

# IAM binding for service account access (optional)
resource "google_storage_bucket_iam_member" "gke_access" {
  bucket = google_storage_bucket.main.name
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${var.project_id}.svc.id.goog[default/default]"
  
  depends_on = [google_storage_bucket.main]
}
