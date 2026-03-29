resource "google_compute_region_instance_group_manager" "this" {
  name               = "${local.name_prefix}-mig"
  base_instance_name = "${local.name_prefix}-instance"
  region             = var.region
  target_size        = var.desired_size
  project            = var.project_id

  version {
    instance_template = google_compute_instance_template.this.self_link_unique
  }

  named_port {
    name = "http"
    port = 8080
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.this.id
    initial_delay_sec = 300
  }

  update_policy {
    type                  = "PROACTIVE"
    minimal_action        = "REPLACE"
    max_surge_fixed       = 1
    max_unavailable_fixed = 0
  }

  lifecycle {
    ignore_changes = [target_size]
  }
}

resource "google_compute_region_autoscaler" "this" {
  name    = "${local.name_prefix}-autoscaler"
  region  = var.region
  target  = google_compute_region_instance_group_manager.this.id
  project = var.project_id

  autoscaling_policy {
    min_replicas    = var.min_size
    max_replicas    = var.max_size
    cooldown_period = 60

    cpu_utilization {
      target = 0.7
    }
  }
}
