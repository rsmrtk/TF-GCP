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
  description = "GCP region for the GKE cluster."
  type        = string
}

variable "vpc_self_link" {
  description = "Self link of the VPC network."
  type        = string
}

variable "private_subnet_self_links" {
  description = "List of self links for private subnets. The first subnet is used for GKE nodes."
  type        = list(string)

  validation {
    condition     = length(var.private_subnet_self_links) > 0
    error_message = "At least one private subnet self link must be provided."
  }
}

variable "pods_secondary_range_name" {
  description = "Name of the secondary IP range for pods."
  type        = string
}

variable "services_secondary_range_name" {
  description = "Name of the secondary IP range for services."
  type        = string
}

variable "kms_key_id" {
  description = "Cloud KMS key self link for application-layer secrets encryption. If empty, Google-managed encryption is used."
  type        = string
  default     = ""
}

variable "cluster_version" {
  description = "Minimum Kubernetes version for the GKE cluster. The actual version may be higher based on the release channel."
  type        = string
  default     = "1.30"
}

variable "node_pools" {
  description = "Map of node pool configurations. The key is used as the node pool name suffix."
  type = map(object({
    machine_type  = optional(string, "e2-standard-2")
    min_count     = optional(number, 1)
    max_count     = optional(number, 3)
    initial_count = optional(number, 1)
    disk_size_gb  = optional(number, 50)
    disk_type     = optional(string, "pd-balanced")
    preemptible   = optional(bool, false)
    spot          = optional(bool, false)
  }))
  default = {}
}

variable "enable_private_nodes" {
  description = "Whether nodes have internal IP addresses only."
  type        = bool
  default     = true
}

variable "enable_private_endpoint" {
  description = "Whether the cluster master is accessible only from internal IP addresses (equivalent to cluster_endpoint_private_access)."
  type        = bool
  default     = false
}

variable "master_authorized_networks" {
  description = "List of CIDR blocks authorized to access the cluster master endpoint."
  type = list(object({
    cidr_block   = string
    display_name = string
  }))
  default = []
}

variable "labels" {
  description = "Additional labels to apply to all resources."
  type        = map(string)
  default     = {}
}
