################################################################################
# Cloud Router
#
# A single regional Cloud Router is required for Cloud NAT.
################################################################################

resource "google_compute_router" "this" {
  name    = "${local.name_prefix}-router"
  network = google_compute_network.this.id
  region  = var.region
  project = var.project_id
}

################################################################################
# Cloud NAT
#
# GCP Cloud NAT is a regional resource. When single_nat_gateway is true, all
# subnets use NAT. When false, only private subnets are configured for NAT.
################################################################################

resource "google_compute_router_nat" "this" {
  name    = "${local.name_prefix}-nat"
  router  = google_compute_router.this.name
  region  = var.region
  project = var.project_id

  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = var.single_nat_gateway ? "ALL_SUBNETWORKS_ALL_IP_RANGES" : "LIST_OF_SUBNETWORKS"

  # When not using single NAT gateway, only route private subnets through NAT
  dynamic "subnetwork" {
    for_each = var.single_nat_gateway ? [] : google_compute_subnetwork.private

    content {
      name                    = subnetwork.value.id
      source_ip_ranges_to_nat = ["ALL_IP_RANGES"]
    }
  }

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}
