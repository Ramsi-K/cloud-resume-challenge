# GitHub OIDC Provider and IAM Role for CI/CD
# This enables GitHub Actions to authenticate to AWS without storing credentials

# OIDC Identity Provider for GitHub Actions
resource "aws_iam_openid_connect_provider" "github_actions" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  # GitHub's OIDC thumbprints (these are GitHub's official thumbprints)
  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1",
    "1c58a3a8518e8759bf075b76b750d4f2df264fcd"
  ]

  tags = {
    Name        = "GitHub Actions OIDC Provider"
    Description = "Allows GitHub Actions to assume AWS roles"
  }
}

# IAM Role for GitHub Actions
resource "aws_iam_role" "github_actions" {
  name = "${var.project_name}-github-actions-role"

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

  tags = {
    Name        = "GitHub Actions Role"
    Description = "Role assumed by GitHub Actions for CI/CD deployments"
  }
}

# IAM Policy for S3 and CloudFront operations (Frontend)
resource "aws_iam_policy" "github_actions_frontend" {
  name        = "${var.project_name}-github-actions-frontend-policy"
  description = "Permissions for GitHub Actions to deploy frontend resources"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket",
          "s3:GetBucketLocation",
          "s3:GetBucketVersioning",
          "s3:PutBucketVersioning",
          "s3:GetBucketWebsite",
          "s3:PutBucketWebsite",
          "s3:GetBucketPolicy",
          "s3:PutBucketPolicy",
          "s3:DeleteBucketPolicy",
          "s3:GetBucketPublicAccessBlock",
          "s3:PutBucketPublicAccessBlock"
        ]
        Resource = [
          "arn:aws:s3:::${var.project_name}-website-${var.aws_region}",
          "arn:aws:s3:::${var.project_name}-website-${var.aws_region}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "cloudfront:CreateInvalidation",
          "cloudfront:GetDistribution",
          "cloudfront:GetDistributionConfig",
          "cloudfront:ListDistributions",
          "cloudfront:UpdateDistribution"
        ]
        Resource = "*"
      }
    ]
  })
}

# IAM Policy for Terraform operations (Backend)
resource "aws_iam_policy" "github_actions_terraform" {
  name        = "${var.project_name}-github-actions-terraform-policy"
  description = "Permissions for GitHub Actions to run Terraform operations"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          # Terraform state operations
          "s3:GetObject",
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::terraform-state-${var.project_name}-${var.aws_region}",
          "arn:aws:s3:::terraform-state-${var.project_name}-${var.aws_region}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          # DynamoDB state locking
          "dynamodb:GetItem",
          "dynamodb:PutItem",
          "dynamodb:DeleteItem"
        ]
        Resource = "arn:aws:dynamodb:${var.aws_region}:*:table/terraform-state-lock"
      },
      {
        Effect = "Allow"
        Action = [
          # Lambda operations
          "lambda:CreateFunction",
          "lambda:DeleteFunction",
          "lambda:GetFunction",
          "lambda:GetFunctionConfiguration",
          "lambda:UpdateFunctionCode",
          "lambda:UpdateFunctionConfiguration",
          "lambda:AddPermission",
          "lambda:RemovePermission",
          "lambda:InvokeFunction",
          "lambda:ListFunctions",
          "lambda:TagResource",
          "lambda:UntagResource"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          # API Gateway operations
          "apigateway:*"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          # DynamoDB operations
          "dynamodb:CreateTable",
          "dynamodb:DeleteTable",
          "dynamodb:DescribeTable",
          "dynamodb:UpdateTable",
          "dynamodb:TagResource",
          "dynamodb:UntagResource",
          "dynamodb:ListTagsOfResource",
          "dynamodb:DescribeContinuousBackups"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          # IAM operations (limited)
          "iam:CreateRole",
          "iam:DeleteRole",
          "iam:GetRole",
          "iam:PassRole",
          "iam:AttachRolePolicy",
          "iam:DetachRolePolicy",
          "iam:CreatePolicy",
          "iam:DeletePolicy",
          "iam:GetPolicy",
          "iam:ListAttachedRolePolicies",
          "iam:TagRole",
          "iam:UntagRole",
          "iam:TagPolicy",
          "iam:UntagPolicy",
          "iam:CreateOpenIDConnectProvider",
          "iam:DeleteOpenIDConnectProvider",
          "iam:GetOpenIDConnectProvider",
          "iam:TagOpenIDConnectProvider",
          "iam:UntagOpenIDConnectProvider",
          "iam:ListRolePolicies",
          "iam:GetRolePolicy",
          "iam:PutRolePolicy",
          "iam:DeleteRolePolicy"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          # CloudFormation (used by some Terraform resources)
          "cloudformation:DescribeStacks",
          "cloudformation:DescribeStackEvents",
          "cloudformation:DescribeStackResources",
          "cloudformation:GetTemplate"
        ]
        Resource = "*"
      }
    ]
  })
}

# Attach policies to the role
resource "aws_iam_role_policy_attachment" "github_actions_frontend" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_frontend.arn
}

resource "aws_iam_role_policy_attachment" "github_actions_terraform" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_terraform.arn
}