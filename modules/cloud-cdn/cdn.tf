################################################################################
# Global Static IP Address
################################################################################

resource "google_compute_global_address" "this" {
  name         = "${local.name_prefix}-cdn-ip"
  project      = var.project_id
  address_type = "EXTERNAL"
  ip_version   = "IPV4"
}

################################################################################
# Backend Bucket (for GCS origin)
#
# Used when origin_type is "gcs". Serves static content from a Cloud Storage
# bucket with Cloud CDN caching enabled.
################################################################################

resource "google_compute_backend_bucket" "this" {
  count = var.origin_type == "gcs" ? 1 : 0

  name        = "${local.name_prefix}-cdn-backend-bucket"
  project     = var.project_id
  bucket_name = var.gcs_bucket_name
  enable_cdn  = var.enable_cdn

  dynamic "cdn_policy" {
    for_each = var.enable_cdn ? [1] : []

    content {
      cache_mode                   = "CACHE_ALL_STATIC"
      default_ttl                  = 3600
      max_ttl                      = 86400
      client_ttl                   = 3600
      negative_caching             = true
      serve_while_stale            = 86400
      signed_url_cache_max_age_sec = 0

      negative_caching_policy {
        code = 404
        ttl  = 60
      }

      negative_caching_policy {
        code = 410
        ttl  = 300
      }
    }
  }
}

################################################################################
# Backend Service (for MIG/NEG origin)
#
# Used when origin_type is "backend_service". Proxies requests to a compute
# backend service with Cloud CDN caching and optional Cloud Armor protection.
################################################################################

resource "google_compute_backend_service" "this" {
  count = var.origin_type == "backend_service" ? 1 : 0

  name      = "${local.name_prefix}-cdn-backend-service"
  project   = var.project_id
  protocol  = "HTTPS"
  port_name = "https"

  timeout_sec                     = 30
  connection_draining_timeout_sec = 300
  load_balancing_scheme           = "EXTERNAL_MANAGED"
  enable_cdn                      = var.enable_cdn
  security_policy                 = var.cloud_armor_policy_id != "" ? var.cloud_armor_policy_id : null

  dynamic "cdn_policy" {
    for_each = var.enable_cdn ? [1] : []

    content {
      cache_mode                   = "CACHE_ALL_STATIC"
      default_ttl                  = 3600
      max_ttl                      = 86400
      client_ttl                   = 3600
      negative_caching             = true
      serve_while_stale            = 86400
      signed_url_cache_max_age_sec = 0

      cache_key_policy {
        include_host         = true
        include_protocol     = true
        include_query_string = true
      }

      negative_caching_policy {
        code = 404
        ttl  = 60
      }
    }
  }

  log_config {
    enable      = true
    sample_rate = 1.0
  }
}

################################################################################
# URL Map
#
# Routes all requests to the appropriate backend (bucket or service).
################################################################################

resource "google_compute_url_map" "this" {
  name            = "${local.name_prefix}-cdn-url-map"
  project         = var.project_id
  default_service = var.origin_type == "gcs" ? google_compute_backend_bucket.this[0].id : google_compute_backend_service.this[0].id
}

################################################################################
# HTTP Proxy and Forwarding Rule
#
# Always created to handle HTTP traffic. When an SSL certificate is provided,
# HTTP traffic can be redirected to HTTPS via URL map rules (not shown here
# to keep the module flexible).
################################################################################

resource "google_compute_target_http_proxy" "this" {
  name    = "${local.name_prefix}-cdn-http-proxy"
  project = var.project_id
  url_map = google_compute_url_map.this.id
}

resource "google_compute_global_forwarding_rule" "http" {
  name                  = "${local.name_prefix}-cdn-http-forwarding"
  project               = var.project_id
  target                = google_compute_target_http_proxy.this.id
  port_range            = "80"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  ip_address            = google_compute_global_address.this.id

  labels = merge(
    local.common_labels,
    var.labels,
    {
      environment = var.environment
    },
  )
}

################################################################################
# HTTPS Proxy and Forwarding Rule (conditional on SSL certificate)
#
# Created only when an SSL certificate is provided. Terminates TLS at the
# load balancer and forwards decrypted traffic to the backend.
################################################################################

resource "google_compute_target_https_proxy" "this" {
  count = var.ssl_certificate_id != "" ? 1 : 0

  name             = "${local.name_prefix}-cdn-https-proxy"
  project          = var.project_id
  url_map          = google_compute_url_map.this.id
  ssl_certificates = [var.ssl_certificate_id]
}

resource "google_compute_global_forwarding_rule" "https" {
  count = var.ssl_certificate_id != "" ? 1 : 0

  name                  = "${local.name_prefix}-cdn-https-forwarding"
  project               = var.project_id
  target                = google_compute_target_https_proxy.this[0].id
  port_range            = "443"
  load_balancing_scheme = "EXTERNAL_MANAGED"
  ip_address            = google_compute_global_address.this.id

  labels = merge(
    local.common_labels,
    var.labels,
    {
      environment = var.environment
    },
  )
}
