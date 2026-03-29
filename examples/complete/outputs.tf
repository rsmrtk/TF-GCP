output "vpc_id" {
  description = "ID of the VPC created by the networking module."
  value       = module.networking.vpc_id
}

output "cloud_sql_connection_name" {
  description = "Connection name for the Cloud SQL instance."
  value       = module.cloud_sql.instance_connection_name
}
