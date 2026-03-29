variable "project" {
  description = "Project name used for resource naming."
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,28}[a-z0-9]$", var.project))
    error_message = "Project name must be 3-30 characters, start with a letter, end with a letter or digit, and contain only lowercase letters, digits, and hyphens."
  }
}

variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)."
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
  description = "GCP region for resource deployment."
  type        = string
}

variable "private_subnet_self_links" {
  description = "List of self links for private subnets."
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_self_links) > 0
    error_message = "At least one private subnet self link must be provided."
  }
}

variable "lb_firewall_tag" {
  description = "Network tag applied to instances for load balancer firewall rules."
  type        = string
}

variable "app_firewall_tag" {
  description = "Network tag applied to instances for application firewall rules."
  type        = string
}

variable "machine_type" {
  description = "GCP Compute Engine machine type for instances."
  type        = string
  default     = "e2-micro"
}

variable "service_account_email" {
  description = "Service account email to attach to compute instances."
  type        = string
}

variable "min_size" {
  description = "Minimum number of instances in the managed instance group."
  type        = number
  default     = 1

  validation {
    condition     = var.min_size >= 0
    error_message = "Minimum size must be non-negative."
  }
}

variable "max_size" {
  description = "Maximum number of instances in the managed instance group."
  type        = number
  default     = 2

  validation {
    condition     = var.max_size >= 1
    error_message = "Maximum size must be at least 1."
  }
}

variable "desired_size" {
  description = "Desired number of instances in the managed instance group (target_size). Ignored after initial creation due to autoscaler management."
  type        = number
  default     = 1

  validation {
    condition     = var.desired_size >= 0
    error_message = "Desired size must be non-negative."
  }
}

variable "kms_key_id" {
  description = "Cloud KMS key self link for disk encryption. If empty, Google-managed encryption is used."
  type        = string
  default     = ""
}

variable "certificate_id" {
  description = "SSL certificate resource ID for HTTPS load balancer. If empty, only HTTP forwarding is created."
  type        = string
  default     = ""
}

variable "labels" {
  description = "Additional labels to apply to all resources."
  type        = map(string)
  default     = {}
}
