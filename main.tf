# Example 1: Creating a local file + editing.
# Use cases:
## 1) If you update the local file without updating TF => tf apply overrides local changes and aplies main.tf properties
## 2) If you update the local file's name without updating TF file => tf apply creates a new file as it is specified in main.tf properties without deleting the updated file. 

# resource "local_file" "foo" {

#  content = "Hello world!"
#  # content  = "time: ${timestamp()}\n"
#  filename = "delete_me.txt"
# }

# output "filename" {
#  value = local_file.foo.filename
# }

#######
# Example 2: Creating a minimal GCP resource (bucket)

# resource "google_storage_bucket" "bucket" {
#     name      = "bucket-lydia-test"
#     location  = "US"
# }

# Example 3: Adding supporting resource (random name generator)
resource "random_pet" "random" {
 length = 2
 separator = "-"
}

resource "google_storage_bucket" "bucket_var_name" {
    name      = "bucket-lydia-${random_pet.random.id}"
    location  = "US"
}

# Example 4: Adding variables
resource "google_storage_bucket" "bucket_var_location" {
    name      = "bucket-lydia-2-${random_pet.random.id}"
    location  = var.bucket_location
}