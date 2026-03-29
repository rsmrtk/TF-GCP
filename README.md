# TF-GCP: Production-Grade Terraform GCP Infrastructure

Production-ready, multi-environment GCP infrastructure managed with Terraform. Demonstrates reusable modules, CI/CD with Workload Identity Federation, security best practices, and progressive deployment.

## Architecture

```
TF-GCP/
├── global/                  # One-time setup (state backend, CI/CD IAM)
├── modules/                 # 14 reusable Terraform modules
│   ├── networking/          # VPC, subnets, Cloud NAT, Cloud Router
│   ├── security/            # Cloud KMS, firewall rules, Cloud Armor
│   ├── iam/                 # Service accounts, IAM bindings
│   ├── gcs/                 # Cloud Storage buckets, lifecycle, CMEK
│   ├── artifact-registry/   # Container registries, cleanup policies
│   ├── compute/             # GCE, MIG, HTTP(S) Load Balancer
│   ├── gke/                 # GKE cluster, node pools, Workload Identity
│   ├── cloud-run/           # Cloud Run services
│   ├── cloud-sql/           # Cloud SQL, Secret Manager
│   ├── cloud-functions/     # Cloud Functions v2
│   ├── cloud-cdn/           # Cloud CDN, backend buckets/services
│   ├── cloud-dns/           # Cloud DNS, DNSSEC
│   └── monitoring/          # Cloud Monitoring, alerting, dashboards
├── environments/            # Environment-specific compositions
│   ├── dev/                 # Minimal: single NAT, e2-micro, no HA
│   ├── staging/             # Medium: mirrors prod topology
│   └── prod/                # Full HA: multi-AZ, REGIONAL, deletion protection
├── .github/workflows/       # CI/CD pipelines
├── docs/                    # Architecture docs and ADRs
├── scripts/                 # Helper scripts
└── examples/                # Usage examples
```

## Quick Start

### Prerequisites

- [Terraform](https://www.terraform.io/downloads) >= 1.9.0
- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) configured with appropriate credentials
- [TFLint](https://github.com/terraform-linters/tflint) (optional, for linting)
- [Checkov](https://www.checkov.io/) (optional, for security scanning)

### 1. Bootstrap State Backend

```bash
cd global/backend-bootstrap
terraform init
terraform apply
```

### 2. Deploy an Environment

```bash
make init ENV=dev
make plan ENV=dev
make apply ENV=dev
```

### 3. Validate All Configurations

```bash
make fmt-check
make validate-all
make lint
make security
```

## Environment Sizing

| Resource | Dev | Staging | Prod |
|---|---|---|---|
| AZs | 2 | 3 | 3 |
| Cloud NAT | 1 (shared) | 1 (shared) | Per-AZ |
| GKE Nodes | 1x e2-medium | 2x e2-standard-2 | 3x e2-standard-8 |
| Cloud SQL | db-f1-micro, ZONAL | db-custom-2-7680, ZONAL | db-custom-4-15360, REGIONAL |
| Backup Retention | 7 days | 14 days | 35 days |
| Cloud Armor | Disabled | Preview mode | Block mode |

## CI/CD Pipeline

| Trigger | Workflow | Action |
|---|---|---|
| Every push | `terraform-validate.yml` | Format, validate, lint, security scan |
| Pull request | `terraform-plan.yml` | Plan all envs, post to PR comment |
| Merge to main | `terraform-apply.yml` | Sequential apply: dev → staging → prod |
| Weekday schedule | `drift-detection.yml` | Detect drift, create GitHub issue |

Authentication uses **Workload Identity Federation** — no long-lived GCP credentials.

## Key Design Patterns

- **Module composition** — environments compose reusable child modules
- **Variable validation** — all inputs validated with custom rules
- **Lifecycle preconditions** — e.g., prod Cloud SQL must be REGIONAL
- **Dynamic subnet calculation** — `cidrsubnet()` for automatic CIDR allocation
- **Cloud KMS encryption** — CMEK for all data at rest
- **Uniform bucket access** — GCS buckets enforce uniform IAM
- **Workload Identity Federation** — keyless CI/CD via federated identity
- **Drift detection** — scheduled workflow with automated issue creation

## Makefile Commands

```
make help          # Show all commands
make init          # Initialize Terraform (ENV=dev)
make plan          # Run plan (ENV=dev)
make apply         # Apply plan (ENV=dev)
make destroy       # Destroy infrastructure (ENV=dev)
make fmt           # Format all files
make validate-all  # Validate all environments
make lint          # Run TFLint
make security      # Run Checkov
make docs          # Generate module documentation
make clean         # Remove .terraform and plans
```

## Documentation

- [Architecture Overview](docs/architecture.md)
- ADRs:
  - [001 - State Backend](docs/adr/001-state-backend.md)
  - [002 - Module Structure](docs/adr/002-module-structure.md)
  - [003 - Naming Convention](docs/adr/003-naming-convention.md)

## License

[MIT](LICENSE)
