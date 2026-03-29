output "repository_ids" {
  description = "Map of repository keys to their Artifact Registry repository IDs."
  value = {
    for key, repo in google_artifact_registry_repository.this : key => repo.id
  }
}

output "repository_urls" {
  description = "Map of repository keys to their Docker registry URLs (REGION-docker.pkg.dev/PROJECT_ID/REPO_NAME)."
  value = {
    for key, repo in google_artifact_registry_repository.this : key => "${var.region}-docker.pkg.dev/${var.project_id}/${repo.repository_id}"
  }
}
