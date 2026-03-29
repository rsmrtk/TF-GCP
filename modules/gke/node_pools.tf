# -----------------------------------------------------------------------------
# Managed Node Pools
# -----------------------------------------------------------------------------

resource "google_container_node_pool" "this" {
  for_each = var.node_pools

  name     = "${local.name_prefix}-${each.key}"
  location = var.region
  cluster  = google_container_cluster.this.name
  project  = var.project_id

  initial_node_count = each.value.initial_count

  autoscaling {
    min_node_count = each.value.min_count
    max_node_count = each.value.max_count
  }

  management {
    auto_repair  = true
    auto_upgrade = true
  }

  upgrade_settings {
    max_surge       = 1
    max_unavailable = 0
    strategy        = "SURGE"
  }

  node_config {
    machine_type = each.value.machine_type
    disk_size_gb = each.value.disk_size_gb
    disk_type    = each.value.disk_type
    preemptible  = each.value.preemptible
    spot         = each.value.spot

    image_type = "COS_CONTAINERD"

    # Workload Identity on nodes
    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    # Shielded instance configuration
    shielded_instance_config {
      enable_secure_boot          = true
      enable_integrity_monitoring = true
    }

    # Minimal OAuth scopes; use Workload Identity for fine-grained access
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]

    # Metadata to disable legacy metadata endpoints
    metadata = {
      disable-legacy-endpoints = "true"
    }

    labels = merge(local.common_labels, var.labels, {
      node-pool = each.key
    })
  }

  lifecycle {
    ignore_changes = [
      initial_node_count,
    ]
  }
}
