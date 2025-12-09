---
title: Setting Up Terraform for AWS - A Complete Guide
date: 2025-11-29
categories:
  - Cloud Infrastructure
  - DevOps
  - AWS
tags:
  - Terraform
  - AWS
  - IaC
  - Tutorial
---

# Setting Up Terraform for AWS - My CRC Walkthrough

<div class="section-label">Tutorial</div>

This guide walks through setting up Terraform for AWS infrastructure management, from installing tools to understanding state management. This is part of my Cloud Resume Challenge journey where I'm deploying a multi-cloud resume website.

<!-- more -->

---

## Prerequisites

Before starting, you need:

- An AWS account
- Windows computer (commands shown for Windows, but concepts apply to all OS)
- Basic command line knowledge

---

## Step 1: AWS Authentication Setup

### Understanding AWS SSO vs IAM Users

**AWS SSO (Single Sign-On)** - What I used:

- Temporary credentials that auto-rotate
- More secure than static access keys
- Recommended for organizations and personal use

**IAM User with Access Keys** - Alternative:

- Static credentials (Access Key ID + Secret)
- Need manual rotation every 90 days
- Simpler for beginners

### My Setup: AWS SSO

I configured AWS SSO through my organization's identity provider. After setup, I verified it works:

```bash
aws sts get-caller-identity --profile ramsi_admin_access
```

**Output:**

```json
{
  "UserId": "AROA4J3XQK62E6GYZQBET:ramsi_admin_access",
  "Account": "845822318516",
  "Arn": "arn:aws:sts::845822318516:assumed-role/AWSReservedSSO_AdministratorAccess_f600b682105275a8/ramsi_admin_access"
}
```

<div class="section-label">Key Takeaway</div>

The `--profile ramsi_admin_access` flag tells AWS CLI which credentials to use. This profile is configured in `~/.aws/config`.

---

## Step 2: Install Terraform

### Using Windows Package Manager (winget)

```bash
winget install HashiCorp.Terraform
```

**Output:**

```
Found HashiCorp Terraform [Hashicorp.Terraform] Version 1.14.0
Downloading https://releases.hashicorp.com/terraform/1.14.0/terraform_1.14.0_windows_amd64.zip
Successfully verified installer hash
Extracting archive...
Path environment variable modified; restart your shell to use the new value.
Successfully installed
```

<div class="section-label">Important</div>

After installation, **restart your terminal** for the PATH changes to take effect.

### Verify Installation

```bash
terraform version
```

**Output:**

```
Terraform v1.14.0
on windows_amd64
```

---

## Step 3: Create Terraform Configuration

### Project Structure

For this tutorial, we're focusing on the AWS infrastructure setup:

```
cloud-resume-challenge/
├── docs/                   # Website source (MkDocs)
├── aws/
│   └── frontend/          # AWS frontend
│       ├── backend.tf     # Terraform & provider
│       ├── variables.tf   # Input variables
│       └── outputs.tf     # Output values
└── mkdocs.yml             # MkDocs configuration
```

### File 1: backend.tf

This file configures Terraform itself and the AWS provider.

```hcl
# Terraform Backend Configuration
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
```

**What this does:**

- `required_version`: Ensures Terraform 1.7 or newer
- `required_providers`: Downloads AWS provider plugin
- `provider "aws"`: Configures AWS connection with profile and region
- `default_tags`: Automatically tags all resources

### File 2: variables.tf

Input variables make your configuration reusable.

```hcl
variable "aws_region" {
  description = "AWS region for resources"
  type        = string
  default     = "us-east-1"
}

variable "aws_profile" {
  description = "AWS CLI profile to use"
  type        = string
  default     = "ramsi_admin_access"
}

variable "domain_name" {
  description = "Domain name for the website (apex domain)"
  type        = string
  default     = "ramsi.dev"
}

variable "domain_name_www" {
  description = "WWW subdomain (will redirect to apex)"
  type        = string
  default     = "www.ramsi.dev"
}

variable "project_name" {
  description = "Project name for resource naming"
  type        = string
  default     = "cloud-resume-challenge"
}
```

**Why variables?**

- Easy to change values without editing multiple files
- Can override defaults: `terraform apply -var="aws_region=us-west-2"`
- Makes code reusable across environments

### File 3: outputs.tf

Outputs display values after Terraform runs.

```hcl
output "aws_region" {
  description = "AWS region used"
  value       = var.aws_region
}

output "project_name" {
  description = "Project name"
  value       = var.project_name
}
```

**Use cases:**

- Display important values (bucket names, URLs)
- Pass values to other Terraform modules
- Use in scripts: `terraform output -raw aws_region`

---

## Step 4: Initialize Terraform

```bash
terraform -chdir=aws/frontend init
```

**What happens:**

1. Terraform reads `backend.tf`
2. Downloads AWS provider plugin (~200MB)
3. Creates `.terraform/` directory with plugins
4. Creates `.terraform.lock.hcl` (dependency lock file)

**Output:**

```bash
Initializing the backend...
Initializing provider plugins...
- Finding hashicorp/aws versions matching "~> 5.0"...
- Installing hashicorp/aws v5.100.0...
- Installed hashicorp/aws v5.100.0 (signed by HashiCorp)

Terraform has been successfully initialized!
```

<div class="section-label">Success</div>

You can now run `terraform plan` and `terraform apply`!

---

## Understanding Terraform State

### What is Terraform State?

The state file (`terraform.tfstate`) is Terraform's memory. It tracks:

- What resources exist in AWS
- Resource IDs and attributes
- Dependencies between resources

**Example state content:**

```json
{
  "resources": [
    {
      "type": "aws_s3_bucket",
      "name": "website",
      "instances": [
        {
          "attributes": {
            "id": "ramsi-resume-site",
            "arn": "arn:aws:s3:::ramsi-resume-site",
            "region": "us-east-1"
          }
        }
      ]
    }
  ]
}
```

### Local vs Remote State

#### Local State (What I'm Using)

**Location:** `aws/frontend/terraform.tfstate` (on your computer)

**Pros:**

- Simple setup (no extra configuration)
- Works immediately
- No additional AWS costs
- Good for solo projects and learning

**Cons:**

- Only accessible from your computer
- Risk of loss if computer fails
- Can't collaborate easily
- Manual backup needed

**When to use:**

- Learning Terraform
- Solo projects
- Quick experiments
- When you commit state to git

#### Remote State (Production Best Practice)

**Location:** S3 bucket in AWS

**Pros:**

- Accessible from any computer
- Automatic backup and versioning
- Team collaboration (with locking)
- Secure and encrypted

**Cons:**

- Requires initial setup
- Small AWS costs (~$0.01/month)
- More complex configuration

**When to use:**

- Production environments
- Team projects
- Working from multiple computers
- CI/CD pipelines

---

## Common Issues and Solutions

### Issue 1: "command not found: terraform"

**Solution:** Restart your terminal after installation.

### Issue 2: "Error: No valid credential sources found"

**Solution:** Configure AWS credentials:

```bash
aws configure --profile ramsi_admin_access
```

### Issue 3: "Error: Failed to get existing workspaces"

**Solution:** Check your AWS profile is correct in `variables.tf`.

### Issue 4: State file conflicts

**Solution:** Use remote state with DynamoDB locking.

---

## Next Steps

Now that Terraform is configured, the next tasks are:

1. **Create S3 bucket** for website hosting
2. **Configure CloudFront** CDN
3. **Set up Route 53** DNS
4. **Request ACM certificate** for HTTPS

Each of these will be defined in separate `.tf` files in the `aws/frontend/` directory.

---

## Key Takeaways

<div class="section-label">Lessons Learned</div>

1. **AWS SSO is more secure** than static access keys
2. **Terraform state is not your website** - it's just tracking metadata
3. **Local state works fine** for solo projects and learning
4. **Remote state is better** for production and teams
5. **The `-chdir` flag** lets you run Terraform from any directory

---

## Resources

- [Terraform AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Backend Configuration](https://www.terraform.io/language/settings/backends/s3)
- [AWS CLI Configuration](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)
- [My GitHub Repository](https://github.com/Ramsi-K/cloud-resume-challenge)

---

[← Back to Blog](../index.md)
