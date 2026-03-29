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
# Zone Configuration
# -----------------------------------------------------------------------------

variable "create_zone" {
  description = "Whether to create a new Cloud DNS managed zone. If false, zone_id must reference an existing zone."
  type        = bool
  default     = false
}

variable "zone_name" {
  description = "The DNS domain name for the managed zone (e.g., 'example.com.'). Must end with a trailing dot."
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]*\\.$", var.zone_name))
    error_message = "Zone name must be a valid DNS domain ending with a trailing dot (e.g., 'example.com.')."
  }
}

variable "zone_id" {
  description = "The name of an existing Cloud DNS managed zone. Required when create_zone is false."
  type        = string
  default     = ""
}

# -----------------------------------------------------------------------------
# DNS Records
# -----------------------------------------------------------------------------

variable "records" {
  description = "Map of DNS record sets to create. Each key is used as the record name relative to the zone."
  type = map(object({
    type    = string
    ttl     = optional(number, 300)
    rrdatas = list(string)
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.records : contains(
        ["A", "AAAA", "CNAME", "MX", "TXT", "SRV", "NS", "PTR", "CAA", "SOA"],
        v.type,
      )
    ])
    error_message = "Record type must be one of: A, AAAA, CNAME, MX, TXT, SRV, NS, PTR, CAA, SOA."
  }
}

# -----------------------------------------------------------------------------
# Labels
# -----------------------------------------------------------------------------

variable "labels" {
  description = "A map of labels to apply to all resources created by this module."
  type        = map(string)
  default     = {}
}
