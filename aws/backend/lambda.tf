# Lambda Function for Visitor Counter

# Create deployment package
data "archive_file" "visitor_counter_zip" {
  type        = "zip"
  source_file = "${path.module}/lambda/visitor_counter.py"
  output_path = "${path.module}/lambda/visitor_counter.zip"
}

# IAM role for Lambda function
resource "aws_iam_role" "visitor_counter_lambda_role" {
  name = "${var.project_name}-visitor-counter-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name = "Visitor Counter Lambda Role"
  }
}

# IAM policy for Lambda to access DynamoDB
resource "aws_iam_policy" "visitor_counter_lambda_policy" {
  name        = "${var.project_name}-visitor-counter-lambda-policy"
  description = "IAM policy for visitor counter Lambda function"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:${var.aws_region}:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:UpdateItem"
        ]
        Resource = aws_dynamodb_table.visitor_counter.arn
      }
    ]
  })
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "visitor_counter_lambda_policy_attachment" {
  role       = aws_iam_role.visitor_counter_lambda_role.name
  policy_arn = aws_iam_policy.visitor_counter_lambda_policy.arn
}

# Lambda function
resource "aws_lambda_function" "visitor_counter" {
  filename         = data.archive_file.visitor_counter_zip.output_path
  function_name    = "${var.project_name}-visitor-counter"
  role            = aws_iam_role.visitor_counter_lambda_role.arn
  handler         = "visitor_counter.lambda_handler"
  runtime         = "python3.11"
  timeout         = 10

  source_code_hash = data.archive_file.visitor_counter_zip.output_base64sha256

  environment {
    variables = {
      DYNAMODB_TABLE_NAME = aws_dynamodb_table.visitor_counter.name
    }
  }

  tags = {
    Name = "Visitor Counter Function"
  }
}

# CloudWatch Log Group for Lambda
resource "aws_cloudwatch_log_group" "visitor_counter_logs" {
  name              = "/aws/lambda/${aws_lambda_function.visitor_counter.function_name}"
  retention_in_days = 7  # Keep logs for 7 days (cost optimization)

  tags = {
    Name = "Visitor Counter Lambda Logs"
  }
}