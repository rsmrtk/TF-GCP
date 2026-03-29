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
  description = "GCP region for the Cloud SQL instance."
  type        = string
}

variable "vpc_self_link" {
  description = "Self link of the VPC network for private IP connectivity."
  type        = string
}

variable "database_version" {
  description = "The database engine and version (e.g., POSTGRES_16, MYSQL_8_0)."
  type        = string
  default     = "POSTGRES_16"
}

variable "tier" {
  description = "The machine type tier for the Cloud SQL instance (e.g., db-f1-micro, db-custom-2-8192)."
  type        = string
  default     = "db-f1-micro"
}

variable "disk_size" {
  description = "Initial disk size in GB."
  type        = number
  default     = 20
}

variable "disk_autoresize" {
  description = "Whether to enable automatic disk size increase."
  type        = bool
  default     = true
}

variable "disk_autoresize_limit" {
  description = "Maximum disk size in GB for auto-resize. Set to 0 for unlimited."
  type        = number
  default     = 100
}

variable "database_name" {
  description = "Name of the default database to create."
  type        = string
  default     = "app"
}

variable "availability_type" {
  description = "Availability type: ZONAL for single zone, REGIONAL for high availability (multi-AZ)."
  type        = string
  default     = "ZONAL"

  validation {
    condition     = contains(["ZONAL", "REGIONAL"], var.availability_type)
    error_message = "Availability type must be either ZONAL or REGIONAL."
  }
}

variable "backup_enabled" {
  description = "Whether automated backups are enabled."
  type        = bool
  default     = true
}

variable "backup_start_time" {
  description = "HH:MM time indicating when the backup should start (UTC)."
  type        = string
  default     = "03:00"
}

variable "backup_transaction_log_retention_days" {
  description = "Number of days to retain transaction logs for point-in-time recovery."
  type        = number
  default     = 7
}

variable "backup_retained_backups" {
  description = "Number of automated backups to retain."
  type        = number
  default     = 7
}

variable "deletion_protection" {
  description = "Whether deletion protection is enabled on the instance."
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "Cloud KMS key ID for CMEK encryption. Leave empty to use Google-managed encryption."
  type        = string
  default     = ""
}

variable "enable_insights" {
  description = "Whether to enable Query Insights (equivalent to Performance Insights)."
  type        = bool
  default     = true
}

variable "database_flags" {
  description = "List of database flags to set on the instance."
  type = list(object({
    name  = string
    value = string
  }))
  default = []
}

variable "labels" {
  description = "Additional labels to apply to all resources."
  type        = map(string)
  default     = {}
}
