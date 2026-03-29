terraform {
  backend "gcs" {
    bucket = "tfgcp-dev-terraform-state"
    prefix = "dev/terraform.tfstate"
  }
}
