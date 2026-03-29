module "networking" {
  source = "../../modules/networking"

  project            = var.project
  environment        = var.environment
  project_id         = var.project_id
  region             = var.gcp_region
  vpc_cidr           = "10.1.0.0/16"
  azs                = local.azs
  single_nat_gateway = true

  enable_flow_logs             = true
  enable_private_google_access = true
  flow_log_sampling_rate       = 0.5
}

module "security" {
  source = "../../modules/security"

  project            = var.project
  environment        = var.environment
  project_id         = var.project_id
  region             = var.gcp_region
  vpc_id             = module.networking.vpc_self_link
  enable_cloud_armor = true
  cloud_armor_mode   = "preview"

  labels = local.common_labels
}

module "iam" {
  source = "../../modules/iam"

  project                   = var.project
  environment               = var.environment
  project_id                = var.project_id
  create_compute_sa         = true
  create_cloud_run_sa       = true
  create_cloud_functions_sa = false
  kms_key_id                = module.security.kms_key_id
  gcs_bucket_names          = values(module.gcs.bucket_names)
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
      purpose    = "static-assets"
      versioning = true
      lifecycle_rules = [
        {
          id              = "transition-to-nearline"
          transition_days = 30
        }
      ]
    }
    logs = {
      purpose    = "application-and-access-logs"
      versioning = false
      lifecycle_rules = [
        {
          id              = "expire-old-logs"
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
      immutable_tags = true
      cleanup_keep   = 20
    }
    worker = {
      immutable_tags = true
      cleanup_keep   = 20
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
  machine_type              = "e2-small"
  service_account_email     = module.iam.compute_sa_email
  min_size                  = 1
  max_size                  = 3
  desired_size              = 2
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
  cluster_version               = "1.30"
  kms_key_id                    = module.security.kms_key_id

  node_pools = {
    general = {
      machine_type  = "e2-standard-4"
      min_count     = 2
      max_count     = 4
      initial_count = 2
      disk_size_gb  = 50
    }
  }

  enable_private_nodes    = true
  enable_private_endpoint = false

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
  tier                    = "db-custom-2-7680"
  disk_size               = 20
  disk_autoresize_limit   = 100
  availability_type       = "ZONAL"
  backup_retained_backups = 14
  deletion_protection     = true
  enable_insights         = true
  kms_key_id              = module.security.kms_key_id

  labels = local.common_labels
}

module "monitoring" {
  source = "../../modules/monitoring"

  project               = var.project
  environment           = var.environment
  project_id            = var.project_id
  alarm_email_endpoints = []

  labels = local.common_labels
}
