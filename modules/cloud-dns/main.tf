locals {
  name_prefix = "${var.project}-${var.environment}"
  common_labels = {
    module = "cloud-dns"
  }

  # Resolve the managed zone name for record sets. When creating a new zone,
  # use the created resource name. Otherwise, use the provided zone_id.
  resolved_zone_name = var.create_zone ? google_dns_managed_zone.this[0].name : var.zone_id
}
