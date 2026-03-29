resource "google_storage_bucket" "this" {
  for_each = var.buckets

  name     = "${local.name_prefix}-${each.key}"
  project  = var.project_id
  location = var.region

  storage_class               = each.value.storage_class
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  force_destroy = false

  versioning {
    enabled = each.value.versioning
  }

  dynamic "lifecycle_rule" {
    for_each = [
      for rule in each.value.lifecycle_rules : rule
      if rule.enabled && rule.transition_days != null
    ]

    content {
      action {
        type          = "SetStorageClass"
        storage_class = lifecycle_rule.value.transition_storage_class
      }

      condition {
        age = lifecycle_rule.value.transition_days
      }
    }
  }

  dynamic "lifecycle_rule" {
    for_each = [
      for rule in each.value.lifecycle_rules : rule
      if rule.enabled && rule.expiration_days != null
    ]

    content {
      action {
        type = "Delete"
      }

      condition {
        age = lifecycle_rule.value.expiration_days
      }
    }
  }

  dynamic "lifecycle_rule" {
    for_each = [
      for rule in each.value.lifecycle_rules : rule
      if rule.enabled && rule.noncurrent_version_expiration_days != null
    ]

    content {
      action {
        type = "Delete"
      }

      condition {
        days_since_noncurrent_time = lifecycle_rule.value.noncurrent_version_expiration_days
        with_state                 = "ARCHIVED"
      }
    }
  }

  dynamic "encryption" {
    for_each = var.kms_key_id != "" ? [1] : []

    content {
      default_kms_key_name = var.kms_key_id
    }
  }

  labels = merge(
    local.common_labels,
    var.labels,
    {
      environment = var.environment
      bucket      = each.key
      purpose     = each.value.purpose != "" ? each.value.purpose : each.key
    },
  )
}
