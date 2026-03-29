# Global IAM

Provisions IAM resources for Terraform execution:

- **Workload Identity Pool + Provider** — federated identity for keyless CI/CD via GitHub Actions OIDC
- **Plan Service Account** — read-only, scoped to pull request events
- **Apply Service Account** — editor, scoped to main branch pushes
- **Execution Service Account** — for local development

## Usage

```bash
cd global/iam
terraform init
terraform apply
```

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
