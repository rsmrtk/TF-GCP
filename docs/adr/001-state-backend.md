# ADR 001: State Backend

## Status

Accepted

## Context

Terraform state must be stored remotely to enable team collaboration, state locking, and disaster recovery. Options considered:

1. **GCS** — native GCP backend with built-in locking
2. **Terraform Cloud** — managed service
3. **Consul** — HashiCorp's KV store

## Decision

Use GCS per environment for state storage and locking.

## Rationale

- Native GCP integration with no additional service dependencies
- Built-in state locking (unlike AWS S3, no separate DynamoDB table required)
- Per-environment isolation prevents accidental cross-environment state corruption
- GCS versioning enables state history and rollback
- Cost-effective at any scale
- Encryption at rest via Google-managed or Cloud KMS keys
- Uniform bucket-level access for simplified IAM

## Consequences

- Must bootstrap state buckets before any environment deployment
- State bucket names must be globally unique
- GCS buckets are regional or multi-regional
