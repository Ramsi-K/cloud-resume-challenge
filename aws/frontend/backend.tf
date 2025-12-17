# Terraform Backend Configuration
# Uses remote state in S3 with DynamoDB locking

terraform {
  required_version = ">= 1.7"

  backend "s3" {
    bucket         = "terraform-state-cloud-resume-challenge-us-east-1"
    key            = "frontend/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
    profile        = "ramsi_admin_access"
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
  region  = var.aws_region
  profile = var.aws_profile

  default_tags {
    tags = {
      Project     = "cloud-resume-challenge"
      Environment = "production"
      ManagedBy   = "terraform"
    }
  }
}
