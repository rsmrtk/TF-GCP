provider "google" {
  project = var.project_id
  region  = var.gcp_region

  default_labels = {
    project    = var.project
    managed-by = "terraform"
    component  = "backend-bootstrap"
    repository = "rsmrtk/TF-GCP"
  }
}

# ---------------------------------------------------------------------------
# GCS buckets for Terraform remote state
#
# GCS has built-in state locking, so no separate lock table (like AWS
# DynamoDB) is needed.
# ---------------------------------------------------------------------------
resource "google_storage_bucket" "terraform_state" {
  for_each = toset(var.environments)

  name     = "${var.project}-${each.value}-terraform-state"
  project  = var.project_id
  location = var.gcp_region

  storage_class             = "STANDARD"
  uniform_bucket_level_access = true
  public_access_prevention  = "enforced"

  versioning {
    enabled = true
  }

  # Delete noncurrent object versions after 90 days.
  lifecycle_rule {
    condition {
      days_since_noncurrent_time = 90
    }
    action {
      type = "Delete"
    }
  }

  # Transition noncurrent versions to NEARLINE after 30 days.
  lifecycle_rule {
    condition {
      days_since_noncurrent_time = 30
    }
    action {
      type          = "SetStorageClass"
      storage_class = "NEARLINE"
    }
  }

  labels = merge(
    var.labels,
    {
      environment = each.value
      purpose     = "terraform-state"
    },
  )

  lifecycle {
    prevent_destroy = true
  }
}
