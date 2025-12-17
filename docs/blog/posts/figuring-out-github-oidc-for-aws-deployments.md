---
date: 2025-12-17
categories:
  - aws
  - devops
  - learning
tags:
  - github-actions
  - oidc
  - ci-cd
  - terraform
---

# Figuring Out GitHub OIDC for AWS Deployments

<div class="section-label">Overview</div>

I've got my AWS infrastructure working pretty well. Frontend deployed to S3 with CloudFront, backend APIs with Lambda and DynamoDB, visitor counter incrementing nicely. But I'm still doing everything manually - running `./deploy.sh` for the frontend and `terraform apply` for the backend.

<!-- more -->

That's fine for an early stage project, but I want to level up and do proper CI/CD. Plus, I came across this LinkedIn post from someone who built a similar setup with "GitHub Actions with OIDC for passwordless deployments" and it got me thinking... how exactly does that work?

## The Questions That Started This Journey

I had a bunch of questions that I couldn't quite wrap my head around:

**What exactly is OIDC in the context of AWS?** I know it stands for OpenID Connect, but how does it actually work for AWS? Is it really "passwordless" or is that just marketing speak?

**Do I need to set up tests first?** I don't want to deploy trash to production, but what kind of tests make sense for a simple resume site? MkDocs builds are pretty straightforward, and Terraform has its own validation.

**How does the deployment structure work?** Right now I have `deploy.sh` for frontend and manual Terraform commands for backend. Are these supposed to be linked somehow, or should they be separate workflows?

**Is this overkill for a resume challenge?** I mean, this is just a portfolio project, not some enterprise application. Am I over-engineering this?

## What I Learned About OIDC

Turns out OIDC is actually pretty clever. Instead of storing AWS access keys in GitHub secrets (which always felt sketchy), GitHub can generate temporary tokens that AWS trusts. Here's the basic flow:

1. GitHub Actions says "Hey AWS, I'm from this specific repo and branch"
2. AWS checks if that repo/branch is allowed to do stuff
3. If yes, AWS gives GitHub temporary credentials
4. GitHub uses those credentials to deploy things
5. Credentials expire automatically

No long-lived secrets sitting in GitHub. No rotating access keys. No "oh crap, did I just commit my AWS keys?" moments.

## The Deploy.sh vs Terraform Question

This one took me a while to figure out. I currently have:

- `deploy.sh` - builds MkDocs and uploads to S3
- Manual Terraform - manages all the AWS infrastructure

The LinkedIn post mentioned separating frontend and backend deployments, which makes sense. If I only change some documentation, why rebuild the entire infrastructure? And if I only change a Lambda function, why rebuild the entire website?

So the plan is:

- **Frontend workflow**: Triggers on changes to `docs/`, `mkdocs.yml` - basically anything that affects the website content
- **Backend workflow**: Triggers on changes to `aws/backend/`, `aws/state/` - the Terraform infrastructure stuff

Smart triggering based on what actually changed. I like it.

## The Testing Reality Check

I was overthinking the testing part. For a resume challenge project, I don't need a full test suite with unit tests, integration tests, end-to-end tests, and whatever else enterprise projects have.

What I actually need:

- **Frontend**: Make sure MkDocs builds without errors
- **Backend**: Make sure Terraform validates and can generate a plan
- **Optional**: Maybe a quick smoke test to check if the API returns 200

That's it. Keep it simple.

## Is This Overkill?

For this project alone, arguably yes. But here's the thing - Understanding OIDC, GitHub Actions, and proper CI/CD patterns is valuable beyond this one project.

Plus, once it's set up, it's actually easier than manual deployment. Push to main, and everything just works. No more remembering to run scripts or forgetting to invalidate CloudFront cache.

## The Plan Forward

So here's what I'm going to build:

1. **AWS OIDC Provider** - Set up the trust relationship between GitHub and AWS
2. **IAM Role** - Define what permissions GitHub Actions gets (minimal, of course)
3. **Frontend Workflow** - MkDocs build → S3 upload → CloudFront invalidation
4. **Backend Workflow** - Terraform validate → plan → apply

Each workflow only runs when relevant files change. Both use OIDC for authentication. Both include basic validation to catch obvious errors.

## Why Document This?

I'm writing this before I actually implement anything because I want to capture the questions and thought process. Too often I see blog posts that are like "Here's how to set up OIDC" without explaining why you'd want to or what problems it solves.

The reality is that figuring out new tech involves a lot of "wait, how does this actually work?" and "am I doing this right?" moments. That's normal. That's part of learning.

So if you're reading this and thinking "I have no idea how OIDC works either," you're not alone. We'll figure it out together.

Next post will be the actual implementation - setting up the OIDC provider, writing the workflows, and probably debugging a bunch of stuff that doesn't work the first time.

Because let's be honest, it never works the first time.

---

_This is part of my Cloud Resume Challenge series. You can see the full project at [ramsi.dev](https://ramsi.dev) and follow along with the code on [GitHub](https://github.com/Ramsi-K/cloud-resume-challenge)._
