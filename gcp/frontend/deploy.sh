#!/bin/bash

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
BUCKET_NAME="cloud-resume-challenge-482812-website"
PROJECT_ID="cloud-resume-challenge-482812"

echo -e "${BLUE}Starting GCP deployment...${NC}"

# Build site
echo -e "${BLUE}Building MkDocs site...${NC}"
cd ../..
mkdocs build

# Upload to GCS
echo -e "${BLUE}Uploading to Cloud Storage...${NC}"
gsutil -m rsync -r -d ./site gs://${BUCKET_NAME}

echo -e "${GREEN}✓ Files uploaded${NC}"

# Invalidate CDN cache
echo -e "${BLUE}Invalidating CDN cache...${NC}"
gcloud compute url-maps invalidate-cdn-cache cloud-resume-challenge-url-map \
  --path "/*" \
  --async

echo -e "${GREEN}✓ Cache invalidation started${NC}"

echo ""
echo -e "${GREEN}Deployment complete!${NC}"
echo "Your website is available at:"
echo "  - Custom domain: https://ramsi.dev"
echo "  - Load balancer IP: Check terraform output"