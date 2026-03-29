resource "google_compute_global_address" "private_ip" {
  name          = "${local.name_prefix}-db-private-ip"
  project       = var.project_id
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = var.vpc_self_link

  labels = merge(local.common_labels, var.labels)
}

resource "google_service_networking_connection" "private_vpc" {
  network                 = var.vpc_self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip.name]
}
