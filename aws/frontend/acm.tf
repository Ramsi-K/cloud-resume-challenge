# ACM Certificate for HTTPS
# IMPORTANT: Must be in us-east-1 for CloudFront

# Request SSL/TLS certificate
resource "aws_acm_certificate" "website" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  # Add www subdomain and wildcard for subdomains
  subject_alternative_names = [
    "www.${var.domain_name}",
    "*.${var.domain_name}"
  ]

  tags = {
    Name = "Resume Website Certificate"
  }

  # Create new certificate before destroying old one
  lifecycle {
    create_before_destroy = true
  }
}

# DNS validation records
# These prove you own the domain
resource "aws_acm_certificate_validation" "website" {
  certificate_arn = aws_acm_certificate.website.arn

  # Wait for DNS validation to complete
  timeouts {
    create = "10m"
  }
}
