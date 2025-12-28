# Terraform State Management

This directory contains the foundational AWS infrastructure for the Cloud Resume Challenge project, including Terraform state management and GitHub Actions OIDC setup.

## Overview

This is the **first** Terraform configuration that should be deployed, as it creates the infrastructure needed by other Terraform configurations.

## What's Included

### State Management (`main.tf`)

- **S3 Bucket**: Stores Terraform state files with versioning and encryption
- **DynamoDB Table**: Provides state locking to prevent concurrent modifications
- **Security**: Public access blocked, server-side encryption enabled

### OIDC for GitHub Actions (`oidc.tf`)

- **OIDC Provider**: Allows GitHub Actions to authenticate to AWS without stored credentials
- **IAM Role**: Role that GitHub Actions assumes for deployments
- **Frontend Policy**: Permissions for S3 and CloudFront operations
- **Terraform Policy**: Permissions for managing AWS infrastructure via Terraform

## Security Features

### OIDC Trust Policy

The IAM role can only be assumed by:

- Repository: `Ramsi-K/cloud-resume-challenge`
- Branch: `main`
- Valid GitHub OIDC tokens with audience `sts.amazonaws.com`

### Minimal Permissions

- Frontend policy: Limited to specific S3 buckets and CloudFront operations
- Terraform policy: Scoped to resources needed for this project only
- No wildcard permissions except where necessary (e.g., CloudFront distributions)

## Deployment

```bash
# Initialize Terraform (first time only)
terraform init

# Validate configuration
terraform validate

# Review planned changes
terraform plan

# Apply changes
terraform apply
```

## Outputs

After deployment, the following outputs are available for use in other configurations:

- `state_bucket_name`: S3 bucket name for Terraform state
- `dynamodb_table_name`: DynamoDB table name for state locking
- `github_actions_role_arn`: IAM role ARN for GitHub Actions
- `github_oidc_provider_arn`: OIDC provider ARN

## Files

```
aws/state/
├── main.tf          # S3 bucket and DynamoDB table for state management
├── oidc.tf          # GitHub OIDC provider and IAM role
├── variables.tf     # Input variables
├── outputs.tf       # Output values
└── README.md        # This file
```

## Dependencies

- AWS CLI configured with appropriate permissions
- Terraform >= 1.0
- AWS provider ~> 5.0

## Notes

- This configuration uses local state initially
- Once deployed, other configurations use remote state in the created S3 bucket
- The OIDC setup enables passwordless GitHub Actions deployments
- All resources are tagged for easy identification and cost tracking
