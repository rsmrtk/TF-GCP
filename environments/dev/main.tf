module "networking" {
  source = "../../modules/networking"

  project     = var.project
  environment = var.environment
  project_id  = var.project_id
  region      = var.gcp_region
  vpc_cidr    = "10.0.0.0/16"
  azs         = local.azs

  # single Cloud NAT saves costs in dev
  single_nat_gateway           = true
  enable_flow_logs             = true
  enable_private_google_access = true
}

module "security" {
  source = "../../modules/security"

  project     = var.project
  environment = var.environment
  project_id  = var.project_id
  region      = var.gcp_region
  vpc_id      = module.networking.vpc_self_link

  enable_cloud_armor = false

  labels = local.common_labels
}

module "iam" {
  source = "../../modules/iam"

  project     = var.project
  environment = var.environment
  project_id  = var.project_id
  kms_key_id  = module.security.kms_key_id
}

module "gcs" {
  source = "../../modules/gcs"

  project     = var.project
  environment = var.environment
  project_id  = var.project_id
  region      = var.gcp_region
  kms_key_id  = module.security.kms_key_id

  buckets = {
    assets = {
      purpose    = "application-static-assets"
      versioning = true
    }
    logs = {
      purpose    = "application-and-access-logs"
      versioning = false
      lifecycle_rules = [
        {
          id              = "expire-old-logs"
          transition_days = 30
          expiration_days = 90
        }
      ]
    }
  }

  labels = local.common_labels
}

module "artifact_registry" {
  source = "../../modules/artifact-registry"

  project     = var.project
  environment = var.environment
  project_id  = var.project_id
  region      = var.gcp_region
  kms_key_id  = module.security.kms_key_id

  repositories = {
    app = {
      cleanup_keep = 10
    }
  }

  labels = local.common_labels
}

module "compute" {
  source = "../../modules/compute"

  project                   = var.project
  environment               = var.environment
  project_id                = var.project_id
  region                    = var.gcp_region
  private_subnet_self_links = module.networking.private_subnet_self_links
  lb_firewall_tag           = module.security.lb_firewall_tag
  app_firewall_tag          = module.security.app_firewall_tag
  machine_type              = "e2-micro"
  service_account_email     = module.iam.compute_sa_email
  min_size                  = 1
  max_size                  = 2
  desired_size              = 1
  kms_key_id                = module.security.kms_key_id

  labels = local.common_labels
}

module "gke" {
  source = "../../modules/gke"

  project                       = var.project
  environment                   = var.environment
  project_id                    = var.project_id
  region                        = var.gcp_region
  vpc_self_link                 = module.networking.vpc_self_link
  private_subnet_self_links     = module.networking.private_subnet_self_links
  pods_secondary_range_name     = module.networking.pods_secondary_range_name
  services_secondary_range_name = module.networking.services_secondary_range_name
  kms_key_id                    = module.security.kms_key_id

  node_pools = {
    general = {
      machine_type  = "e2-standard-2"
      min_count     = 1
      max_count     = 2
      initial_count = 1
      disk_size_gb  = 30
    }
  }

  labels = local.common_labels
}

module "cloud_run" {
  source = "../../modules/cloud-run"

  project               = var.project
  environment           = var.environment
  project_id            = var.project_id
  region                = var.gcp_region
  service_account_email = module.iam.cloud_run_sa_email

  labels = local.common_labels
}

module "cloud_sql" {
  source = "../../modules/cloud-sql"

  project                 = var.project
  environment             = var.environment
  project_id              = var.project_id
  region                  = var.gcp_region
  vpc_self_link           = module.networking.vpc_self_link
  database_version        = "POSTGRES_16"
  tier                    = "db-f1-micro"
  disk_size               = 20
  availability_type       = "ZONAL"
  backup_retained_backups = 7
  deletion_protection     = false
  kms_key_id              = module.security.kms_key_id

  labels = local.common_labels
}

module "monitoring" {
  source = "../../modules/monitoring"

  project     = var.project
  environment = var.environment
  project_id  = var.project_id

  labels = local.common_labels
}
