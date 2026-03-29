resource "google_compute_instance_template" "this" {
  name_prefix  = "${local.name_prefix}-template-"
  machine_type = var.machine_type
  project      = var.project_id
  region       = var.region

  tags = [var.app_firewall_tag, var.lb_firewall_tag]

  disk {
    source_image = "projects/ubuntu-os-cloud/global/images/family/ubuntu-2404-lts-amd64"
    auto_delete  = true
    boot         = true
    disk_size_gb = 20
    disk_type    = "pd-balanced"

    disk_encryption_key {
      kms_key_self_link = var.kms_key_id != "" ? var.kms_key_id : null
    }
  }

  network_interface {
    subnetwork = var.private_subnet_self_links[0]
  }

  service_account {
    email  = var.service_account_email
    scopes = ["cloud-platform"]
  }

  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  labels = merge(local.common_labels, var.labels)

  lifecycle {
    create_before_destroy = true
  }
}
