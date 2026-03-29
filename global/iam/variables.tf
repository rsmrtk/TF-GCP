variable "project" {
  description = "Short project name used for resource naming."
  type        = string
  default     = "tfgcp"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,28}[a-z0-9]$", var.project))
    error_message = "Project must be 3-30 characters, start with a letter, end with a letter or digit, and contain only lowercase letters, digits, and hyphens."
  }
}

variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "gcp_region" {
  description = "Default GCP region."
  type        = string
  default     = "europe-west1"
}

variable "github_org" {
  description = "GitHub organisation or user that owns the repository."
  type        = string
  default     = "rsmrtk"
}

variable "github_repo" {
  description = "GitHub repository name."
  type        = string
  default     = "TF-GCP"
}

variable "state_bucket_names" {
  description = "Map of logical name to GCS bucket name for Terraform state. The plan SA receives objectViewer on each bucket."
  type        = map(string)
  default     = {}
}

variable "labels" {
  description = "Additional labels to apply to all resources that support them."
  type        = map(string)
  default     = {}
}
