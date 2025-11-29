# Terraform Backend Configuration
# This tells Terraform where to store its state file
# Currently using local state (terraform.tfstate in this directory)

terraform {
  required_version = ">= 1.7"

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
