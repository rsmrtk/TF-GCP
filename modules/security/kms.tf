# -----------------------------------------------------------------------------
# Cloud KMS - Encryption Key Management (equivalent to AWS KMS)
# -----------------------------------------------------------------------------
# Creates a KMS keyring and a symmetric encryption/decryption key with
# automatic 90-day rotation. The key can be used for CMEK (Customer-Managed
# Encryption Keys) across GCP services such as Cloud SQL, GCS, and GKE.
# -----------------------------------------------------------------------------

resource "google_kms_key_ring" "this" {
  name     = "${local.name_prefix}-keyring"
  location = var.region
  project  = var.project_id
}

resource "google_kms_crypto_key" "this" {
  name            = "${local.name_prefix}-key"
  key_ring        = google_kms_key_ring.this.id
  rotation_period = "7776000s" # 90 days
  purpose         = "ENCRYPT_DECRYPT"

  labels = merge(local.common_labels, var.labels)

  lifecycle {
    prevent_destroy = true
  }
}
