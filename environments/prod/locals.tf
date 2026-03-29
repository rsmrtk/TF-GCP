locals {
  azs = slice(data.google_compute_zones.available.names, 0, 3)

  common_labels = {
    project     = var.project
    environment = var.environment
  }
}
