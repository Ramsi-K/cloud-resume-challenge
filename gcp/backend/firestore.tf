# Firestore API is already enabled manually via gcloud
# Removed google_project_service resource to avoid permission issues

# Firestore Database
resource "google_firestore_database" "main" {
  project     = var.project_id
  name        = "(default)"
  location_id = var.region
  type        = "FIRESTORE_NATIVE"

  depends_on = [google_firestore_database.main]
}

# Create visitor counter document (initial setup)
resource "google_firestore_document" "visitor_counter" {
  project     = var.project_id
  collection  = "counters"
  document_id = "visitor_count"
  fields = jsonencode({
    count = {
      integerValue = "0"
    }
    last_updated = {
      timestampValue = timestamp()
    }
  })

  depends_on = [google_firestore_database.main]
}