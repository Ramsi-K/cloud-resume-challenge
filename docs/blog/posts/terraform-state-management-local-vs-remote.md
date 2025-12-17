---
date: 2025-12-17
categories:
  - terraform
  - devops
  - infrastructure
tags:
  - terraform
  - state-management
  - aws
  - s3
---

# Terraform State Management: Local vs Remote (And Why You Should Care)

<div class="section-label">Overview</div>

I was building my AWS infrastructure with Terraform, running `terraform apply` from my laptop, when I hit a wall planning CI/CD. My Terraform state file was local - sitting in my project directory. That doesn't work for automated deployments.

<!-- more -->

This is the classic Terraform state management problem: local state is simple to start with, but remote state is essential for production workflows.

## What Even Is Terraform State?

If you're new to Terraform, the state file is basically Terraform's memory. It's a JSON file that tracks what resources exist, their current configuration, and how they map to your Terraform code.

When you run `terraform plan`, Terraform compares your code to the state file to figure out what needs to change. When you run `terraform apply`, it updates the state file with the new reality.

No state file = Terraform has no idea what it created before.

## Local State: The Default (And The Problem)

By default, Terraform stores state locally in a file called `terraform.tfstate` in your project directory.

**Pros:**

- Simple - no setup required
- Fast - no network calls
- Works great for solo projects and learning

**Cons:**

- Can't share with team members
- No backup if your laptop dies
- Can't run Terraform from CI/CD
- No locking (multiple people can break things)

For my resume challenge project, local state was fine initially. But the moment I wanted GitHub Actions to deploy my infrastructure, I hit a wall. GitHub Actions can't access the state file on my laptop.

## Remote State: The Grown-Up Solution

Remote state stores the state file in a shared location that multiple people (or CI/CD systems) can access.

**Common backends:**

- **S3** (AWS) - most popular for AWS projects
- **Azure Storage** - for Azure projects
- **Google Cloud Storage** - for GCP projects
- **Terraform Cloud** - Terraform's hosted solution

**Pros:**

- Team collaboration works
- Automatic backups
- State locking prevents conflicts
- CI/CD can access it
- Versioning and history

**Cons:**

- Requires initial setup
- Slightly slower (network calls)
- Need to manage backend credentials

## How I Set Up S3 Remote State

Here's what I did for my AWS project:

### Step 1: Create the Backend Infrastructure

First, I needed an S3 bucket and DynamoDB table for locking:

```hcl
# aws/state/main.tf
resource "aws_s3_bucket" "terraform_state" {
  bucket = "terraform-state-cloud-resume-challenge-us-east-1"
}

resource "aws_dynamodb_table" "terraform_state_lock" {
  name           = "terraform-state-lock"
  billing_mode   = "PAY_PER_REQUEST"
  hash_key       = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}
```

### Step 2: Configure Remote Backend

Then I updated my Terraform configuration:

```hcl
terraform {
  backend "s3" {
    bucket         = "terraform-state-cloud-resume-challenge-us-east-1"
    key            = "frontend/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}
```

### Step 3: Migrate Existing State

```bash
terraform init  # Terraform detects the backend change
# Answer "yes" to migrate existing state
```

That's it. Now my state is in S3, and GitHub Actions can access it.

## The Locking Thing

DynamoDB provides state locking, which prevents two people from running `terraform apply` at the same time. Without locking, you can corrupt your state file and break everything.

The lock is automatic - when someone runs Terraform, it grabs a lock. When they're done, it releases the lock. If someone else tries to run Terraform while it's locked, they get an error and have to wait.

## When to Use Each

**Use Local State When:**

- Learning Terraform
- Solo projects that will never need CI/CD
- Quick experiments and testing
- You're just getting started

**Use Remote State When:**

- Working with a team
- Setting up CI/CD pipelines
- Production infrastructure
- You care about backups and history
- Multiple environments (dev/staging/prod)

## The Migration Reality

I initially thought "I'll just use local state for now and migrate later." That was a mistake. Migration isn't hard, but it's an extra step that you have to remember to do.

If you know you'll eventually want CI/CD (and you probably will), just start with remote state. The setup takes 10 minutes and saves you from migration headaches later.

## Cost Reality Check

S3 storage for Terraform state files is basically free. My state files are a few KB each. DynamoDB for locking is also essentially free for this use case.

Don't let cost concerns keep you on local state. We're talking pennies per month.

## What I Learned

1. **Start with remote state if you plan to do CI/CD** - Don't make my mistake of migrating later
2. **State locking is crucial** - DynamoDB prevents corruption from concurrent runs
3. **Separate state files for different components** - I use different keys for frontend/backend
4. **Encryption is free** - Always encrypt your state files
5. **Backup happens automatically** - S3 versioning gives you state history

The bottom line: if you're doing anything more serious than learning exercises, use remote state from the start. Your future self will thank you when you want to set up automated deployments.

---

_This is part of my Cloud Resume Challenge series. You can see the full project at [ramsi.dev](https://ramsi.dev) and follow along with the code on [GitHub](https://github.com/Ramsi-K/cloud-resume-challenge)._
