module "networking" {
  source = "../../modules/networking"

  project     = var.project
  environment = var.environment
  project_id  = var.project_id
  region      = var.gcp_region
  vpc_cidr    = "10.2.0.0/16"
  azs         = local.azs

  # Cloud NAT is regional in GCP, single_nat_gateway=false routes only private subnets
  single_nat_gateway           = false
  enable_flow_logs             = true
  enable_private_google_access = true
  flow_log_sampling_rate       = 1.0
}

module "security" {
  source = "../../modules/security"

  project            = var.project
  environment        = var.environment
  project_id         = var.project_id
  region             = var.gcp_region
  vpc_id             = module.networking.vpc_self_link
  enable_cloud_armor = true
  cloud_armor_mode   = "deny(403)"

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
      lifecycle_rules = [
        {
          id              = "transition-to-nearline"
          transition_days = 30
        },
        {
          id                                 = "cleanup-old-versions"
          noncurrent_version_expiration_days = 90
        }
      ]
    }
    logs = {
      purpose    = "application-and-access-logs"
      versioning = true
      lifecycle_rules = [
        {
          id              = "transition-to-nearline"
          transition_days = 30
        },
        {
          id              = "expire-old-logs"
          transition_days = 60
          expiration_days = 180
        }
      ]
    }
    backups = {
      purpose    = "database-and-application-backups"
      versioning = true
      lifecycle_rules = [
        {
          id                       = "transition-to-nearline"
          transition_days          = 30
          transition_storage_class = "NEARLINE"
        },
        {
          id              = "expire-old-backups"
          expiration_days = 365
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
      cleanup_keep = 50
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
  machine_type              = "e2-standard-4"
  service_account_email     = module.iam.compute_sa_email
  min_size                  = 2
  max_size                  = 6
  desired_size              = 3
  certificate_id            = "" # TODO: replace with SSL certificate ID
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
      machine_type  = "e2-standard-8"
      min_count     = 3
      max_count     = 6
      initial_count = 3
      disk_size_gb  = 100
    }
  }

  # lock down the control plane -- operators connect via VPN or IAP
  enable_private_nodes    = true
  enable_private_endpoint = true

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
  tier                    = "db-custom-4-15360"
  disk_size               = 100
  disk_autoresize_limit   = 500
  availability_type       = "REGIONAL"
  backup_retained_backups = 35
  deletion_protection     = true
  enable_insights         = true
  kms_key_id              = module.security.kms_key_id

  labels = local.common_labels
}

module "monitoring" {
  source = "../../modules/monitoring"

  project     = var.project
  environment = var.environment
  project_id  = var.project_id

  # REQUIRED: set actual email addresses before deploying
  alarm_email_endpoints = var.alarm_emails

  alert_policies = {
    high-cpu = {
      description     = "Average CPU utilization exceeds 80% for 5 minutes"
      metric_type     = "compute.googleapis.com/instance/cpu/utilization"
      comparison      = "COMPARISON_GT"
      threshold_value = 0.8
      duration        = "300s"
    }
    cloud-sql-connections = {
      description     = "Cloud SQL database connections exceed 100"
      metric_type     = "cloudsql.googleapis.com/database/network/connections"
      comparison      = "COMPARISON_GT"
      threshold_value = 100
      duration        = "300s"
    }
  }

  labels = local.common_labels
}

# Cloud CDN -- uncomment when the GCS assets bucket or backend service is ready.
#
# module "cloud_cdn" {
#   source = "../../modules/cloud-cdn"
#
#   project                = var.project
#   environment            = var.environment
#   project_id             = var.project_id
#   origin_type            = "gcs"
#   gcs_bucket_name        = module.gcs.bucket_names["assets"]
#   ssl_certificate_id     = ""     # Google-managed SSL cert ID
#   cloud_armor_policy_id  = module.security.cloud_armor_policy_id
#   enable_cdn             = true
#
#   labels = local.common_labels
# }

# Cloud DNS -- uncomment when the domain and managed zone are ready.
#
# module "cloud_dns" {
#   source = "../../modules/cloud-dns"
#
#   project     = var.project
#   environment = var.environment
#   project_id  = var.project_id
#   create_zone = false
#   zone_id     = ""  # Existing managed zone name
#
#   records = {}
#
#   labels = local.common_labels
# }
