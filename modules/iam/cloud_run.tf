################################################################################
# Cloud Run Service Account (equivalent of AWS ECS Task/Execution Roles)
################################################################################

resource "google_service_account" "cloud_run" {
  count = var.create_cloud_run_sa ? 1 : 0

  account_id   = "${local.name_prefix}-run-sa"
  display_name = "Cloud Run service account for ${local.name_prefix}"
  project      = var.project_id
}

################################################################################
# Cloud Run IAM Role Bindings
################################################################################

# Allow writing logs to Cloud Logging
resource "google_project_iam_member" "cloud_run_log_writer" {
  count = var.create_cloud_run_sa ? 1 : 0

  project = var.project_id
  role    = "roles/logging.logWriter"
  member  = "serviceAccount:${google_service_account.cloud_run[0].email}"
}

# Allow writing metrics to Cloud Monitoring
resource "google_project_iam_member" "cloud_run_metric_writer" {
  count = var.create_cloud_run_sa ? 1 : 0

  project = var.project_id
  role    = "roles/monitoring.metricWriter"
  member  = "serviceAccount:${google_service_account.cloud_run[0].email}"
}

# Allow accessing secrets from Secret Manager (equivalent of ECS pulling from Secrets Manager/SSM)
resource "google_project_iam_member" "cloud_run_secret_accessor" {
  count = var.create_cloud_run_sa ? 1 : 0

  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.cloud_run[0].email}"
}

# Allow connecting to Cloud SQL instances
resource "google_project_iam_member" "cloud_run_sql_client" {
  count = var.create_cloud_run_sa ? 1 : 0

  project = var.project_id
  role    = "roles/cloudsql.client"
  member  = "serviceAccount:${google_service_account.cloud_run[0].email}"
}

################################################################################
# Cloud Run - KMS Permissions (optional)
################################################################################

resource "google_kms_crypto_key_iam_member" "cloud_run_kms" {
  count = var.create_cloud_run_sa && var.kms_key_id != "" ? 1 : 0

  crypto_key_id = var.kms_key_id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
  member        = "serviceAccount:${google_service_account.cloud_run[0].email}"
}

################################################################################
# Cloud Run - GCS Bucket Permissions (optional)
################################################################################

resource "google_storage_bucket_iam_member" "cloud_run_gcs" {
  count = var.create_cloud_run_sa ? length(var.gcs_bucket_names) : 0

  bucket = var.gcs_bucket_names[count.index]
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.cloud_run[0].email}"
}
