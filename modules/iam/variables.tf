variable "project" {
  description = "The project name used for resource naming."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{2,21}$", var.project))
    error_message = "Project name must be 3-22 characters, lowercase letters, numbers, and hyphens only, starting with a letter."
  }
}

variable "environment" {
  description = "The deployment environment (dev, staging, or prod)."
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "project_id" {
  description = "The GCP project ID where resources will be created."
  type        = string
}

variable "create_compute_sa" {
  description = "Whether to create a service account for Compute Engine workloads."
  type        = bool
  default     = true
}

variable "create_cloud_run_sa" {
  description = "Whether to create a service account for Cloud Run services."
  type        = bool
  default     = true
}

variable "create_cloud_functions_sa" {
  description = "Whether to create a service account for Cloud Functions."
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "The Cloud KMS key resource name for granting encrypt/decrypt permissions. Leave empty to skip KMS bindings."
  type        = string
  default     = ""
}

variable "gcs_bucket_names" {
  description = "List of GCS bucket names to grant object access to the service accounts."
  type        = list(string)
  default     = []
}

