output "project_id" {
  description = "GCP project ID"
  value       = var.project_id
}

output "region" {
  description = "GCP region used"
  value       = var.region
}

# Firestore Database
output "firestore_database" {
  description = "Firestore database name"
  value       = google_firestore_database.main.name
}

# Cloud Function
output "visitor_counter_function_name" {
  description = "Visitor counter function name"
  value       = google_cloudfunctions2_function.visitor_counter.name
}

output "visitor_counter_function_url" {
  description = "Visitor counter function URL"
  value       = google_cloudfunctions2_function.visitor_counter.service_config[0].uri
}

output "api_endpoint" {
  description = "API endpoint for visitor counter"
  value       = "https://${var.region}-${var.project_id}.cloudfunctions.net/${google_cloudfunctions2_function.visitor_counter.name}"
}

# API Gateway (if implemented)
output "api_domain" {
  description = "API domain for custom domain"
  value       = "api.${var.domain_name}"
}