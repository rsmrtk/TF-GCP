################################################################################
# DNS Zone
################################################################################

output "zone_name" {
  description = "The name of the Cloud DNS managed zone."
  value       = var.create_zone ? google_dns_managed_zone.this[0].name : var.zone_id
}

output "zone_name_servers" {
  description = "The list of name servers for the managed zone. Empty if using an existing zone."
  value       = var.create_zone ? google_dns_managed_zone.this[0].name_servers : []
}

################################################################################
# DNS Records
################################################################################

output "record_names" {
  description = "Map of record keys to their fully qualified DNS names."
  value = {
    for key, record in google_dns_record_set.this : key => record.name
  }
}
