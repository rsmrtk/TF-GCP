################################################################################
# Public Subnets
#
# Public subnets are intended for resources that require direct external access
# such as load balancers. Uses the first block of the CIDR space.
# CIDR: cidrsubnet(vpc_cidr, 8, index) -> /24 subnets from a /16
################################################################################

resource "google_compute_subnetwork" "public" {
  count = length(var.azs)

  name    = "${local.name_prefix}-public-${var.azs[count.index]}"
  network = google_compute_network.this.id
  project = var.project_id
  region  = var.region

  ip_cidr_range            = cidrsubnet(var.vpc_cidr, 8, count.index)
  private_ip_google_access = var.enable_private_google_access

  dynamic "log_config" {
    for_each = var.enable_flow_logs ? [1] : []

    content {
      aggregation_interval = "INTERVAL_5_SEC"
      flow_sampling        = var.flow_log_sampling_rate
      metadata             = "INCLUDE_ALL_METADATA"
      filter_expr          = "true"
    }
  }
}

################################################################################
# Private Subnets
#
# Private subnets are for application workloads that egress through Cloud NAT.
# Uses the second block of the CIDR space (offset by length(azs)).
# CIDR: cidrsubnet(vpc_cidr, 8, length(azs) + index)
################################################################################

resource "google_compute_subnetwork" "private" {
  count = length(var.azs)

  name    = "${local.name_prefix}-private-${var.azs[count.index]}"
  network = google_compute_network.this.id
  project = var.project_id
  region  = var.region

  ip_cidr_range            = cidrsubnet(var.vpc_cidr, 8, length(var.azs) + count.index)
  private_ip_google_access = var.enable_private_google_access

  dynamic "log_config" {
    for_each = var.enable_flow_logs ? [1] : []

    content {
      aggregation_interval = "INTERVAL_5_SEC"
      flow_sampling        = var.flow_log_sampling_rate
      metadata             = "INCLUDE_ALL_METADATA"
      filter_expr          = "true"
    }
  }
}

################################################################################
# Data Subnets
#
# Data subnets are for managed data services (Cloud SQL, Memorystore, etc.)
# with no external access. Uses the third block of the CIDR space.
# CIDR: cidrsubnet(vpc_cidr, 8, 2 * length(azs) + index)
################################################################################

resource "google_compute_subnetwork" "data" {
  count = length(var.azs)

  name    = "${local.name_prefix}-data-${var.azs[count.index]}"
  network = google_compute_network.this.id
  project = var.project_id
  region  = var.region

  ip_cidr_range            = cidrsubnet(var.vpc_cidr, 8, 2 * length(var.azs) + count.index)
  private_ip_google_access = var.enable_private_google_access

  dynamic "log_config" {
    for_each = var.enable_flow_logs ? [1] : []

    content {
      aggregation_interval = "INTERVAL_5_SEC"
      flow_sampling        = var.flow_log_sampling_rate
      metadata             = "INCLUDE_ALL_METADATA"
      filter_expr          = "true"
    }
  }
}
