locals {
  name_prefix = "${var.project}-${var.environment}"
  common_labels = {
    module = "artifact-registry"
  }
}
