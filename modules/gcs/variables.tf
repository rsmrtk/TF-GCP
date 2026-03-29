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

variable "region" {
  description = "The GCP region for resource deployment."
  type        = string
  default     = "europe-west1"
}

variable "kms_key_id" {
  description = "The Cloud KMS CryptoKey resource name for CMEK encryption of bucket objects. Leave empty to use Google-managed encryption."
  type        = string
  default     = ""
}

variable "buckets" {
  description = "Map of GCS bucket configurations."
  type = map(object({
    purpose       = optional(string, "")
    versioning    = optional(bool, false)
    storage_class = optional(string, "STANDARD")
    lifecycle_rules = optional(list(object({
      id                                 = string
      enabled                            = optional(bool, true)
      transition_days                    = optional(number, null)
      transition_storage_class           = optional(string, "NEARLINE")
      expiration_days                    = optional(number, null)
      noncurrent_version_expiration_days = optional(number, null)
    })), [])
  }))
  default = {}
}

variable "labels" {
  description = "A map of labels to apply to all resources created by this module."
  type        = map(string)
  default     = {}
}
