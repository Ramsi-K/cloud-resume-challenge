# API Gateway Custom Domain Configuration

# Custom domain name for API Gateway
resource "aws_api_gateway_domain_name" "api" {
  domain_name              = "api.${var.domain_name}"
  regional_certificate_arn = "arn:aws:acm:us-east-1:845822318516:certificate/a21c0fc9-96ec-4921-9ede-c8cece882143"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = {
    Name = "API Custom Domain"
  }
}

# Base path mapping to connect custom domain to API Gateway stage
resource "aws_api_gateway_base_path_mapping" "api" {
  api_id      = aws_api_gateway_rest_api.visitor_counter_api.id
  stage_name  = aws_api_gateway_stage.visitor_counter_api.stage_name
  domain_name = aws_api_gateway_domain_name.api.domain_name
}