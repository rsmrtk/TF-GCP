################################################################################
# Compute Engine Service Account Outputs
################################################################################

output "compute_sa_email" {
  description = "The email address of the Compute Engine service account."
  value       = var.create_compute_sa ? google_service_account.compute[0].email : null
}

output "compute_sa_id" {
  description = "The fully-qualified ID of the Compute Engine service account."
  value       = var.create_compute_sa ? google_service_account.compute[0].id : null
}

################################################################################
# Cloud Run Service Account Outputs
################################################################################

output "cloud_run_sa_email" {
  description = "The email address of the Cloud Run service account."
  value       = var.create_cloud_run_sa ? google_service_account.cloud_run[0].email : null
}

output "cloud_run_sa_id" {
  description = "The fully-qualified ID of the Cloud Run service account."
  value       = var.create_cloud_run_sa ? google_service_account.cloud_run[0].id : null
}

################################################################################
# Cloud Functions Service Account Outputs
################################################################################

output "cloud_functions_sa_email" {
  description = "The email address of the Cloud Functions service account."
  value       = var.create_cloud_functions_sa ? google_service_account.cloud_functions[0].email : null
}

output "cloud_functions_sa_id" {
  description = "The fully-qualified ID of the Cloud Functions service account."
  value       = var.create_cloud_functions_sa ? google_service_account.cloud_functions[0].id : null
}
