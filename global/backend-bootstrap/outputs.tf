output "state_bucket_names" {
  description = "Map of environment name to GCS bucket name."
  value = {
    for env, bucket in google_storage_bucket.terraform_state :
    env => bucket.name
  }
}

output "state_bucket_urls" {
  description = "Map of environment name to GCS bucket URL (gs://…)."
  value = {
    for env, bucket in google_storage_bucket.terraform_state :
    env => "gs://${bucket.name}"
  }
}
