# -----------------------------------------------------------------------------
# Google-Managed SSL Certificates (equivalent to AWS ACM)
# -----------------------------------------------------------------------------
# Google-managed SSL certificates are automatically provisioned and renewed
# by Google. They must be attached to a load balancer target proxy for
# domain validation to succeed. Unlike AWS ACM, there is no separate
# validation step -- Google handles validation via the load balancer.
# -----------------------------------------------------------------------------

resource "google_compute_managed_ssl_certificate" "this" {
  count = length(var.ssl_domains) > 0 ? 1 : 0

  name    = "${local.name_prefix}-ssl-cert"
  project = var.project_id

  managed {
    domains = var.ssl_domains
  }

  lifecycle {
    create_before_destroy = true
  }
}
