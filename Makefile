ENV     ?= dev
TF_DIR  := environments/$(ENV)
MODULES := networking security iam gcs artifact-registry compute gke cloud-run cloud-sql cloud-functions cloud-cdn cloud-dns monitoring

.PHONY: help init init-upgrade plan plan-target apply apply-auto destroy \
        fmt fmt-check validate validate-all lint security docs \
        pre-commit bootstrap clean cost graph

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

init: ## Initialize Terraform (ENV=dev)
	cd $(TF_DIR) && terraform init

init-upgrade: ## Initialize with provider upgrade (ENV=dev)
	cd $(TF_DIR) && terraform init -upgrade

plan: ## Run terraform plan (ENV=dev)
	cd $(TF_DIR) && terraform plan -out=tfplan

plan-target: ## Plan a specific target (ENV=dev TARGET=module.networking)
	cd $(TF_DIR) && terraform plan -target=$(TARGET) -out=tfplan

apply: ## Apply saved plan (ENV=dev)
	cd $(TF_DIR) && terraform apply tfplan

apply-auto: ## Apply without confirmation -- use with caution (ENV=dev)
	cd $(TF_DIR) && terraform apply -auto-approve

destroy: ## Destroy infrastructure (ENV=dev)
	cd $(TF_DIR) && terraform destroy

fmt: ## Format all Terraform files
	terraform fmt -recursive

fmt-check: ## Check formatting without modifying files
	terraform fmt -check -recursive

validate: ## Validate Terraform configuration (ENV=dev)
	cd $(TF_DIR) && terraform init -backend=false -input=false && terraform validate

validate-all: ## Validate all environments
	@for env in dev staging prod; do \
		echo "==> Validating $$env..."; \
		(cd environments/$$env && terraform init -backend=false -input=false > /dev/null 2>&1 && terraform validate) || exit 1; \
	done

lint: ## Run TFLint
	tflint --recursive --config "$$(pwd)/.tflint.hcl"

security: ## Run Checkov security scan
	checkov -d . --framework terraform --config-file .checkov.yaml

docs: ## Generate module documentation
	@for mod in $(MODULES); do \
		echo "==> Generating docs for $$mod..."; \
		terraform-docs markdown table --output-file README.md --output-mode inject modules/$$mod; \
	done

pre-commit: ## Run all pre-commit hooks
	pre-commit run --all-files

bootstrap: ## Bootstrap state backend
	cd global/backend-bootstrap && terraform init && terraform apply

clean: ## Remove .terraform directories and plan files
	find . -type d -name ".terraform" -exec rm -rf {} + 2>/dev/null || true
	find . -name "*.tfplan" -delete 2>/dev/null || true
	find . -name "tfplan" -delete 2>/dev/null || true

cost: ## Estimate infrastructure costs (ENV=dev)
	infracost breakdown --path $(TF_DIR)

graph: ## Generate dependency graph (ENV=dev)
	cd $(TF_DIR) && terraform graph | dot -Tpng > ../../docs/graph-$(ENV).png
