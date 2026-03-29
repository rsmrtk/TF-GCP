# -----------------------------------------------------------------------------
# Workload Identity
# -----------------------------------------------------------------------------
#
# Workload Identity is enabled at the cluster level via workload_identity_config
# in cluster.tf. This file exposes the Workload Identity pool identifier for use
# by other modules (e.g., binding Kubernetes service accounts to GCP service
# accounts).
#
# The Workload Identity pool follows the format: <project_id>.svc.id.goog
#
# Usage pattern (in consuming modules):
#   1. Create a GCP service account
#   2. Bind the KSA to the GSA:
#      gcloud iam service-accounts add-iam-policy-binding \
#        --role roles/iam.workloadIdentityUser \
#        --member "serviceAccount:<project_id>.svc.id.goog[<namespace>/<ksa_name>]" \
#        <gsa_name>@<project_id>.iam.gserviceaccount.com
#   3. Annotate the KSA:
#      kubectl annotate serviceaccount <ksa_name> \
#        iam.gke.io/gcp-service-account=<gsa_name>@<project_id>.iam.gserviceaccount.com

locals {
  workload_identity_pool = "${var.project_id}.svc.id.goog"
}
