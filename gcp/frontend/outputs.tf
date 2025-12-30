output "project_id" {
  description = "GCP project ID"
  value       = var.project_id
}

output "region" {
  description = "GCP region used"
  value       = var.region
}

output "project_name" {
  description = "Project name"
  value       = var.project_name
}

# Storage Bucket Outputs
output "bucket_name" {
  description = "Name of the GCS bucket"
  value       = google_storage_bucket.website.name
}

output "bucket_url" {
  description = "URL of the GCS bucket"
  value       = google_storage_bucket.website.url
}

# Load Balancer Outputs
output "load_balancer_ip" {
  description = "Load balancer IP address"
  value       = google_compute_global_address.website.address
}

output "cloudfront_equivalent_url" {
  description = "Load balancer URL (CloudFront equivalent)"
  value       = "http://${google_compute_global_address.website.address}"
}

# SSL Certificate Outputs
output "ssl_certificate_name" {
  description = "Name of the managed SSL certificate"
  value       = google_compute_managed_ssl_certificate.website.name
}

# DNS Outputs
output "dns_zone_name" {
  description = "Cloud DNS zone name"
  value       = google_dns_managed_zone.website.name
}

output "dns_name_servers" {
  description = "Cloud DNS name servers"
  value       = google_dns_managed_zone.website.name_servers
}

output "website_url" {
  description = "Final website URL"
  value       = "https://${var.domain_name}"
}

output "api_subdomain" {
  description = "API subdomain (for future backend)"
  value       = "api.${var.domain_name}"
}