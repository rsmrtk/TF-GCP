output "github_actions_plan_sa_email" {
  description = "Email of the service account for GitHub Actions plan."
  value       = google_service_account.github_actions_plan.email
}

output "github_actions_apply_sa_email" {
  description = "Email of the service account for GitHub Actions apply."
  value       = google_service_account.github_actions_apply.email
}

output "terraform_execution_sa_email" {
  description = "Email of the service account for local Terraform execution."
  value       = google_service_account.terraform_execution.email
}

output "workload_identity_pool_name" {
  description = "Full name of the Workload Identity Pool."
  value       = google_iam_workload_identity_pool.github_actions.name
}

output "workload_identity_provider_name" {
  description = "Full name of the Workload Identity Provider."
  value       = google_iam_workload_identity_pool_provider.github_actions.name
}
