# Backend Bootstrap

Provisions the GCS buckets used for Terraform remote state. GCS provides built-in state locking, so no separate lock table is needed (unlike AWS S3+DynamoDB).

## Usage

```bash
cd global/backend-bootstrap
terraform init
terraform apply
```

> **Note:** This must be applied before any other environment. State for this module is stored locally.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
