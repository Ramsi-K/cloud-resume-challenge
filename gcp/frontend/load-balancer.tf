# Reserve global IP address
resource "google_compute_global_address" "website" {
  name = "${var.project_name}-ip"
}

# Backend bucket
resource "google_compute_backend_bucket" "website" {
  name        = "${var.project_name}-backend"
  bucket_name = google_storage_bucket.website.name
  enable_cdn  = true

  cdn_policy {
    cache_mode        = "CACHE_ALL_STATIC"
    default_ttl       = 3600
    max_ttl           = 86400
    client_ttl        = 3600
    negative_caching  = true
  }
}

# URL map
resource "google_compute_url_map" "website" {
  name            = "${var.project_name}-url-map"
  default_service = google_compute_backend_bucket.website.id
}

# HTTP proxy
resource "google_compute_target_http_proxy" "website" {
  name    = "${var.project_name}-http-proxy"
  url_map = google_compute_url_map.website.id
}

# HTTPS proxy (will be configured after SSL cert)
resource "google_compute_target_https_proxy" "website" {
  name             = "${var.project_name}-https-proxy"
  url_map          = google_compute_url_map.website.id
  ssl_certificates = [google_compute_managed_ssl_certificate.website.id]
}

# HTTP forwarding rule
resource "google_compute_global_forwarding_rule" "http" {
  name       = "${var.project_name}-http"
  target     = google_compute_target_http_proxy.website.id
  port_range = "80"
  ip_address = google_compute_global_address.website.address
}

# HTTPS forwarding rule
resource "google_compute_global_forwarding_rule" "https" {
  name       = "${var.project_name}-https"
  target     = google_compute_target_https_proxy.website.id
  port_range = "443"
  ip_address = google_compute_global_address.website.address
}