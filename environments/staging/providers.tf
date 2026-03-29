provider "google" {
  project = var.project_id
  region  = var.gcp_region

  default_labels = {
    project     = var.project
    environment = var.environment
    managed_by  = "terraform"
    repository  = "rsmrtk-tf-gcp"
  }
}
