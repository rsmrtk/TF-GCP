################################################################################
# Cloud Functions
################################################################################

output "function_uris" {
  description = "Map of function keys to their HTTPS trigger URIs."
  value = {
    for key, fn in google_cloudfunctions2_function.this : key => fn.service_config[0].uri
  }
}

output "function_names" {
  description = "Map of function keys to their deployed function names."
  value = {
    for key, fn in google_cloudfunctions2_function.this : key => fn.name
  }
}
