# Route 53 record for API subdomain
resource "aws_route53_record" "api" {
  zone_id = aws_route53_zone.main.zone_id
  name    = "api.${var.domain_name}"
  type    = "A"

  alias {
    name                   = "d-9zc33jt8n4.execute-api.us-east-1.amazonaws.com"
    zone_id                = "Z1UJRXOUMOOFQ8"  # API Gateway zone ID for us-east-1
    evaluate_target_health = false
  }
}