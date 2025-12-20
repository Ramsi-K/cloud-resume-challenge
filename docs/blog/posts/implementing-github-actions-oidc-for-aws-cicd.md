---
date: 2025-12-17
categories:
  - aws
  - devops
  - terraform
tags:
  - github-actions
  - oidc
  - ci-cd
  - iam
  - security
---

# Implementing GitHub Actions OIDC for AWS CI/CD

<div class="section-label">Implementation</div>

I wanted to automate deployments using GitHub Actions instead of running manual scripts. OIDC authentication eliminates the need to store AWS credentials in GitHub secrets while providing secure, temporary access tokens. While this is more complex than manual scripts, it mirrors the constraints of production CI/CD environments.

<!-- more -->

## OIDC Provider Configuration

The OIDC provider enables GitHub Actions to authenticate to AWS without storing credentials. I placed this configuration in `aws/state/` alongside the Terraform state infrastructure since it's foundational plumbing that both frontend and backend workflows need.

The provider configuration requires GitHub's SSL certificate thumbprints for verification. These are GitHub's official thumbprints that AWS uses to verify tokens are actually from GitHub:

```hcl
resource "aws_iam_openid_connect_provider" "github_actions" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = ["sts.amazonaws.com"]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd"
  ]
}
```

The client ID is always `sts.amazonaws.com` for AWS integrations.

## IAM Role and Trust Policy

The IAM role restricts access to my specific repository and main branch:

```hcl
assume_role_policy = jsonencode({
  Version = "2012-10-17"
  Statement = [
    {
      Effect = "Allow"
      Principal = {
        Federated = aws_iam_openid_connect_provider.github_actions.arn
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
        StringLike = {
          "token.actions.githubusercontent.com:sub" = "repo:Ramsi-K/cloud-resume-challenge:ref:refs/heads/main"
        }
      }
    }
  ]
})
```

The subject condition ensures only GitHub Actions from my specific repository and main branch can assume this role. Forked repositories cannot use this role because their tokens have different subjects.

## IAM Permissions

I created two separate policies to scope permissions by deployment function and limit blast radius:

**Frontend Policy** - S3 and CloudFront operations for website deployment:

- S3 bucket operations (get, put, delete objects)
- CloudFront invalidation permissions
- Bucket policy and website configuration permissions

**Terraform Policy** - Infrastructure management operations:

- Lambda function management
- API Gateway operations
- DynamoDB table operations
- IAM role and policy management
- CloudWatch Logs operations

CloudFront permissions require `Resource: "*"` because CloudFront doesn't support resource-level permissions.

You can see the complete policy definitions in [my GitHub repo](https://github.com/Ramsi-K/cloud-resume-challenge/blob/main/aws/state/oidc.tf).

## Workflow Configuration

I created three separate workflows:

**Frontend Workflow** (`frontend.yml`):

- Triggers on changes to `docs/`, `mkdocs.yml`, `aws/frontend/`
- Validates MkDocs build with `--strict` flag
- Uploads to S3 and invalidates CloudFront cache
- Only deploys on push to main branch

**Backend Workflow** (`backend.yml`):

- Triggers on changes to `aws/backend/`
- Runs Terraform validate, plan, and apply
- Uses `-auto-approve` for automated deployment

**State Workflow** (`state.yml`):

- Manual triggering only (`workflow_dispatch`)
- Manages foundational infrastructure (S3 bucket, DynamoDB table, OIDC provider)
- Uses `-detailed-exitcode` to handle existing infrastructure gracefully

Each workflow includes the required OIDC permissions:

```yaml
permissions:
  id-token: write # Required for OIDC
  contents: read # Required to checkout code
```

## Implementation Issues

### Issue #1: Workflow Conflicts

Initial implementation tried to manage both state and application infrastructure in one workflow. This caused conflicts when resources already existed.

**Solution**: Split into separate workflows based on function and change frequency.

### Issue #2: IAM Permission Errors

Multiple permission errors occurred during implementation:

1. `dynamodb:DescribeTimeToLive` - Terraform reads TTL configuration
2. `dynamodb:GetItem/PutItem/DeleteItem` - Table item operations
3. `iam:GetPolicyVersion` - Policy version reading
4. `lambda:ListVersionsByFunction` - Lambda version listing
5. `lambda:GetFunctionCodeSigningConfig` - Code signing configuration
6. `lambda:GetPolicy` - Lambda function policies
7. `logs:DescribeLogGroups` - CloudWatch log group operations
8. `logs:ListTagsForResource` - Log group tag operations (not `logs:ListTagsLogGroup`)

**Root Cause**: Terraform requires read permissions for every AWS resource attribute it checks during planning, not just create/update permissions.

**Solution**: Added comprehensive permissions for each service while maintaining resource-level restrictions where possible.

### Issue #3: State Workflow Bootstrap Problem

The state workflow creates the infrastructure it needs to store its own state, creating a chicken-and-egg problem.

**Solution**: Deploy state infrastructure manually once, then use the workflow for updates. The workflow uses `-detailed-exitcode` to handle cases where no changes are needed:

- Exit code 0: No changes needed (success)
- Exit code 2: Changes detected (success, proceed with apply)
- Exit code 1: Error (failure)

## Security Verification

Tested the OIDC security by attempting to assume the role without proper tokens. The role correctly denied access even with admin AWS credentials, confirming that only GitHub Actions from the specified repository can assume the role.

AWS account IDs are not considered sensitive and can be hardcoded in workflow files, eliminating the need for GitHub secrets.

## Results

The implementation provides automated deployments with several advantages over manual deployment:

- **Path-based triggering** - Only relevant workflows run when files change, improving efficiency
- **No stored credentials** - OIDC eliminates the need for AWS keys in GitHub secrets
- **Separate workflows** - Frontend and backend deployments are independent
- **Comprehensive permissions** - All necessary IAM permissions for reliable deployments
- **Security restrictions** - Only my specific repository and branch can assume the role

This approach is more complex than manual deployment scripts, but provides better security and automation. The path-based triggering was particularly valuable - documentation changes only trigger the frontend workflow, while infrastructure changes only trigger the backend workflow.

The complete implementation is available in [my GitHub repo](https://github.com/Ramsi-K/cloud-resume-challenge), including:

- [OIDC configuration](https://github.com/Ramsi-K/cloud-resume-challenge/blob/main/aws/state/oidc.tf)
- [Workflow files](https://github.com/Ramsi-K/cloud-resume-challenge/tree/main/.github/workflows)
- [Terraform configurations](https://github.com/Ramsi-K/cloud-resume-challenge/tree/main/aws)

---

_This is part of my Cloud Resume Challenge series. You can see the full project at [ramsi.dev](https://ramsi.dev) and follow along with the code on [GitHub](https://github.com/Ramsi-K/cloud-resume-challenge)._
