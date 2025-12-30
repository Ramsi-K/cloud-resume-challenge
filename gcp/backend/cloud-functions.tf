# APIs are already enabled manually via gcloud
# Removed google_project_service resources to avoid permission issues

# Create ZIP archive of function source
data "archive_file" "visitor_counter_zip" {
  type        = "zip"
  source_dir  = "${path.module}/functions/visitor-counter"
  output_path = "${path.module}/visitor-counter.zip"
}

# Cloud Storage bucket for function source
resource "google_storage_bucket" "function_source" {
  name          = "${var.project_id}-function-source"
  location      = "US"
  force_destroy = true

  uniform_bucket_level_access = true
  
  labels = var.common_tags
}

# Upload function source to bucket
resource "google_storage_bucket_object" "visitor_counter_source" {
  name   = "visitor-counter-${data.archive_file.visitor_counter_zip.output_md5}.zip"
  bucket = google_storage_bucket.function_source.name
  source = data.archive_file.visitor_counter_zip.output_path
}

# Service account for Cloud Function
resource "google_service_account" "function_sa" {
  account_id   = "crc-function-sa"
  display_name = "Cloud Function Service Account"
  description  = "Service account for visitor counter function"
}

# Grant Firestore access to function service account
resource "google_project_iam_member" "function_firestore" {
  project = var.project_id
  role    = "roles/datastore.user"
  member  = "serviceAccount:${google_service_account.function_sa.email}"
}

# Cloud Function (Gen 2)
resource "google_cloudfunctions2_function" "visitor_counter" {
  name        = "${var.project_name}-visitor-counter"
  location    = var.region
  description = "Visitor counter API with rate limiting"

  build_config {
    runtime     = "python311"
    entry_point = "visitor_counter"
    
    source {
      storage_source {
        bucket = google_storage_bucket.function_source.name
        object = google_storage_bucket_object.visitor_counter_source.name
      }
    }
  }

  service_config {
    max_instance_count = 10
    min_instance_count = 0
    available_memory   = "256M"
    timeout_seconds    = 60
    
    environment_variables = {
      GOOGLE_CLOUD_PROJECT = var.project_id
    }
    
    service_account_email = google_service_account.function_sa.email
  }

  depends_on = [
    google_firestore_database.main
  ]
}

# Make function publicly accessible
resource "google_cloudfunctions2_function_iam_member" "public_access" {
  project        = var.project_id
  location       = var.region
  cloud_function = google_cloudfunctions2_function.visitor_counter.name
  role           = "roles/cloudfunctions.invoker"
  member         = "allUsers"
}