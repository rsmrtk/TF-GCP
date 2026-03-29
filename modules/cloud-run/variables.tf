variable "project" {
  description = "Project name used for resource naming."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,28}[a-z0-9]$", var.project))
    error_message = "Project name must be 3-30 characters, start with a letter, end with a letter or digit, and contain only lowercase letters, digits, and hyphens."
  }
}

variable "environment" {
  description = "Deployment environment."
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "project_id" {
  description = "GCP project ID where resources will be created."
  type        = string
}

variable "region" {
  description = "GCP region for Cloud Run services."
  type        = string
}

variable "service_account_email" {
  description = "Service account email for Cloud Run services."
  type        = string
}

variable "vpc_connector_id" {
  description = "VPC Access connector ID for private VPC egress. Leave empty to disable."
  type        = string
  default     = ""
}

variable "kms_key_id" {
  description = "Cloud KMS key ID for CMEK encryption. Leave empty to use Google-managed encryption."
  type        = string
  default     = ""
}

variable "services" {
  description = "Map of Cloud Run service configurations."
  type = map(object({
    image                = string
    port                 = optional(number, 8080)
    cpu                  = optional(string, "1")
    memory               = optional(string, "512Mi")
    min_instances        = optional(number, 0)
    max_instances        = optional(number, 10)
    timeout_seconds      = optional(number, 300)
    concurrency          = optional(number, 80)
    env_vars             = optional(map(string), {})
    secret_env_vars      = optional(map(string), {}) # name -> secret_id
    cloudsql_connections = optional(list(string), [])
    ingress              = optional(string, "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER")
  }))
  default = {}
}

variable "labels" {
  description = "Additional labels to apply to all resources."
  type        = map(string)
  default     = {}
}
