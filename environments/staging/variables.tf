variable "project" {
  description = "Project name."
  type        = string
  default     = "tfgcp"
}

variable "environment" {
  description = "Environment name."
  type        = string
  default     = "staging"
}

variable "project_id" {
  description = "GCP project ID."
  type        = string
}

variable "gcp_region" {
  description = "GCP region."
  type        = string
  default     = "europe-west1"
}
