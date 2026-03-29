################################################################################
# Cloud Functions v2
#
# Each function is built from a source archive in GCS. The build config
# points to the Cloud Storage source, and the service config controls
# runtime settings, scaling, and networking.
################################################################################

resource "google_cloudfunctions2_function" "this" {
  for_each = var.functions

  name         = "${local.name_prefix}-${each.key}"
  project      = var.project_id
  location     = var.region
  description  = each.value.description != "" ? each.value.description : "Cloud Function: ${each.key}"
  kms_key_name = var.kms_key_id != "" ? var.kms_key_id : null

  build_config {
    runtime     = each.value.runtime
    entry_point = each.value.entry_point

    source {
      storage_source {
        bucket = each.value.source_bucket
        object = each.value.source_object
      }
    }
  }

  service_config {
    available_memory               = "${each.value.memory_mb}M"
    timeout_seconds                = each.value.timeout_seconds
    min_instance_count             = each.value.min_instances
    max_instance_count             = each.value.max_instances
    service_account_email          = var.service_account_email
    ingress_settings               = each.value.ingress_settings
    all_traffic_on_latest_revision = true
    environment_variables          = each.value.env_vars
    vpc_connector                  = each.value.vpc_connector != "" ? each.value.vpc_connector : null
    vpc_connector_egress_settings  = each.value.vpc_connector != "" ? "PRIVATE_RANGES_ONLY" : null
  }

  labels = merge(
    local.common_labels,
    var.labels,
    {
      environment = var.environment
      function    = each.key
    },
  )
}

################################################################################
# IAM: Allow unauthenticated invocation (only when API Gateway is enabled)
#
# When API Gateway is enabled, functions must be publicly invocable by the
# gateway. Authentication is handled at the gateway level instead.
################################################################################

resource "google_cloud_run_v2_service_iam_member" "invoker" {
  for_each = var.enable_api_gateway ? var.functions : {}

  project  = var.project_id
  location = var.region
  name     = google_cloudfunctions2_function.this[each.key].name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
