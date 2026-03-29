output "instance_name" {
  description = "The name of the Cloud SQL instance."
  value       = google_sql_database_instance.this.name
}

output "instance_connection_name" {
  description = "The connection name of the instance for Cloud SQL Proxy."
  value       = google_sql_database_instance.this.connection_name
}

output "private_ip_address" {
  description = "The private IP address of the Cloud SQL instance."
  value       = google_sql_database_instance.this.private_ip_address
}

output "database_name" {
  description = "The name of the default database."
  value       = google_sql_database.this.name
}

output "db_secret_id" {
  description = "The Secret Manager secret ID containing database credentials."
  value       = google_secret_manager_secret.db_credentials.secret_id
}

output "instance_self_link" {
  description = "The self link of the Cloud SQL instance."
  value       = google_sql_database_instance.this.self_link
}
