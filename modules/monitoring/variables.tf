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
# Notification Configuration
# -----------------------------------------------------------------------------

variable "alarm_email_endpoints" {
  description = "List of email addresses to receive alert notifications."
  type        = list(string)
  default     = []

  validation {
    condition = alltrue([
      for email in var.alarm_email_endpoints : can(regex("^[^@]+@[^@]+\\.[^@]+$", email))
    ])
    error_message = "Each email endpoint must be a valid email address."
  }
}

# -----------------------------------------------------------------------------
# Alert Policies
# -----------------------------------------------------------------------------

variable "alert_policies" {
  description = "Map of alert policy configurations. Each key becomes part of the alert policy display name."
  type = map(object({
    description        = optional(string, "")
    metric_type        = string          # e.g. "compute.googleapis.com/instance/cpu/utilization"
    comparison         = string          # COMPARISON_GT, COMPARISON_LT, etc.
    threshold_value    = number
    duration           = optional(string, "300s")
    alignment_period   = optional(string, "300s")
    per_series_aligner = optional(string, "ALIGN_MEAN")
    filter_extra       = optional(string, "")
  }))
  default = {}

  validation {
    condition = alltrue([
      for k, v in var.alert_policies : contains(
        ["COMPARISON_GT", "COMPARISON_GE", "COMPARISON_LT", "COMPARISON_LE", "COMPARISON_EQ", "COMPARISON_NE"],
        v.comparison,
      )
    ])
    error_message = "Comparison must be one of: COMPARISON_GT, COMPARISON_GE, COMPARISON_LT, COMPARISON_LE, COMPARISON_EQ, COMPARISON_NE."
  }
}

# -----------------------------------------------------------------------------
# Dashboard Configuration
# -----------------------------------------------------------------------------

variable "dashboard_widgets" {
  description = "List of widget configurations for the monitoring dashboard. Each widget defines a chart or text panel."
  type = list(object({
    title       = string
    metric_type = optional(string, "")
    widget_type = optional(string, "xy_chart")   # xy_chart, scorecard, text
    text        = optional(string, "")
  }))
  default = []
}

# -----------------------------------------------------------------------------
# Labels
# -----------------------------------------------------------------------------

variable "labels" {
  description = "A map of labels to apply to all resources created by this module."
  type        = map(string)
  default     = {}
}
