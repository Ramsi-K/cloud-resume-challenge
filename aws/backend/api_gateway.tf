# API Gateway for Visitor Counter

# REST API
resource "aws_api_gateway_rest_api" "visitor_counter_api" {
  name        = "${var.project_name}-api"
  description = "API for cloud resume challenge backend services"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = {
    Name = "Cloud Resume Challenge API"
  }
}

# Resource for visitor counter
resource "aws_api_gateway_resource" "visitor_counter" {
  rest_api_id = aws_api_gateway_rest_api.visitor_counter_api.id
  parent_id   = aws_api_gateway_rest_api.visitor_counter_api.root_resource_id
  path_part   = "visitor-count"
}

# OPTIONS method for CORS preflight
resource "aws_api_gateway_method" "visitor_counter_options" {
  rest_api_id   = aws_api_gateway_rest_api.visitor_counter_api.id
  resource_id   = aws_api_gateway_resource.visitor_counter.id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

# OPTIONS integration
resource "aws_api_gateway_integration" "visitor_counter_options" {
  rest_api_id = aws_api_gateway_rest_api.visitor_counter_api.id
  resource_id = aws_api_gateway_resource.visitor_counter.id
  http_method = aws_api_gateway_method.visitor_counter_options.http_method
  type        = "MOCK"

  request_templates = {
    "application/json" = jsonencode({
      statusCode = 200
    })
  }
}

# OPTIONS method response
resource "aws_api_gateway_method_response" "visitor_counter_options" {
  rest_api_id = aws_api_gateway_rest_api.visitor_counter_api.id
  resource_id = aws_api_gateway_resource.visitor_counter.id
  http_method = aws_api_gateway_method.visitor_counter_options.http_method
  status_code = "200"

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true
    "method.response.header.Access-Control-Allow-Methods" = true
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

# OPTIONS integration response
resource "aws_api_gateway_integration_response" "visitor_counter_options" {
  rest_api_id = aws_api_gateway_rest_api.visitor_counter_api.id
  resource_id = aws_api_gateway_resource.visitor_counter.id
  http_method = aws_api_gateway_method.visitor_counter_options.http_method
  status_code = aws_api_gateway_method_response.visitor_counter_options.status_code

  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'"
    "method.response.header.Access-Control-Allow-Methods" = "'GET,POST,OPTIONS'"
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

# POST method for incrementing counter
resource "aws_api_gateway_method" "visitor_counter_post" {
  rest_api_id   = aws_api_gateway_rest_api.visitor_counter_api.id
  resource_id   = aws_api_gateway_resource.visitor_counter.id
  http_method   = "POST"
  authorization = "NONE"
}

# POST integration with Lambda
resource "aws_api_gateway_integration" "visitor_counter_post" {
  rest_api_id = aws_api_gateway_rest_api.visitor_counter_api.id
  resource_id = aws_api_gateway_resource.visitor_counter.id
  http_method = aws_api_gateway_method.visitor_counter_post.http_method

  integration_http_method = "POST"
  type                   = "AWS_PROXY"
  uri                    = aws_lambda_function.visitor_counter.invoke_arn
}

# GET method for retrieving current count
resource "aws_api_gateway_method" "visitor_counter_get" {
  rest_api_id   = aws_api_gateway_rest_api.visitor_counter_api.id
  resource_id   = aws_api_gateway_resource.visitor_counter.id
  http_method   = "GET"
  authorization = "NONE"
}

# GET integration with Lambda
resource "aws_api_gateway_integration" "visitor_counter_get" {
  rest_api_id = aws_api_gateway_rest_api.visitor_counter_api.id
  resource_id = aws_api_gateway_resource.visitor_counter.id
  http_method = aws_api_gateway_method.visitor_counter_get.http_method

  integration_http_method = "POST"  # Lambda always uses POST
  type                   = "AWS_PROXY"
  uri                    = aws_lambda_function.visitor_counter.invoke_arn
}

# Lambda permission for API Gateway to invoke the function
resource "aws_lambda_permission" "api_gateway_invoke" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.visitor_counter.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.visitor_counter_api.execution_arn}/*/*"
}

# Usage Plan for rate limiting
resource "aws_api_gateway_usage_plan" "visitor_counter_plan" {
  name         = "${var.project_name}-usage-plan"
  description  = "Usage plan for visitor counter API"

  api_stages {
    api_id = aws_api_gateway_rest_api.visitor_counter_api.id
    stage  = aws_api_gateway_stage.visitor_counter_api.stage_name
  }

  throttle_settings {
    rate_limit  = 100  # 100 requests per second
    burst_limit = 200  # 200 requests burst
  }

  quota_settings {
    limit  = 10000  # 10,000 requests per day
    period = "DAY"
  }

  tags = {
    Name = "Visitor Counter Usage Plan"
  }
}

# API Deployment
resource "aws_api_gateway_deployment" "visitor_counter_api" {
  depends_on = [
    aws_api_gateway_method.visitor_counter_options,
    aws_api_gateway_method.visitor_counter_post,
    aws_api_gateway_method.visitor_counter_get,
    aws_api_gateway_integration.visitor_counter_options,
    aws_api_gateway_integration.visitor_counter_post,
    aws_api_gateway_integration.visitor_counter_get,
  ]

  rest_api_id = aws_api_gateway_rest_api.visitor_counter_api.id

  lifecycle {
    create_before_destroy = true
  }
}

# API Gateway Stage
resource "aws_api_gateway_stage" "visitor_counter_api" {
  deployment_id = aws_api_gateway_deployment.visitor_counter_api.id
  rest_api_id   = aws_api_gateway_rest_api.visitor_counter_api.id
  stage_name    = "prod"

  tags = {
    Name = "Visitor Counter API Stage"
  }
}