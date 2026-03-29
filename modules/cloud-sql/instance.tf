resource "google_sql_database_instance" "this" {
  name                = "${local.name_prefix}-db"
  database_version    = var.database_version
  region              = var.region
  project             = var.project_id
  deletion_protection = var.deletion_protection

  encryption_key_name = var.kms_key_id != "" ? var.kms_key_id : null

  depends_on = [google_service_networking_connection.private_vpc]

  settings {
    tier                  = var.tier
    disk_size             = var.disk_size
    disk_autoresize       = var.disk_autoresize
    disk_autoresize_limit = var.disk_autoresize_limit
    disk_type             = "PD_SSD"
    availability_type     = var.availability_type

    ip_configuration {
      ipv4_enabled    = false
      private_network = var.vpc_self_link
    }

    backup_configuration {
      enabled                        = var.backup_enabled
      start_time                     = var.backup_start_time
      point_in_time_recovery_enabled = true
      transaction_log_retention_days = var.backup_transaction_log_retention_days
      backup_retention_settings {
        retained_backups = var.backup_retained_backups
      }
    }

    maintenance_window {
      day          = 7 # Sunday
      hour         = 4
      update_track = "stable"
    }

    insights_config {
      query_insights_enabled  = var.enable_insights
      query_plans_per_minute  = var.enable_insights ? 5 : 0
      query_string_length     = var.enable_insights ? 1024 : 0
      record_application_tags = var.enable_insights
      record_client_address   = var.enable_insights
    }

    dynamic "database_flags" {
      for_each = var.database_flags
      content {
        name  = database_flags.value.name
        value = database_flags.value.value
      }
    }

    user_labels = merge(local.common_labels, var.labels)
  }

  lifecycle {
    precondition {
      condition     = var.environment != "prod" || var.availability_type == "REGIONAL"
      error_message = "Production must use REGIONAL availability for high availability."
    }
    precondition {
      condition     = var.environment != "prod" || var.deletion_protection
      error_message = "Deletion protection must be enabled in production."
    }
  }
}

resource "google_sql_database" "this" {
  name     = var.database_name
  instance = google_sql_database_instance.this.name
  project  = var.project_id
}

resource "random_password" "db_password" {
  length           = 32
  special          = true
  override_special = "!#$%^&*()-_=+[]{}|:,.<>?"
}

resource "google_sql_user" "this" {
  name     = "dbadmin"
  instance = google_sql_database_instance.this.name
  password = random_password.db_password.result
  project  = var.project_id
}
