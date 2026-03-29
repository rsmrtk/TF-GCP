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

variable "vpc_cidr" {
  description = "The base CIDR block for the VPC, used to calculate subnet CIDRs with cidrsubnet()."
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "vpc_cidr must be a valid CIDR block (e.g., 10.0.0.0/16)."
  }
}

variable "azs" {
  description = "List of GCP availability zones for subnet deployment (e.g., [\"europe-west1-b\", \"europe-west1-c\", \"europe-west1-d\"])."
  type        = list(string)

  validation {
    condition     = length(var.azs) > 0
    error_message = "At least one availability zone must be specified."
  }
}

variable "single_nat_gateway" {
  description = "Whether to provision a single Cloud NAT for all subnets (true) or NAT only private subnets (false). GCP Cloud NAT is regional regardless."
  type        = bool
  default     = true
}

variable "enable_flow_logs" {
  description = "Whether to enable VPC flow logs on all subnetworks."
  type        = bool
  default     = true
}

variable "flow_log_sampling_rate" {
  description = "The sampling rate for VPC flow logs. Value must be between 0.0 (no sampling) and 1.0 (all logs)."
  type        = number
  default     = 0.5

  validation {
    condition     = var.flow_log_sampling_rate >= 0 && var.flow_log_sampling_rate <= 1
    error_message = "flow_log_sampling_rate must be between 0.0 and 1.0."
  }
}

variable "enable_private_google_access" {
  description = "Whether to enable Private Google Access on subnetworks, allowing VMs without external IPs to reach Google APIs."
  type        = bool
  default     = true
}

