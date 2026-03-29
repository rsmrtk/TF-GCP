# -----------------------------------------------------------------------------
# Cloud Armor Security Policy (equivalent to AWS WAF)
# -----------------------------------------------------------------------------
# Cloud Armor provides application-layer (L7) DDoS protection and WAF
# capabilities for resources behind a Google Cloud external HTTP(S) load
# balancer. This policy includes OWASP Top 10 protections (SQL injection
# and XSS) using pre-configured expression sets.
#
# When cloud_armor_mode is "preview", rules are logged but not enforced,
# similar to AWS WAF "count" mode. When set to "deny(403)", requests
# matching the rules are blocked, similar to AWS WAF "block" mode.
# -----------------------------------------------------------------------------

resource "google_compute_security_policy" "this" {
  count = var.enable_cloud_armor ? 1 : 0

  name        = "${local.name_prefix}-cloud-armor-policy"
  project     = var.project_id
  description = "Cloud Armor WAF policy with OWASP Top 10 protections for ${local.name_prefix}"

  # ---------------------------------------------------------------------------
  # Default rule: allow all traffic
  # ---------------------------------------------------------------------------
  # This is the lowest-priority catch-all rule. All traffic that does not
  # match a higher-priority rule is allowed through.
  # ---------------------------------------------------------------------------

  rule {
    action   = "allow"
    priority = "2147483647"

    match {
      versioned_expr = "SRC_IPS_V1"

      config {
        src_ip_ranges = ["*"]
      }
    }

    description = "Default allow rule"
  }

  # ---------------------------------------------------------------------------
  # SQL Injection Protection (OWASP A03:2021)
  # ---------------------------------------------------------------------------

  rule {
    action   = var.cloud_armor_mode == "preview" ? "allow" : "deny(403)"
    priority = "1000"

    match {
      expr {
        expression = "evaluatePreconfiguredExpr('sqli-v33-stable')"
      }
    }

    description = "SQL injection protection"
    preview     = var.cloud_armor_mode == "preview"
  }

  # ---------------------------------------------------------------------------
  # Cross-Site Scripting (XSS) Protection (OWASP A03:2021)
  # ---------------------------------------------------------------------------

  rule {
    action   = var.cloud_armor_mode == "preview" ? "allow" : "deny(403)"
    priority = "1001"

    match {
      expr {
        expression = "evaluatePreconfiguredExpr('xss-v33-stable')"
      }
    }

    description = "XSS protection"
    preview     = var.cloud_armor_mode == "preview"
  }

  # ---------------------------------------------------------------------------
  # Remote Code Execution (RCE) Protection
  # ---------------------------------------------------------------------------

  rule {
    action   = var.cloud_armor_mode == "preview" ? "allow" : "deny(403)"
    priority = "1002"

    match {
      expr {
        expression = "evaluatePreconfiguredExpr('rce-v33-stable')"
      }
    }

    description = "Remote code execution protection"
    preview     = var.cloud_armor_mode == "preview"
  }

  # ---------------------------------------------------------------------------
  # Local File Inclusion (LFI) Protection
  # ---------------------------------------------------------------------------

  rule {
    action   = var.cloud_armor_mode == "preview" ? "allow" : "deny(403)"
    priority = "1003"

    match {
      expr {
        expression = "evaluatePreconfiguredExpr('lfi-v33-stable')"
      }
    }

    description = "Local file inclusion protection"
    preview     = var.cloud_armor_mode == "preview"
  }

  # ---------------------------------------------------------------------------
  # Remote File Inclusion (RFI) Protection
  # ---------------------------------------------------------------------------

  rule {
    action   = var.cloud_armor_mode == "preview" ? "allow" : "deny(403)"
    priority = "1004"

    match {
      expr {
        expression = "evaluatePreconfiguredExpr('rfi-v33-stable')"
      }
    }

    description = "Remote file inclusion protection"
    preview     = var.cloud_armor_mode == "preview"
  }

  # ---------------------------------------------------------------------------
  # Scanner Detection
  # ---------------------------------------------------------------------------

  rule {
    action   = var.cloud_armor_mode == "preview" ? "allow" : "deny(403)"
    priority = "1005"

    match {
      expr {
        expression = "evaluatePreconfiguredExpr('scannerdetection-v33-stable')"
      }
    }

    description = "Scanner detection protection"
    preview     = var.cloud_armor_mode == "preview"
  }

  # ---------------------------------------------------------------------------
  # Protocol Attack Protection
  # ---------------------------------------------------------------------------

  rule {
    action   = var.cloud_armor_mode == "preview" ? "allow" : "deny(403)"
    priority = "1006"

    match {
      expr {
        expression = "evaluatePreconfiguredExpr('protocolattack-v33-stable')"
      }
    }

    description = "Protocol attack protection"
    preview     = var.cloud_armor_mode == "preview"
  }

  # ---------------------------------------------------------------------------
  # Session Fixation Protection
  # ---------------------------------------------------------------------------

  rule {
    action   = var.cloud_armor_mode == "preview" ? "allow" : "deny(403)"
    priority = "1007"

    match {
      expr {
        expression = "evaluatePreconfiguredExpr('sessionfixation-v33-stable')"
      }
    }

    description = "Session fixation protection"
    preview     = var.cloud_armor_mode == "preview"
  }
}
