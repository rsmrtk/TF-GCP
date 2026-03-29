################################################################################
# Compute Engine Service Account (equivalent of AWS EC2 IAM Role)
################################################################################

resource "google_service_account" "compute" {
  count = var.create_compute_sa ? 1 : 0

  account_id   = "${local.name_prefix}-compute-sa"
  display_name = "Compute Engine service account for ${local.name_prefix}"
  project      = var.project_id
}

################################################################################
# Compute Engine IAM Role Bindings
################################################################################

# Allow writing logs to Cloud Logging
resource "google_project_iam_member" "compute_log_writer" {
  count = var.create_compute_sa ? 1 : 0

  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.compute[0].email}"
}

# Allow writing metrics to Cloud Monitoring
resource "google_project_iam_member" "compute_metric_writer" {
  count = var.create_compute_sa ? 1 : 0

  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.compute[0].email}"
}

# Allow reading objects from GCS (e.g., pulling artifacts, configs)
resource "google_project_iam_member" "compute_storage_viewer" {
  count = var.create_compute_sa ? 1 : 0

  project = var.project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.compute[0].email}"
}

################################################################################
# Compute Engine - KMS Permissions (optional)
################################################################################

resource "google_kms_crypto_key_iam_member" "compute_kms" {
  count = var.create_compute_sa && var.kms_key_id != "" ? 1 : 0

  crypto_key_id = var.kms_key_id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${google_service_account.compute[0].email}"
}

################################################################################
# Compute Engine - GCS Bucket Permissions (optional)
################################################################################

resource "google_storage_bucket_iam_member" "compute_gcs" {
  count = var.create_compute_sa ? length(var.gcs_bucket_names) : 0

  bucket = var.gcs_bucket_names[count.index]
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.compute[0].email}"
}
