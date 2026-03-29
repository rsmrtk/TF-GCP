# Architecture

## Overview

This repository implements a production-grade GCP infrastructure using Terraform with a module-composition pattern. Each environment (dev, staging, prod) composes reusable child modules with environment-specific configurations.

## Design Principles

1. **Module Composition** — Reusable modules in `modules/` are composed by environment configurations in `environments/`
2. **State Isolation** — Each environment has its own GCS backend bucket
3. **Least Privilege** — Workload Identity Federation for CI/CD, scoped service accounts
4. **Encryption by Default** — Cloud KMS CMEK for all data at rest
5. **Progressive Delivery** — Sequential deployment: dev → staging → prod

## Network Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     VPC (10.0.0.0/16)                       │
│                                                             │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │  Public AZ-a │  │  Public AZ-b │  │  Public AZ-c │     │
│  │  10.0.0.0/24 │  │  10.0.1.0/24 │  │  10.0.2.0/24 │     │
│  │   Cloud LB   │  │   Cloud LB   │  │   Cloud LB   │     │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘     │
│         │                  │                  │             │
│  ┌──────┴───────┐  ┌──────┴───────┐  ┌──────┴───────┐     │
│  │ Private AZ-a │  │ Private AZ-b │  │ Private AZ-c │     │
│  │10.0.100.0/24 │  │10.0.101.0/24 │  │10.0.102.0/24 │     │
│  │ GKE, GCE, CR │  │ GKE, GCE, CR │  │ GKE, GCE, CR │     │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘     │
│         │                  │                  │             │
│  ┌──────┴───────┐  ┌──────┴───────┐  ┌──────┴───────┐     │
│  │  Data AZ-a   │  │  Data AZ-b   │  │  Data AZ-c   │     │
│  │10.0.200.0/24 │  │10.0.201.0/24 │  │10.0.202.0/24 │     │
│  │  Cloud SQL   │  │  Cloud SQL   │  │  Cloud SQL   │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│                                                             │
│  Cloud NAT + Cloud Router, Private Google Access            │
└─────────────────────────────────────────────────────────────┘
```

## Module Dependency Graph

```
environments/{env}/main.tf
├── modules/networking      (VPC, subnets, Cloud NAT, Cloud Router)
├── modules/security        (Cloud KMS, firewall rules, Cloud Armor)
│   └── depends on: networking
├── modules/iam             (service accounts, IAM bindings)
│   └── depends on: security
├── modules/gcs             (Cloud Storage buckets, lifecycle)
│   └── depends on: security
├── modules/artifact-registry (container registries, cleanup)
│   └── depends on: security
├── modules/compute         (GCE, MIG, HTTP(S) Load Balancer)
│   └── depends on: networking, security, iam
├── modules/gke             (GKE cluster, node pools, Workload Identity)
│   └── depends on: networking, security
├── modules/cloud-run       (Cloud Run services)
│   └── depends on: iam
├── modules/cloud-sql       (Cloud SQL, Secret Manager)
│   └── depends on: networking, security
├── modules/cloud-functions (Cloud Functions v2)
│   └── depends on: iam, security
├── modules/cloud-cdn       (Cloud CDN, backend buckets/services)
│   └── depends on: gcs, security
├── modules/cloud-dns       (Cloud DNS, DNSSEC)
└── modules/monitoring      (Cloud Monitoring, alerting, dashboards)
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
| Deletion Protection | Off | On (Cloud SQL) | On (all) |

## CI/CD Pipeline

```
Push to feature branch
  └── terraform-validate.yml (fmt, validate, tflint, checkov)

Pull Request to main
  └── terraform-plan.yml (plan for all envs, post to PR)

Merge to main
  └── terraform-apply.yml (dev → staging → prod, sequential)

Weekday schedule
  └── drift-detection.yml (plan -detailed-exitcode, create issue on drift)
```

## State Management

- **Backend**: GCS with versioning and encryption
- **Locking**: Built-in GCS state locking (no separate lock table needed)
- **Isolation**: One bucket per environment
- **Bootstrap**: `global/backend-bootstrap/` must be applied first
