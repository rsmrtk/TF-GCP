resource "google_secret_manager_secret" "db_credentials" {
  secret_id = "${local.name_prefix}-db-credentials"
  project   = var.project_id

  replication {
    auto {}
  }

  labels = merge(local.common_labels, var.labels)
}

resource "google_secret_manager_secret_version" "db_credentials" {
  secret = google_secret_manager_secret.db_credentials.id

  secret_data = jsonencode({
    username        = google_sql_user.this.name
    password        = random_password.db_password.result
    database        = var.database_name
    host            = google_sql_database_instance.this.private_ip_address
    port            = 5432
    connection_name = google_sql_database_instance.this.connection_name
  })
}
