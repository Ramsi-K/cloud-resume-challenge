# Cloud DNS Zone
resource "google_dns_managed_zone" "website" {
  name        = "${var.project_name}-zone"
  dns_name    = "${var.domain_name}."
  description = "DNS zone for resume website"
}

# A record for apex domain
resource "google_dns_record_set" "apex" {
  name         = google_dns_managed_zone.website.dns_name
  managed_zone = google_dns_managed_zone.website.name
  type         = "A"
  ttl          = 300

  rrdatas = [google_compute_global_address.website.address]
}

# A record for www subdomain
resource "google_dns_record_set" "www" {
  name         = "www.${google_dns_managed_zone.website.dns_name}"
  managed_zone = google_dns_managed_zone.website.name
  type         = "A"
  ttl          = 300

  rrdatas = [google_compute_global_address.website.address]
}