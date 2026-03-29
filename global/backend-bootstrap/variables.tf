variable "project" {
  description = "Short project name used as a prefix for resource naming."
  type        = string
  default     = "tfgcp"

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,28}[a-z0-9]$", var.project))
    error_message = "Project name must be 3-30 characters, start with a letter, end with a letter or digit, and contain only lowercase letters, digits, and hyphens."
  }
}

variable "project_id" {
  description = "GCP project ID where resources will be created."
  type        = string
}

variable "gcp_region" {
  description = "GCP region for the state buckets."
  type        = string
  default     = "europe-west1"

  validation {
    condition     = can(regex("^[a-z]+-[a-z]+[0-9]$", var.gcp_region))
    error_message = "Must be a valid GCP region (e.g. europe-west1, us-central1)."
  }
}

variable "environments" {
  description = "List of environment names; one state bucket is created per environment."
  type        = list(string)
  default     = ["dev", "staging", "prod"]

  validation {
    condition     = length(var.environments) > 0
    error_message = "At least one environment must be specified."
  }
}

variable "labels" {
  description = "Additional labels to apply to all resources."
  type        = map(string)
  default     = {}
}
