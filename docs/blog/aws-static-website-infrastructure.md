---
title: Building Secure AWS Static Website Infrastructure with Terraform
date: 2025-11-29
categories:
  - AWS
  - Infrastructure
  - Terraform
  - DevOps
tags:
  - S3
  - CloudFront
  - Route53
  - ACM
  - HTTPS
  - CDN
---

# Building Secure AWS Static Website Infrastructure with Terraform

<div class="section-label">Cloud Resume Challenge</div>

Today I built the complete infrastructure for hosting a static website on AWS using Terraform. This covers S3 storage, CloudFront CDN, SSL certificates, and DNS configuration. Here's everything I learned.

---

## Architecture Overview

The architecture uses four AWS services working together:

```text
User → Route 53 (DNS) → CloudFront (CDN + HTTPS) → S3 (Private Storage)
```

**Why this architecture?**

- S3 provides cheap, reliable storage
- CloudFront adds global CDN and HTTPS support
- ACM provides free SSL certificates
- Route 53 handles custom domain DNS

**Cost:** $0.50-1.00/month (just Route 53 hosted zone)

---

## Task 12: S3 Bucket for Static Website Hosting

<div class="section-label">The Challenge</div>

Create an S3 bucket that's private but accessible through CloudFront. Many tutorials show public S3 buckets, but that's outdated and insecure.

---

### The Solution

Created `aws/frontend/s3.tf` with these key resources:

**1. S3 Bucket**

```hcl
resource "aws_s3_bucket" "website" {
  bucket = "${var.project_name}-website-${var.aws_region}"

  tags = {
    Name = "Resume Website Bucket"
  }
}
```

**2. Website Configuration**

```hcl
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "404.html"
  }
}
```

**3. Versioning (keeps file history)**

```hcl
resource "aws_s3_bucket_versioning" "website" {
  bucket = aws_s3_bucket.website.id

  versioning_configuration {
    status = "Enabled"
  }
}
```

**4. Block Public Access (security)**

```hcl
resource "aws_s3_bucket_public_access_block" "website" {
  bucket = aws_s3_bucket.website.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
```

**5. Lifecycle Rule (cost optimization)**

```hcl
resource "aws_s3_bucket_lifecycle_configuration" "website" {
  bucket = aws_s3_bucket.website.id

  rule {
    id     = "delete-old-versions"
    status = "Enabled"

    filter {}  # Apply to all objects

    noncurrent_version_expiration {
      noncurrent_days = 90
    }
  }
}
```

**6. Bucket Policy (CloudFront access only)**

```hcl
resource "aws_s3_bucket_policy" "website" {
  bucket = aws_s3_bucket.website.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowCloudFrontAccess"
        Effect = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.website.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.website.arn
          }
        }
      }
    ]
  })
}
```

---

### Commands Used

```bash
# Preview changes
terraform -chdir=aws/frontend plan

# Create resources
terraform -chdir=aws/frontend apply
```

---

### Output

```bash
Apply complete! Resources: 6 added, 0 changed, 0 destroyed.

Outputs:
s3_bucket_name = "cloud-resume-challenge-website-us-east-1"
s3_bucket_arn = "arn:aws:s3:::cloud-resume-challenge-website-us-east-1"
```

---

<div class="section-label">Key Takeaway</div>

**Question I had:** "Why block public access if we're hosting a website?"

**Answer:** We're using CloudFront as the only entry point. The bucket stays private, and CloudFront gets special permission through the bucket policy. This is more secure and enables HTTPS.

---

## Task 13: ACM Certificate for HTTPS

<div class="section-label">The Challenge</div>

Get a free SSL certificate for custom domain. Certificate must be in `us-east-1` region (CloudFront requirement).

---

### The Solution

Created `aws/frontend/acm.tf`:

```hcl
# Request SSL/TLS certificate
resource "aws_acm_certificate" "website" {
  domain_name       = var.domain_name
  validation_method = "DNS"

  # Optional: Add www subdomain
  subject_alternative_names = [
    "www.${var.domain_name}"
  ]

  tags = {
    Name = "Resume Website Certificate"
  }

  lifecycle {
    create_before_destroy = true
  }
}

# DNS validation
resource "aws_acm_certificate_validation" "website" {
  certificate_arn = aws_acm_certificate.website.arn

  timeouts {
    create = "10m"
  }
}
```

---

### Commands Used

```bash
# Create certificate (will timeout waiting for DNS validation)
terraform -chdir=aws/frontend apply -auto-approve

# Get DNS validation records
terraform -chdir=aws/frontend output acm_validation_records
```

---

### Output

```bash
acm_validation_records = [
  {
    "name" = "_83ff97c7c7f78e398486e4b2b640a4ee.ramsi.dev."
    "type" = "CNAME"
    "value" = "_c76859f67c6f3747c781c7d948cf52e0.jkddzztszm.acm-validations.aws."
  },
  {
    "name" = "_46562756ca652f9c38c50b61e4c15751.www.ramsi.dev."
    "type" = "CNAME"
    "value" = "_36b9950b4800bed039e9a2f7779966e5.jkddzztszm.acm-validations.aws."
  }
]
```

---

### DNS Validation in Namecheap

Added two CNAME records in Namecheap Advanced DNS:

**Record 1:**

- Host: `_83ff97c7c7f78e398486e4b2b640a4ee`
- Type: CNAME
- Value: `_c76859f67c6f3747c781c7d948cf52e0.jkddzztszm.acm-validations.aws.`

**Record 2:**

- Host: `_46562756ca652f9c38c50b61e4c15751.www`
- Type: CNAME
- Value: `_36b9950b4800bed039e9a2f7779966e5.jkddzztszm.acm-validations.aws.`

---

### Verification

```bash
# Check certificate status
aws acm describe-certificate \
  --certificate-arn "arn:aws:acm:us-east-1:845822318516:certificate/6e261099-2f9b-4b74-a05e-61f243f5e159" \
  --region us-east-1 \
  --profile ramsi_admin_access \
  --query "Certificate.Status" \
  --output text

# Output: ISSUED ✓
```

---

<div class="section-label">Key Takeaway</div>

DNS validation took about 5-10 minutes after adding the CNAME records. The certificate is free forever and auto-renews.

---

## Task 14: CloudFront Distribution

<div class="section-label">The Challenge</div>

Set up a global CDN that serves content over HTTPS with custom domain support.

---

### The Solution

Created `aws/frontend/cloudfront.tf`:

**1. Origin Access Control**

```hcl
resource "aws_cloudfront_origin_access_control" "website" {
  name                              = "${var.project_name}-oac"
  description                       = "Origin Access Control for S3 website bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}
```

**2. CloudFront Distribution**

```hcl
resource "aws_cloudfront_distribution" "website" {
  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Resume website CDN"
  default_root_object = "index.html"
  price_class         = "PriceClass_100" # North America + Europe only

  aliases = [
    var.domain_name,
    var.domain_name_www
  ]

  origin {
    domain_name              = aws_s3_bucket.website.bucket_regional_domain_name
    origin_id                = "S3-${aws_s3_bucket.website.id}"
    origin_access_control_id = aws_cloudfront_origin_access_control.website.id
  }

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-${aws_s3_bucket.website.id}"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600   # 1 hour
    max_ttl                = 86400  # 24 hours
    compress               = true
  }

  custom_error_response {
    error_code         = 404
    response_code      = 404
    response_page_path = "/404.html"
  }

  custom_error_response {
    error_code         = 403
    response_code      = 404
    response_page_path = "/404.html"
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.website.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  depends_on = [aws_acm_certificate_validation.website]
}
```

---

### Commands Used

```bash
# Create CloudFront distribution
terraform -chdir=aws/frontend apply -auto-approve
```

---

### Output

```bash
Apply complete! Resources: 2 added, 1 changed, 0 destroyed.

Outputs:
cloudfront_distribution_id = "E30Q81K1LHTMG1"
cloudfront_domain_name = "d1zlrozohdpjmg.cloudfront.net"
cloudfront_url = "https://d1zlrozohdpjmg.cloudfront.net"
```

---

### Testing

```bash
# Test CloudFront endpoint
curl -I https://d1zlrozohdpjmg.cloudfront.net

# Output: HTTP/2 403 (expected - bucket is empty)
```

---

<div class="section-label">Key Takeaways</div>

**Price Class Decision:**

- `PriceClass_100`: North America + Europe only (cheapest)
- `PriceClass_200`: Adds Asia, Middle East, Africa
- `PriceClass_All`: All edge locations worldwide

I chose `PriceClass_100` because:

- Saves $1-2/month after free tier
- Most traffic will be from US/Europe
- Still works globally (just slightly slower from Asia)

**Deployment Time:** CloudFront took only 3 minutes to deploy (usually takes 15-20 minutes).

---

## Task 15: Route 53 DNS Configuration

<div class="section-label">The Challenge</div>

Point custom domain to CloudFront distribution using AWS Route 53.

---

### The Solution

Created `aws/frontend/route53.tf`:

**1. Create Hosted Zone**

```hcl
resource "aws_route53_zone" "main" {
  name = var.domain_name

  tags = {
    Name = "Resume Website Hosted Zone"
  }
}
```

**2. A Record for Apex Domain**

```hcl
resource "aws_route53_record" "apex" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.website.domain_name
    zone_id                = aws_cloudfront_distribution.website.hosted_zone_id
    evaluate_target_health = false
  }
}
```

**3. A Record for WWW Subdomain**

```hcl
resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.main.zone_id
  name    = var.domain_name_www
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.website.domain_name
    zone_id                = aws_cloudfront_distribution.website.hosted_zone_id
    evaluate_target_health = false
  }
}
```

---

### Commands Used

```bash
# Check if hosted zone exists
aws route53 list-hosted-zones \
  --profile ramsi_admin_access \
  --query "HostedZones[?Name=='ramsi.dev.']" \
  --output table

# Create Route 53 resources
terraform -chdir=aws/frontend apply -auto-approve
```

---

### Output

```bash
Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:
route53_zone_id = "Z08021202QI7X8VLKJ2PR"
route53_name_servers = [
  "ns-1523.awsdns-62.org",
  "ns-1597.awsdns-07.co.uk",
  "ns-21.awsdns-02.com",
  "ns-608.awsdns-12.net"
]
website_url = "https://ramsi.dev"
```

---

### Update Namecheap Nameservers

In Namecheap Domain Management:

1. Changed from "Namecheap BasicDNS" to "Custom DNS"
2. Added all 4 AWS nameservers:
   - `ns-1523.awsdns-62.org`
   - `ns-1597.awsdns-07.co.uk`
   - `ns-21.awsdns-02.com`
   - `ns-608.awsdns-12.net`

DNS propagation takes 5-60 minutes.

---

## Complete Infrastructure Summary

<div class="section-label">Summary</div>

### Resources Created

| Resource                | Purpose                  | Cost                      |
| ----------------------- | ------------------------ | ------------------------- |
| S3 Bucket               | Static file storage      | $0 (free tier)            |
| S3 Versioning           | File history             | $0 (minimal storage)      |
| S3 Lifecycle            | Auto-delete old versions | $0                        |
| ACM Certificate         | SSL/TLS for HTTPS        | $0 (free forever)         |
| CloudFront Distribution | Global CDN               | $0 (free tier 1 TB/month) |
| Route 53 Hosted Zone    | DNS management           | $0.50/month               |
| Route 53 A Records      | Domain routing           | $0                        |

**Total Cost:** $0.50-1.00/month

### Terraform Files Created

```text
aws/frontend/
├── backend.tf          # Terraform state
├── providers.tf        # AWS provider configuration
├── variables.tf        # Input variables
├── outputs.tf          # Output values
├── s3.tf              # S3 bucket resources
├── acm.tf             # SSL certificate
├── cloudfront.tf      # CDN distribution
└── route53.tf         # DNS configuration
```

### Key Commands Reference

```bash
# Initialize Terraform
terraform -chdir=aws/frontend init

# Preview changes
terraform -chdir=aws/frontend plan

# Apply changes
terraform -chdir=aws/frontend apply

# View outputs
terraform -chdir=aws/frontend output

# Destroy everything (if needed)
terraform -chdir=aws/frontend destroy
```

---

## Lessons Learned

<div class="section-label">Key Takeaways</div>

### 1. Private S3 + CloudFront is the Modern Way

Don't make S3 buckets public. Use CloudFront with Origin Access Control instead. This provides:

- Better security (no direct S3 access)
- HTTPS support (S3 website hosting doesn't support HTTPS)
- Global CDN caching
- Custom domain support

### 2. ACM Certificates Must Be in us-east-1

CloudFront requires certificates in the `us-east-1` region, regardless of where your other resources are.

### 3. DNS Validation Takes Time

After adding DNS validation records, wait 5-10 minutes before running `terraform apply` again. The certificate won't validate instantly.

### 4. Price Classes Matter

CloudFront price classes control which edge locations serve your content. For a resume site targeting US/Europe, `PriceClass_100` saves money without sacrificing much performance.

### 5. Terraform State is Critical

Always use remote state (S3 + DynamoDB) for production. Never commit state files to git.

### 6. Lifecycle Rules Save Money

Enabling S3 versioning is great for safety, but old versions accumulate. Lifecycle rules automatically delete versions older than 90 days.

---

## Common Errors and Solutions

<div class="section-label">Troubleshooting</div>

### Error: Lifecycle Configuration Missing Filter

**Problem:**

```bash
Warning: Invalid Attribute Combination
No attribute specified when one (and only one) of [rule[0].filter,rule[0].prefix] is required
```

**Solution:** Add empty filter block:

```hcl
rule {
  id     = "delete-old-versions"
  status = "Enabled"
  filter {}  # Add this line
  noncurrent_version_expiration {
    noncurrent_days = 90
  }
}
```

### Error: Certificate Validation Timeout

**Problem:**

```bash
Error: waiting for ACM Certificate to be issued: timeout while waiting for state to become 'ISSUED'
```

**Solution:** This is expected. Add DNS validation records in your domain registrar, wait 5-10 minutes, then run `terraform apply` again.

### Error: CloudFront 403 Forbidden

**Problem:** Accessing CloudFront URL returns 403 error.

**Solution:** This is expected if the S3 bucket is empty. Upload files to S3 and the error will resolve.

---

## Conclusion

<div class="section-label">Final Thoughts</div>

Building AWS infrastructure with Terraform is powerful once you understand the architecture. The key is keeping S3 private and using CloudFront as the public-facing layer. This provides security, performance, and HTTPS support at minimal cost.

Total time: ~2 hours (including DNS propagation waits)
Total cost: $0.50/month
Lines of Terraform: ~250

---

**Tags:** AWS, Terraform, S3, CloudFront, Route53, ACM, Infrastructure as Code, Static Website, HTTPS, CDN
