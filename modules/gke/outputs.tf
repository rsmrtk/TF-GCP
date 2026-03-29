output "cluster_name" {
  description = "Name of the GKE cluster."
  value       = google_container_cluster.this.name
}

output "cluster_endpoint" {
  description = "Endpoint for the GKE cluster master."
  value       = google_container_cluster.this.endpoint
  sensitive   = true
}

output "cluster_ca_certificate" {
  description = "Base64-encoded public certificate authority of the GKE cluster."
  value       = google_container_cluster.this.master_auth[0].cluster_ca_certificate
  sensitive   = true
}

output "cluster_version" {
  description = "Actual Kubernetes version running on the GKE cluster master."
  value       = google_container_cluster.this.master_version
}

output "cluster_id" {
  description = "Unique identifier of the GKE cluster."
  value       = google_container_cluster.this.id
}

output "workload_identity_pool" {
  description = "Workload Identity pool for the cluster, used to bind Kubernetes service accounts to GCP service accounts."
  value       = local.workload_identity_pool
}
