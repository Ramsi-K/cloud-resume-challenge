#!/bin/bash

# AWS Frontend Deployment Script
# Builds MkDocs site and deploys to S3 + CloudFront

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration
AWS_PROFILE="ramsi_admin_access"
AWS_REGION="us-east-1"
S3_BUCKET="cloud-resume-challenge-website-us-east-1"
CLOUDFRONT_DISTRIBUTION_ID="E30Q81K1LHTMG1"

echo -e "${BLUE}Starting deployment...${NC}"

# Step 1: Build MkDocs site
echo -e "${BLUE}Building MkDocs site...${NC}"
# Get the script directory and go to project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "${SCRIPT_DIR}/../.." && pwd )"
cd "${PROJECT_ROOT}"
mkdocs build

if [ ! -d "site" ]; then
    echo -e "${RED}Error: site/ directory not found. MkDocs build failed.${NC}"
    exit 1
fi

echo -e "${GREEN}✓ MkDocs build complete${NC}"

# Step 2: Sync to S3
echo -e "${BLUE}Uploading to S3...${NC}"
aws s3 sync site/ s3://${S3_BUCKET}/ \
    --profile ${AWS_PROFILE} \
    --region ${AWS_REGION} \
    --delete \
    --cache-control "public, max-age=3600"

echo -e "${GREEN}✓ Files uploaded to S3${NC}"

# Step 3: Invalidate CloudFront cache
echo -e "${BLUE}Invalidating CloudFront cache...${NC}"
aws cloudfront create-invalidation \
    --distribution-id ${CLOUDFRONT_DISTRIBUTION_ID} \
    --paths "/*" \
    --profile ${AWS_PROFILE} \
    --region ${AWS_REGION}

echo -e "${GREEN}✓ CloudFront cache invalidated${NC}"

# Step 4: Display URLs
echo ""
echo -e "${GREEN}Deployment complete!${NC}"
echo ""
echo "Your website is available at:"
echo "  - CloudFront: https://d1zlrozohdpjmg.cloudfront.net"
echo "  - Custom domain: https://ramsi.dev (after DNS propagation)"
echo ""
echo "Note: CloudFront cache invalidation takes 1-2 minutes to complete."
