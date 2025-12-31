# DNS record for API subdomain pointing to GCP Cloud Function
# Note: GCP deployment will only have visitor counter, not AI features
resource "google_dns_record_set" "api" {
  name         = "api.${google_dns_managed_zone.website.dns_name}"
  managed_zone = google_dns_managed_zone.website.name
  type         = "CNAME"
  ttl          = 300

  # Point to GCP Cloud Functions domain
  rrdatas = ["us-central1-cloud-resume-challenge-482812.cloudfunctions.net."]
}