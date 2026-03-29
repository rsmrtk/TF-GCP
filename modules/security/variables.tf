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

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{4,28}[a-z0-9]$", var.project_id))
    error_message = "GCP project ID must be 6-30 characters, start with a letter, end with a letter or digit, and contain only lowercase letters, digits, and hyphens."
  }
}

# -----------------------------------------------------------------------------
# Optional Variables
# -----------------------------------------------------------------------------

variable "region" {
  description = "The GCP region for regional resources (e.g., KMS keyring)."
  type        = string
  default     = "europe-west1"
}

variable "vpc_id" {
  description = "The VPC network self_link to associate firewall rules with."
  type        = string
}

variable "enable_cloud_armor" {
  description = "Whether to create a Cloud Armor security policy (equivalent to AWS WAF)."
  type        = bool
  default     = false
}

variable "cloud_armor_mode" {
  description = "Cloud Armor rule enforcement mode. Use 'preview' for logging only (equivalent to WAF count mode) or 'deny(403)' for blocking (equivalent to WAF block mode)."
  type        = string
  default     = "deny(403)"

  validation {
    condition     = contains(["preview", "deny(403)"], var.cloud_armor_mode)
    error_message = "Cloud Armor mode must be one of: preview, deny(403)."
  }
}

variable "ssl_domains" {
  description = "List of domains for Google-managed SSL certificates (equivalent to AWS ACM). Leave empty to skip certificate creation."
  type        = list(string)
  default     = []

  validation {
    condition     = alltrue([for d in var.ssl_domains : can(regex("^[a-z0-9][a-z0-9.-]*[a-z0-9]$", d))])
    error_message = "Each SSL domain must be a valid domain name."
  }
}

variable "labels" {
  description = "A map of labels to apply to all resources that support labels."
  type        = map(string)
  default     = {}
}
