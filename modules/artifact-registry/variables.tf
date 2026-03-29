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
  description = "The Cloud KMS CryptoKey resource name for CMEK encryption of repository artifacts. Leave empty to use Google-managed encryption."
  type        = string
  default     = ""
}

variable "repositories" {
  description = "Map of Artifact Registry repository configurations."
  type = map(object({
    format         = optional(string, "DOCKER")
    description    = optional(string, "")
    immutable_tags = optional(bool, false)
    cleanup_keep   = optional(number, 10)
  }))
  default = {}
}

variable "labels" {
  description = "A map of labels to apply to all resources created by this module."
  type        = map(string)
  default     = {}
}
