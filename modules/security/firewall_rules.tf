# -----------------------------------------------------------------------------
# VPC Firewall Rules (equivalent to AWS Security Groups)
# -----------------------------------------------------------------------------
# GCP firewall rules are applied at the VPC level and use target tags to
# control which instances the rules apply to. This is analogous to AWS
# security groups but operates as a flat list of rules rather than per-
# resource group associations.
# -----------------------------------------------------------------------------

locals {
  # Firewall target tags for use by other modules
  lb_firewall_tag           = "${local.name_prefix}-allow-lb"
  health_check_firewall_tag = "${local.name_prefix}-allow-health-check"
  app_firewall_tag          = "${local.name_prefix}-allow-app-internal"
  db_firewall_tag           = "${local.name_prefix}-allow-db"

  # Google Cloud health check source IP ranges
  # https://cloud.google.com/load-balancing/docs/health-check-concepts#ip-ranges
  health_check_source_ranges = [
    "130.211.0.0/22",
    "35.191.0.0/16",
  ]
}

# -----------------------------------------------------------------------------
# Allow Google Cloud health check probes
# -----------------------------------------------------------------------------
# Required for load balancer health checks to reach backend instances.
# These IP ranges are used by all GCP load balancer types.
# -----------------------------------------------------------------------------

resource "google_compute_firewall" "allow_health_check" {
  name    = "${local.name_prefix}-allow-health-check"
  network = var.vpc_id
  project = var.project_id

  description = "Allow Google Cloud health check probes to tagged instances"
  direction   = "INGRESS"
  priority    = 1000

  source_ranges = local.health_check_source_ranges
  target_tags   = [local.health_check_firewall_tag]

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "8080"]
  }

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

# -----------------------------------------------------------------------------
# Allow HTTP/HTTPS from the internet to load-balancer-facing instances
# -----------------------------------------------------------------------------

resource "google_compute_firewall" "allow_lb" {
  name    = "${local.name_prefix}-allow-lb"
  network = var.vpc_id
  project = var.project_id

  description = "Allow HTTP and HTTPS traffic from the internet to load-balancer-tagged instances"
  direction   = "INGRESS"
  priority    = 1100

  source_ranges = ["0.0.0.0/0"]
  target_tags   = [local.lb_firewall_tag]

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

# -----------------------------------------------------------------------------
# Allow internal communication between application instances
# -----------------------------------------------------------------------------

resource "google_compute_firewall" "allow_app_internal" {
  name    = "${local.name_prefix}-allow-app-internal"
  network = var.vpc_id
  project = var.project_id

  description = "Allow internal traffic between application instances"
  direction   = "INGRESS"
  priority    = 1200

  source_tags = [local.app_firewall_tag]
  target_tags = [local.app_firewall_tag]

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

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

# -----------------------------------------------------------------------------
# Allow application instances to reach database (PostgreSQL)
# -----------------------------------------------------------------------------

resource "google_compute_firewall" "allow_db" {
  name    = "${local.name_prefix}-allow-db"
  network = var.vpc_id
  project = var.project_id

  description = "Allow application instances to reach database on port 5432"
  direction   = "INGRESS"
  priority    = 1300

  source_tags = [local.app_firewall_tag]
  target_tags = [local.db_firewall_tag]

  allow {
    protocol = "tcp"
    ports    = ["5432"]
  }

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}

# -----------------------------------------------------------------------------
# Deny all other ingress traffic (catch-all rule)
# -----------------------------------------------------------------------------
# This rule has the lowest possible priority (65534) to ensure it only matches
# traffic that is not matched by any higher-priority rule. GCP has an implied
# deny-all at priority 65535, but this explicit rule provides logging.
# -----------------------------------------------------------------------------

resource "google_compute_firewall" "deny_all_ingress" {
  name    = "${local.name_prefix}-deny-all-ingress"
  network = var.vpc_id
  project = var.project_id

  description = "Deny all other ingress traffic not matched by higher-priority rules"
  direction   = "INGRESS"
  priority    = 65534

  source_ranges = ["0.0.0.0/0"]

  deny {
    protocol = "all"
  }

  log_config {
    metadata = "INCLUDE_ALL_METADATA"
  }
}
