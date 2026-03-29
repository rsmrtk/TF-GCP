# Complete Example
#
# This example demonstrates how to use all modules together.
# Copy this to a new environment directory and customize the values.

terraform {
  required_version = ">= 1.9.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}

provider "google" {
  project = "my-gcp-project"
  region  = "europe-west1"

  default_labels = {
    project     = "example"
    environment = "dev"
    managed-by  = "terraform"
  }
}

data "google_compute_zones" "available" {
  project = "my-gcp-project"
  region  = "europe-west1"
}

locals {
  project     = "example"
  environment = "dev"
  project_id  = "my-gcp-project"
  azs         = slice(data.google_compute_zones.available.names, 0, 2)
}

module "networking" {
  source = "../../modules/networking"

  project            = local.project
  environment        = local.environment
  project_id         = local.project_id
  region             = "europe-west1"
  vpc_cidr           = "10.0.0.0/16"
  azs                = local.azs
  single_nat_gateway = true
}

module "security" {
  source = "../../modules/security"

  project     = local.project
  environment = local.environment
  project_id  = local.project_id
  region      = "europe-west1"
  vpc_id      = module.networking.vpc_self_link
  vpc_name    = module.networking.vpc_name
}

module "iam" {
  source = "../../modules/iam"

  project     = local.project
  environment = local.environment
  project_id  = local.project_id
  kms_key_id  = module.security.kms_key_id
}

module "cloud_sql" {
  source = "../../modules/cloud-sql"

  project       = local.project
  environment   = local.environment
  project_id    = local.project_id
  region        = "europe-west1"
  vpc_self_link = module.networking.vpc_self_link
  kms_key_id    = module.security.kms_key_id
}
