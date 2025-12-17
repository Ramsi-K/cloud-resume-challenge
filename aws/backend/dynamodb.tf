# DynamoDB Table for Visitor Counter
# Uses on-demand billing for cost optimization

resource "aws_dynamodb_table" "visitor_counter" {
  name           = "${var.project_name}-visitor-counter"
  billing_mode   = "PAY_PER_REQUEST"  # On-demand pricing (essentially free for low usage)
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"  # String
  }

  tags = {
    Name        = "Visitor Counter Table"
    Project     = var.project_name
    Environment = "production"
    ManagedBy   = "terraform"
  }
}

# Initialize the counter with a default value
resource "aws_dynamodb_table_item" "visitor_counter_init" {
  table_name = aws_dynamodb_table.visitor_counter.name
  hash_key   = aws_dynamodb_table.visitor_counter.hash_key

  item = jsonencode({
    id = {
      S = "total"
    }
    visit_count = {
      N = "0"
    }
  })

  # Only create if item doesn't exist
  lifecycle {
    ignore_changes = [item]
  }
}