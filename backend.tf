terraform {
    backend "gcs" {
        # would you use the outputs bucket?
        bucket = "my-backend-bucket"
        prefix = "gdg-madrid/tf-workshop"
    }
}