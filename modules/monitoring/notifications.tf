################################################################################
# Email Notification Channels
#
# Creates an email notification channel for each address in
# alarm_email_endpoints. These channels are referenced by alert policies
# to deliver alert notifications.
################################################################################

resource "google_monitoring_notification_channel" "email" {
  count = length(var.alarm_email_endpoints)

  project      = var.project_id
  display_name = "${local.name_prefix}-email-${count.index}"
  type         = "email"

  labels = {
    email_address = var.alarm_email_endpoints[count.index]
  }

  user_labels = merge(
    local.common_labels,
    var.labels,
    {
      environment = var.environment
    },
  )

  force_delete = false
}
