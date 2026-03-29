# -----------------------------------------------------------------------------
# Health Check
# -----------------------------------------------------------------------------

resource "google_compute_health_check" "this" {
  name    = "${local.name_prefix}-health-check"
  project = var.project_id

  check_interval_sec  = 10
  timeout_sec         = 5
  healthy_threshold   = 2
  unhealthy_threshold = 3

  http_health_check {
    port         = 8080
    request_path = "/health"
  }

  log_config {
    enable = true
  }
}

# -----------------------------------------------------------------------------
# Backend Service
# -----------------------------------------------------------------------------

resource "google_compute_backend_service" "this" {
  name      = "${local.name_prefix}-backend-service"
  project   = var.project_id
  protocol  = "HTTP"
  port_name = "http"

  timeout_sec                     = 30
  connection_draining_timeout_sec = 300
  load_balancing_scheme           = "EXTERNAL_MANAGED"

  health_checks = [google_compute_health_check.this.id]

  backend {
    group           = google_compute_region_instance_group_manager.this.instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
    max_utilization = 0.8
  }

  log_config {
    enable      = true
    sample_rate = 1.0
  }
}

# -----------------------------------------------------------------------------
# URL Map
# -----------------------------------------------------------------------------

resource "google_compute_url_map" "this" {
  name            = "${local.name_prefix}-url-map"
  project         = var.project_id
  default_service = google_compute_backend_service.this.id
}

# -----------------------------------------------------------------------------
# HTTP Proxy and Forwarding Rule
# -----------------------------------------------------------------------------

resource "google_compute_target_http_proxy" "this" {
  name    = "${local.name_prefix}-http-proxy"
  project = var.project_id
  url_map = google_compute_url_map.this.id
}

resource "google_compute_global_forwarding_rule" "http" {
  name                  = "${local.name_prefix}-http-forwarding-rule"
  project               = var.project_id
  target                = google_compute_target_http_proxy.this.id
  port_range            = "80"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  ip_address            = google_compute_global_address.this.id
}

# -----------------------------------------------------------------------------
# HTTPS Proxy and Forwarding Rule (conditional on certificate_id)
# -----------------------------------------------------------------------------

resource "google_compute_target_https_proxy" "this" {
  count = var.certificate_id != "" ? 1 : 0

  name             = "${local.name_prefix}-https-proxy"
  project          = var.project_id
  url_map          = google_compute_url_map.this.id
  ssl_certificates = [var.certificate_id]
}

resource "google_compute_global_forwarding_rule" "https" {
  count = var.certificate_id != "" ? 1 : 0

  name                  = "${local.name_prefix}-https-forwarding-rule"
  project               = var.project_id
  target                = google_compute_target_https_proxy.this[0].id
  port_range            = "443"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  ip_address            = google_compute_global_address.this.id
}

# -----------------------------------------------------------------------------
# Global Static IP Address
# -----------------------------------------------------------------------------

resource "google_compute_global_address" "this" {
  name         = "${local.name_prefix}-lb-ip"
  project      = var.project_id
  address_type = "EXTERNAL"
  ip_version   = "IPV4"
}
