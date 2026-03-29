# -----------------------------------------------------------------------------
# Cloud KMS Outputs
# -----------------------------------------------------------------------------

output "kms_key_ring_id" {
  description = "The ID of the Cloud KMS key ring."
  value       = google_kms_key_ring.this.id
}

output "kms_key_id" {
  description = "The ID of the Cloud KMS crypto key. Use this for CMEK integration with GCP services."
  value       = google_kms_crypto_key.this.id
}

output "kms_key_name" {
  description = "The resource name of the Cloud KMS crypto key."
  value       = google_kms_crypto_key.this.name
}

# -----------------------------------------------------------------------------
# Cloud Armor Outputs
# -----------------------------------------------------------------------------

output "cloud_armor_policy_id" {
  description = "The ID of the Cloud Armor security policy. Null if Cloud Armor is disabled."
  value       = var.enable_cloud_armor ? google_compute_security_policy.this[0].id : null
}

output "cloud_armor_policy_self_link" {
  description = "The self_link of the Cloud Armor security policy. Null if Cloud Armor is disabled."
  value       = var.enable_cloud_armor ? google_compute_security_policy.this[0].self_link : null
}

# -----------------------------------------------------------------------------
# SSL Certificate Outputs
# -----------------------------------------------------------------------------

output "ssl_certificate_id" {
  description = "The ID of the Google-managed SSL certificate. Null if no domains are specified."
  value       = length(var.ssl_domains) > 0 ? google_compute_managed_ssl_certificate.this[0].id : null
}

output "ssl_certificate_self_link" {
  description = "The self_link of the Google-managed SSL certificate. Null if no domains are specified."
  value       = length(var.ssl_domains) > 0 ? google_compute_managed_ssl_certificate.this[0].self_link : null
}

# -----------------------------------------------------------------------------
# Firewall Tag Outputs
# -----------------------------------------------------------------------------
# These tags should be applied to compute instances to associate them with
# the corresponding firewall rules. This is the GCP equivalent of placing
# an instance in an AWS security group.
# -----------------------------------------------------------------------------

output "lb_firewall_tag" {
  description = "The network tag to apply to instances that should receive HTTP/HTTPS traffic from the internet."
  value       = local.lb_firewall_tag
}

output "health_check_firewall_tag" {
  description = "The network tag to apply to instances that should receive Google Cloud health check probes."
  value       = local.health_check_firewall_tag
}

output "app_firewall_tag" {
  description = "The network tag to apply to application instances for internal communication."
  value       = local.app_firewall_tag
}

output "db_firewall_tag" {
  description = "The network tag to apply to database instances to allow application access on port 5432."
  value       = local.db_firewall_tag
}
