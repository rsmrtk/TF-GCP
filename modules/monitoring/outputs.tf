################################################################################
# Notification Channels
################################################################################

output "notification_channel_ids" {
  description = "List of notification channel IDs created for email endpoints."
  value       = google_monitoring_notification_channel.email[*].id
}

################################################################################
# Alert Policies
################################################################################

output "alert_policy_ids" {
  description = "Map of alert policy keys to their resource IDs."
  value = {
    for key, policy in google_monitoring_alert_policy.this : key => policy.id
  }
}

################################################################################
# Dashboard
################################################################################

output "dashboard_id" {
  description = "The ID of the monitoring dashboard. Empty if no widgets are configured."
  value       = length(var.dashboard_widgets) > 0 ? google_monitoring_dashboard.this[0].id : ""
}
