output "bucket_ids" {
  description = "Map of bucket keys to their unique GCS bucket IDs."
  value = {
    for key, bucket in google_storage_bucket.this : key => bucket.id
  }
}

output "bucket_names" {
  description = "Map of bucket keys to their GCS bucket names."
  value = {
    for key, bucket in google_storage_bucket.this : key => bucket.name
  }
}

output "bucket_urls" {
  description = "Map of bucket keys to their GCS bucket URLs (gs:// format)."
  value = {
    for key, bucket in google_storage_bucket.this : key => bucket.url
  }
}

output "bucket_self_links" {
  description = "Map of bucket keys to their GCS bucket self links."
  value = {
    for key, bucket in google_storage_bucket.this : key => bucket.self_link
  }
}
