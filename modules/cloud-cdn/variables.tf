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

# -----------------------------------------------------------------------------
# Origin Configuration
# -----------------------------------------------------------------------------

variable "origin_type" {
  description = "The type of origin backend: 'gcs' for a Cloud Storage bucket or 'backend_service' for a compute backend service (MIG/NEG)."
  type        = string

  validation {
    condition     = contains(["gcs", "backend_service"], var.origin_type)
    error_message = "Origin type must be one of: gcs, backend_service."
  }
}

variable "gcs_bucket_name" {
  description = "The name of the GCS bucket to use as the CDN origin. Required when origin_type is 'gcs'."
  type        = string
  default     = ""
}

# -----------------------------------------------------------------------------
# SSL and Security
# -----------------------------------------------------------------------------

variable "ssl_certificate_id" {
  description = "The self link or ID of an SSL certificate for HTTPS termination. If empty, only HTTP forwarding is created."
  type        = string
  default     = ""
}

variable "cloud_armor_policy_id" {
  description = "The self link or ID of a Cloud Armor security policy to attach to the backend. If empty, no policy is attached."
  type        = string
  default     = ""
}

# -----------------------------------------------------------------------------
# CDN Configuration
# -----------------------------------------------------------------------------

variable "enable_cdn" {
  description = "Whether to enable Cloud CDN on the backend."
  type        = bool
  default     = true
}

variable "custom_domain" {
  description = "Custom domain for the CDN endpoint. Used for documentation and output purposes."
  type        = string
  default     = ""
}

# -----------------------------------------------------------------------------
# Labels
# -----------------------------------------------------------------------------

variable "labels" {
  description = "A map of labels to apply to all resources created by this module."
  type        = map(string)
  default     = {}
}
