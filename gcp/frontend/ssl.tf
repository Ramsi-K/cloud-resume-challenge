# Managed SSL Certificate
resource "google_compute_managed_ssl_certificate" "website" {
  name = "${var.project_name}-cert"

  managed {
    domains = [
      var.domain_name,
      "www.${var.domain_name}"
    ]
  }

  lifecycle {
    create_before_destroy = true
  }
}