# -----------------------------------------------------------------------------
# Required Variables
# -----------------------------------------------------------------------------

variable "project" {
  description = "The project name used for resource naming."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,28}[a-z0-9]$", var.project))
    error_message = "Project name must be 3-30 characters, start with a letter, end with a letter or digit, and contain only lowercase letters, digits, and hyphens."
  }
}

variable "environment" {
  description = "The deployment environment (e.g., dev, staging, prod)."
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
}

variable "service_account_email" {
  description = "The service account email to use for Cloud Functions execution."
  type        = string
}

# -----------------------------------------------------------------------------
# Optional Variables
# -----------------------------------------------------------------------------

variable "kms_key_id" {
  description = "The Cloud KMS CryptoKey resource name for CMEK encryption. Leave empty to use Google-managed encryption."
  type        = string
  default     = ""
}

variable "functions" {
  description = "Map of Cloud Functions v2 configurations. Each key becomes part of the function name."
  type = map(object({
    description      = optional(string, "")
    runtime          = string                             # e.g. "python312", "nodejs20", "go122"
    entry_point      = string                             # function name
    source_bucket    = string                             # GCS bucket with source archive
    source_object    = string                             # GCS object path
    memory_mb        = optional(number, 256)
    timeout_seconds  = optional(number, 60)
    min_instances    = optional(number, 0)
    max_instances    = optional(number, 100)
    env_vars         = optional(map(string), {})
    vpc_connector    = optional(string, "")
    ingress_settings = optional(string, "ALLOW_INTERNAL_ONLY")
  }))
  default = {}
}

variable "enable_api_gateway" {
  description = "Whether to enable API Gateway integration for the Cloud Functions."
  type        = bool
  default     = false
}

variable "labels" {
  description = "A map of labels to apply to all resources created by this module."
  type        = map(string)
  default     = {}
}
