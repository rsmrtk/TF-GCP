resource "google_artifact_registry_repository" "this" {
  for_each = var.repositories

  repository_id = "${local.name_prefix}-${each.key}"
  project       = var.project_id
  location      = var.region
  format        = each.value.format
  description   = each.value.description != "" ? each.value.description : "Artifact Registry repository for ${each.key}"
  mode          = "STANDARD_REPOSITORY"

  dynamic "docker_config" {
    for_each = each.value.format == "DOCKER" ? [1] : []

    content {
      immutable_tags = each.value.immutable_tags
    }
  }

  kms_key_name = var.kms_key_id != "" ? var.kms_key_id : null

  cleanup_policies {
    id     = "keep-recent-versions"
    action = "KEEP"

    most_recent_versions {
      keep_count = each.value.cleanup_keep
    }
  }

  cleanup_policies {
    id     = "delete-untagged"
    action = "DELETE"

    condition {
      tag_state = "UNTAGGED"
    }
  }

  cleanup_policy_dry_run = false

  labels = merge(
    local.common_labels,
    var.labels,
    {
      environment = var.environment
      repository  = each.key
      format      = lower(each.value.format)
    },
  )
}
