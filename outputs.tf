output "name" {
 description = "Bucket name."
 value       = google_storage_bucket.bucket_var_name.name
 # optional sensitive attribute, not needed here
 sensitive = false
 # optional depends_on, not useful here
 depends_on = [random_pet.random]
}
