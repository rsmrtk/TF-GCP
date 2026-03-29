################################################################################
# VPC Network
################################################################################

output "vpc_id" {
  description = "The ID of the VPC network."
  value       = google_compute_network.this.id
}

output "vpc_name" {
  description = "The name of the VPC network."
  value       = google_compute_network.this.name
}

output "vpc_self_link" {
  description = "The self link of the VPC network."
  value       = google_compute_network.this.self_link
}

################################################################################
# Public Subnets
################################################################################

output "public_subnet_ids" {
  description = "List of IDs of the public subnetworks."
  value       = google_compute_subnetwork.public[*].id
}

output "public_subnet_self_links" {
  description = "List of self links of the public subnetworks."
  value       = google_compute_subnetwork.public[*].self_link
}

################################################################################
# Private Subnets
################################################################################

output "private_subnet_ids" {
  description = "List of IDs of the private subnetworks."
  value       = google_compute_subnetwork.private[*].id
}

output "private_subnet_self_links" {
  description = "List of self links of the private subnetworks."
  value       = google_compute_subnetwork.private[*].self_link
}

################################################################################
# Data Subnets
################################################################################

output "data_subnet_ids" {
  description = "List of IDs of the data subnetworks."
  value       = google_compute_subnetwork.data[*].id
}

output "data_subnet_self_links" {
  description = "List of self links of the data subnetworks."
  value       = google_compute_subnetwork.data[*].self_link
}

################################################################################
# Cloud Router and Cloud NAT
################################################################################

output "router_name" {
  description = "The name of the Cloud Router."
  value       = google_compute_router.this.name
}

output "nat_name" {
  description = "The name of the Cloud NAT."
  value       = google_compute_router_nat.this.name
}
