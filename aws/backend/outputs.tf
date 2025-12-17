# Output Values for Backend Infrastructure

output "dynamodb_table_name" {
  description = "Name of the DynamoDB table"
  value       = aws_dynamodb_table.visitor_counter.name
}

output "dynamodb_table_arn" {
  description = "ARN of the DynamoDB table"
  value       = aws_dynamodb_table.visitor_counter.arn
}

output "aws_region" {
  description = "AWS region"
  value       = var.aws_region
}

output "project_name" {
  description = "Project name"
  value       = var.project_name
}
output "lambda_function_name" {
  description = "Name of the visitor counter Lambda function"
  value       = aws_lambda_function.visitor_counter.function_name
}

output "lambda_function_arn" {
  description = "ARN of the visitor counter Lambda function"
  value       = aws_lambda_function.visitor_counter.arn
}
output "api_gateway_url" {
  description = "URL of the API Gateway"
  value       = "${aws_api_gateway_stage.visitor_counter_api.invoke_url}/visitor-count"
}

output "api_gateway_id" {
  description = "ID of the API Gateway"
  value       = aws_api_gateway_rest_api.visitor_counter_api.id
}
output "api_custom_domain_name" {
  description = "Regional domain name for API Gateway custom domain"
  value       = aws_api_gateway_domain_name.api.regional_domain_name
}

output "api_custom_domain_zone_id" {
  description = "Regional zone ID for API Gateway custom domain"
  value       = aws_api_gateway_domain_name.api.regional_zone_id
}