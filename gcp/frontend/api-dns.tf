# DNS record for API subdomain (for future backend services)
# Note: GCP deployment will only have visitor counter, not AI features
resource "google_dns_record_set" "api" {
  name         = "api.${google_dns_managed_zone.website.dns_name}"
  managed_zone = google_dns_managed_zone.website.name
  type         = "A"
  ttl          = 300

  # Placeholder IP - will be updated when backend is deployed
  rrdatas = ["127.0.0.1"]
}