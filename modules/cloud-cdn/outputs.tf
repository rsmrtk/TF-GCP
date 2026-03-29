################################################################################
# Load Balancer
################################################################################

output "lb_ip_address" {
  description = "The external IP address of the CDN load balancer."
  value       = google_compute_global_address.this.address
}

output "cdn_url" {
  description = "The HTTP URL of the CDN endpoint."
  value       = var.ssl_certificate_id != "" ? "https://${var.custom_domain != "" ? var.custom_domain : google_compute_global_address.this.address}" : "http://${google_compute_global_address.this.address}"
}

################################################################################
# Backend
################################################################################

output "backend_bucket_id" {
  description = "The ID of the backend bucket (empty if origin_type is not 'gcs')."
  value       = var.origin_type == "gcs" ? google_compute_backend_bucket.this[0].id : ""
}

output "backend_service_id" {
  description = "The ID of the backend service (empty if origin_type is not 'backend_service')."
  value       = var.origin_type == "backend_service" ? google_compute_backend_service.this[0].id : ""
}

################################################################################
# URL Map
################################################################################

output "url_map_id" {
  description = "The ID of the URL map."
  value       = google_compute_url_map.this.id
}
