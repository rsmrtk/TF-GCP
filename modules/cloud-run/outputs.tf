output "service_urls" {
  description = "Map of service name to service URL."
  value = {
    for k, v in google_cloud_run_v2_service.this : k => v.uri
  }
}

output "service_names" {
  description = "Map of service key to fully qualified service name."
  value = {
    for k, v in google_cloud_run_v2_service.this : k => v.name
  }
}

output "service_ids" {
  description = "Map of service key to service ID."
  value = {
    for k, v in google_cloud_run_v2_service.this : k => v.id
  }
}
