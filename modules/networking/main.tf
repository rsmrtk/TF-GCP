################################################################################
# VPC Network
################################################################################

resource "google_compute_network" "this" {
  name                    = "${local.name_prefix}-vpc"
  auto_create_subnetworks = false
  routing_mode            = "REGIONAL"
  project                 = var.project_id
}

################################################################################
# Default Firewall Rules
################################################################################

# Deny all ingress traffic by default (lowest priority)
resource "google_compute_firewall" "deny_all_ingress" {
  name    = "${local.name_prefix}-deny-all-ingress"
  network = google_compute_network.this.id
  project = var.project_id

  priority  = 65534
  direction = "INGRESS"

  deny {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"]

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

# Allow internal traffic within the VPC CIDR
resource "google_compute_firewall" "allow_internal" {
  name    = "${local.name_prefix}-allow-internal"
  network = google_compute_network.this.id
  project = var.project_id

  priority  = 1000
  direction = "INGRESS"

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_ranges = [var.vpc_cidr]
}

# Allow Google health check ranges (required for load balancers and health checks)
resource "google_compute_firewall" "allow_health_checks" {
  name    = "${local.name_prefix}-allow-health-checks"
  network = google_compute_network.this.id
  project = var.project_id

  priority  = 1000
  direction = "INGRESS"

  allow {
    protocol = "tcp"
  }

  source_ranges = [
    "130.211.0.0/22",
    "35.191.0.0/16",
  ]
}
