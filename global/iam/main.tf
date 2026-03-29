provider "google" {
  project = var.project_id
  region  = var.gcp_region

  default_labels = merge(
    {
      project    = var.project
      managed-by = "terraform"
      component  = "global-iam"
      repository = "${var.github_org}-${var.github_repo}"
    },
    var.labels,
  )
}

# Workload Identity Pool for GitHub Actions
resource "google_iam_workload_identity_pool" "github_actions" {
  project                   = var.project_id
  workload_identity_pool_id = "${var.project}-github-actions"
  display_name              = "GitHub Actions"
  description               = "Workload Identity Pool for GitHub Actions CI/CD."
}

# Workload Identity Pool Provider (OIDC)
resource "google_iam_workload_identity_pool_provider" "github_actions" {
  project                            = var.project_id
  workload_identity_pool_id          = google_iam_workload_identity_pool.github_actions.workload_identity_pool_id
  workload_identity_pool_provider_id = "github-oidc"
  display_name                       = "GitHub OIDC"
  description                        = "GitHub Actions OIDC provider."

  attribute_mapping = {
    "google.subject"       = "assertion.sub"
    "attribute.actor"      = "assertion.actor"
    "attribute.repository" = "assertion.repository"
    "attribute.ref"        = "assertion.ref"
    "attribute.event_name" = "assertion.event_name"
  }

  attribute_condition = "assertion.repository == '${var.github_org}/${var.github_repo}'"

  oidc {
    issuer_uri = "https://token.actions.githubusercontent.com"
  }
}

# Plan service account -- read-only, used during pull requests
resource "google_service_account" "github_actions_plan" {
  project      = var.project_id
  account_id   = "${var.project}-gh-plan"
  display_name = "GitHub Actions Plan"
  description  = "Service account for GitHub Actions terraform plan (read-only)."
}

# Allow GitHub Actions (pull_request events) to impersonate the plan SA
resource "google_service_account_iam_member" "plan_workload_identity" {
  service_account_id = google_service_account.github_actions_plan.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_actions.name}/attribute.event_name/pull_request"
}

# Plan SA gets Viewer role on the project
resource "google_project_iam_member" "plan_viewer" {
  project = var.project_id
  role    = "roles/viewer"
  member  = "serviceAccount:${google_service_account.github_actions_plan.email}"
}

# Plan SA needs storage access for state buckets
resource "google_storage_bucket_iam_member" "plan_state_access" {
  for_each = var.state_bucket_names

  bucket = each.value
  role   = "roles/storage.objectViewer"
  member = "serviceAccount:${google_service_account.github_actions_plan.email}"
}

# Apply service account -- used on merge to main
resource "google_service_account" "github_actions_apply" {
  project      = var.project_id
  account_id   = "${var.project}-gh-apply"
  display_name = "GitHub Actions Apply"
  description  = "Service account for GitHub Actions terraform apply."
}

# Allow GitHub Actions (push to main) to impersonate the apply SA
resource "google_service_account_iam_member" "apply_workload_identity" {
  service_account_id = google_service_account.github_actions_apply.name
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.github_actions.name}/attribute.ref/refs/heads/main"
}

# Apply SA gets Editor role on the project
# Editor is broad but avoids unrestricted IAM access that Owner grants.
# Scope down as the project stabilises.
resource "google_project_iam_member" "apply_editor" {
  project = var.project_id
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.github_actions_apply.email}"
}

# Terraform execution service account (for local development)
resource "google_service_account" "terraform_execution" {
  project      = var.project_id
  account_id   = "${var.project}-tf-exec"
  display_name = "Terraform Execution"
  description  = "Service account for local Terraform execution with broad permissions."
}

resource "google_project_iam_member" "execution_editor" {
  project = var.project_id
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.terraform_execution.email}"
}
