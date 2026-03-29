# Networking

output "vpc_id" {
  description = "The ID of the VPC."
  value       = module.networking.vpc_id
}

output "vpc_self_link" {
  description = "The self link of the VPC."
  value       = module.networking.vpc_self_link
}

output "public_subnet_ids" {
  description = "List of public subnet IDs."
  value       = module.networking.public_subnet_ids
}

output "private_subnet_ids" {
  description = "List of private subnet IDs."
  value       = module.networking.private_subnet_ids
}

output "data_subnet_ids" {
  description = "List of data subnet IDs."
  value       = module.networking.data_subnet_ids
}

# Security

output "kms_key_id" {
  description = "ID of the Cloud KMS key."
  value       = module.security.kms_key_id
}

output "cloud_armor_policy_id" {
  description = "ID of the Cloud Armor security policy."
  value       = module.security.cloud_armor_policy_id
}

# IAM

output "compute_sa_email" {
  description = "Email of the Compute Engine service account."
  value       = module.iam.compute_sa_email
}

output "cloud_run_sa_email" {
  description = "Email of the Cloud Run service account."
  value       = module.iam.cloud_run_sa_email
}

# GCS

output "gcs_bucket_names" {
  description = "Map of GCS bucket names."
  value       = module.gcs.bucket_names
}

# Artifact Registry

output "artifact_registry_urls" {
  description = "Map of Artifact Registry repository URLs."
  value       = module.artifact_registry.repository_urls
}

# Compute

output "lb_ip_address" {
  description = "IP address of the load balancer."
  value       = module.compute.lb_ip_address
}

output "mig_name" {
  description = "Name of the managed instance group."
  value       = module.compute.mig_name
}

# GKE

output "gke_cluster_name" {
  description = "Name of the GKE cluster."
  value       = module.gke.cluster_name
}

output "gke_cluster_endpoint" {
  description = "Endpoint of the GKE cluster."
  value       = module.gke.cluster_endpoint
}

# Cloud SQL

output "cloud_sql_connection_name" {
  description = "Connection name of the Cloud SQL instance."
  value       = module.cloud_sql.instance_connection_name
}

output "cloud_sql_private_ip" {
  description = "Private IP of the Cloud SQL instance."
  value       = module.cloud_sql.private_ip_address
}

output "cloud_sql_secret_id" {
  description = "Secret Manager secret ID for database credentials."
  value       = module.cloud_sql.db_secret_id
}

# Monitoring

output "notification_channel_ids" {
  description = "Monitoring notification channel IDs."
  value       = module.monitoring.notification_channel_ids
}
