# Terraform Backend Configuration
# Uses remote state in S3 with DynamoDB locking

terraform {
  required_version = ">= 1.0"

  backend "s3" {
    bucket         = "terraform-state-cloud-resume-challenge-us-east-1"
    key            = "backend/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# AWS Provider Configuration
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = "production"
      ManagedBy   = "terraform"
    }
  }
}