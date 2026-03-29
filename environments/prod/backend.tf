terraform {
  backend "gcs" {
    bucket = "tfgcp-prod-terraform-state"
    prefix = "prod/terraform.tfstate"
  }
}
