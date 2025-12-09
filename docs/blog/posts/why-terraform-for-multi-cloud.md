---
title: Choosing Terraform for Multi-Cloud Deployment
date: 2025-11-29
categories:
  - Cloud Infrastructure
  - Learning
tags:
  - Terraform
  - Multi-Cloud
  - IaC
---

# Choosing Terraform for Multi-Cloud Deployment

<div class="section-label">Learning Journey</div>

For the Cloud Resume Challenge, I'm deploying the same website to AWS, Azure, and Google Cloud. I had to choose an Infrastructure as Code tool, and I wanted to document my thinking process.

<!-- more -->

---

## The Situation

The bootcamp teaches CloudFormation + Ansible for AWS deployment. That's a proven approach, and I considered following it exactly. But my goal is different - I want to deploy to three clouds, not just one.

This made me pause and think about what tool would work best.

---

## Options I Considered

### CloudFormation

AWS's native tool. The bootcamp uses this, so I'd have examples to follow. But it only works for AWS. I'd need to learn different tools for Azure and GCP.

### Terraform

Works across all three clouds. One tool, one syntax. But I'd be deviating from the bootcamp materials.

### AWS CDK

Lets you write infrastructure in Python or TypeScript. Interesting, but also AWS-only.

---

## Why I Chose Terraform

**The main reason:** I'm deploying to three clouds, and Terraform works with all of them.

If I used CloudFormation for AWS, I'd need to learn Azure Resource Manager templates for Azure, and Google Cloud Deployment Manager for GCP. That's three different tools with three different syntaxes.

With Terraform, I learn one tool and apply it three times. The syntax stays consistent even when the cloud provider changes.

**Example:**

```bash
# Same command structure for all clouds
terraform -chdir=aws/frontend apply
terraform -chdir=azure/frontend apply
terraform -chdir=gcp/frontend apply
```

This consistency helps me focus on learning cloud concepts rather than tool syntax.

---

## What About Ansible?

The bootcamp also uses Ansible for deployment. I decided to use simple bash scripts instead.

My deployment is straightforward:

1. Build the website with MkDocs
2. Apply Terraform to create infrastructure
3. Upload files to cloud storage
4. Invalidate CDN cache

For this workflow, bash scripts felt simpler than adding Ansible. I might be wrong about this - I'll learn as I go.

---

## Trade-offs I'm Aware Of

**What I'm giving up:**

- CloudFormation's deeper AWS integration
- The ability to follow bootcamp examples directly
- Native AWS features and automatic rollbacks

**What I'm gaining:**

- Ability to deploy to three clouds with one tool
- Consistent workflow across providers
- Learning cloud-agnostic patterns

I'm not sure if this is the "right" choice, but it aligns with my multi-cloud goal.

---

## The Plan

1. **Start with AWS** - Learn Terraform basics, deploy S3 + CloudFront
2. **Add backend** - Lambda + API Gateway + DynamoDB
3. **Replicate to Azure** - Apply what I learned to Azure services
4. **Replicate to GCP** - Complete the multi-cloud deployment
5. **Automate** - Set up CI/CD with GitHub Actions

I'll document what works and what doesn't along the way.

---

## Reflections

This decision taught me that it's okay to deviate from tutorials when your goals are different. The bootcamp approach is great for AWS-focused projects. My project is multi-cloud focused, so I adapted.

I'm curious to see if this choice pays off or if I'll run into challenges I didn't anticipate. Either way, I'll learn something.

---

## Resources

- [Terraform Documentation](https://www.terraform.io/docs)
- [My Terraform Setup Guide](terraform-aws-setup.md)
- [Cloud Resume Challenge](https://cloudresumechallenge.dev)

---

[← Back to Blog](../index.md)
