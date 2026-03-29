output "lb_ip_address" {
  description = "External IP address of the load balancer."
  value       = google_compute_global_address.this.address
}

output "lb_url" {
  description = "URL of the load balancer (HTTP)."
  value       = "http://${google_compute_global_address.this.address}"
}

output "mig_name" {
  description = "Name of the managed instance group."
  value       = google_compute_region_instance_group_manager.this.name
}

output "mig_self_link" {
  description = "Self link of the managed instance group."
  value       = google_compute_region_instance_group_manager.this.self_link
}

output "instance_template_name" {
  description = "Name of the instance template."
  value       = google_compute_instance_template.this.name
}

output "health_check_id" {
  description = "ID of the health check."
  value       = google_compute_health_check.this.id
}
