resource "google_cloud_run_v2_service" "this" {
  for_each = var.services

  name     = "${local.name_prefix}-${each.key}"
  location = var.region
  project  = var.project_id
  ingress  = each.value.ingress

  template {
    service_account = var.service_account_email

    scaling {
      min_instance_count = each.value.min_instances
      max_instance_count = each.value.max_instances
    }

    containers {
      image = each.value.image

      ports {
        container_port = each.value.port
      }

      resources {
        limits = {
          cpu    = each.value.cpu
          memory = each.value.memory
        }
      }

      dynamic "env" {
        for_each = merge({
          ENVIRONMENT = var.environment
          PROJECT     = var.project
        }, each.value.env_vars)
        content {
          name  = env.key
          value = env.value
        }
      }

      dynamic "env" {
        for_each = each.value.secret_env_vars
        content {
          name = env.key
          value_source {
            secret_key_ref {
              secret  = env.value
              version = "latest"
            }
          }
        }
      }
    }

    dynamic "volumes" {
      for_each = length(each.value.cloudsql_connections) > 0 ? [1] : []
      content {
        name = "cloudsql"
        cloud_sql_instance {
          instances = each.value.cloudsql_connections
        }
      }
    }

    vpc_access {
      connector = var.vpc_connector_id != "" ? var.vpc_connector_id : null
      egress    = var.vpc_connector_id != "" ? "PRIVATE_RANGES_ONLY" : null
    }

    timeout                          = "${each.value.timeout_seconds}s"
    max_instance_request_concurrency = each.value.concurrency
  }

  labels = merge(local.common_labels, var.labels)
}
