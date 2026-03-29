terraform {
  backend "gcs" {
    bucket = "tfgcp-staging-terraform-state"
    prefix = "staging/terraform.tfstate"
  }
}
