################################################################################
# Cloud DNS Managed Zone
#
# Creates a public DNS managed zone when create_zone is true. If using an
# existing zone, set create_zone to false and provide the zone name via
# zone_id variable.
################################################################################

resource "google_dns_managed_zone" "this" {
  count = var.create_zone ? 1 : 0

  name        = "${local.name_prefix}-${replace(trimsuffix(var.zone_name, "."), ".", "-")}"
  project     = var.project_id
  dns_name    = var.zone_name
  description = "Managed DNS zone for ${var.zone_name} (${var.environment})"
  visibility  = "public"

  dnssec_config {
    state = "on"
  }

  labels = merge(
    local.common_labels,
    var.labels,
    {
      environment = var.environment
      zone        = replace(trimsuffix(var.zone_name, "."), ".", "-")
    },
  )
}

################################################################################
# DNS Record Sets
#
# Creates individual DNS record sets within the managed zone. Each record is
# keyed by its name for easy reference in module outputs.
################################################################################

resource "google_dns_record_set" "this" {
  for_each = var.records

  name         = each.key
  project      = var.project_id
  managed_zone = local.resolved_zone_name
  type         = each.value.type
  ttl          = each.value.ttl
  rrdatas      = each.value.rrdatas
}
