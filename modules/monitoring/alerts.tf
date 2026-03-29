################################################################################
# Alert Policies
#
# Creates a Cloud Monitoring alert policy for each entry in alert_policies.
# Each policy monitors a specific metric and triggers notifications through
# the configured email channels when conditions are met.
################################################################################

resource "google_monitoring_alert_policy" "this" {
  for_each = var.alert_policies

  project      = var.project_id
  display_name = "${local.name_prefix}-${each.key}"
  combiner     = "OR"
  enabled      = true

  conditions {
    display_name = each.value.description != "" ? each.value.description : each.key

    condition_threshold {
      filter          = "metric.type=\"${each.value.metric_type}\" AND resource.type!=\"\" ${each.value.filter_extra}"
      comparison      = each.value.comparison
      threshold_value = each.value.threshold_value
      duration        = each.value.duration

      aggregations {
        alignment_period   = each.value.alignment_period
        per_series_aligner = each.value.per_series_aligner
      }

      trigger {
        count = 1
      }
    }
  }

  notification_channels = [
    for ch in google_monitoring_notification_channel.email : ch.id
  ]

  documentation {
    content   = "Alert: ${each.key} - ${each.value.description != "" ? each.value.description : "Threshold exceeded for ${each.value.metric_type}"}\n\nEnvironment: ${var.environment}\nProject: ${var.project}"
    mime_type = "text/markdown"
  }

  alert_strategy {
    auto_close = "1800s"

    notification_rate_limit {
      period = "300s"
    }
  }

  user_labels = merge(
    local.common_labels,
    var.labels,
    {
      environment = var.environment
      alert       = each.key
    },
  )
}
