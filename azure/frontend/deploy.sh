#!/bin/bash

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}Starting Azure frontend deployment...${NC}"

# Build site
echo -e "${BLUE}Building MkDocs site...${NC}"
cd ../..
mkdocs build

# Get storage account name from Terraform output
cd azure/frontend
STORAGE_ACCOUNT=$(terraform output -raw storage_account_name)

# Upload to Azure Storage
echo -e "${BLUE}Uploading to Azure Storage...${NC}"
cd ../..
az storage blob upload-batch \
  --account-name ${STORAGE_ACCOUNT} \
  --source ./site \
  --destination '$web' \
  --overwrite

echo -e "${GREEN}✓ Files uploaded${NC}"

# Get outputs
cd azure/frontend
STORAGE_ENDPOINT=$(terraform output -raw storage_website_endpoint)
NAMESERVERS=$(terraform output -raw dns_zone_nameservers)

echo ""
echo -e "${GREEN}Deployment complete!${NC}"
echo ""
echo -e "${YELLOW}Your website is available at:${NC}"
echo "  - Direct URL: $STORAGE_ENDPOINT"
echo "  - Custom domain (after DNS setup): https://www.ramsi.dev"
echo ""
echo -e "${YELLOW}DNS Configuration Required:${NC}"
echo "Update your domain nameservers in Namecheap to:"
terraform output dns_zone_nameservers
echo ""
echo -e "${YELLOW}After DNS propagation (5-60 minutes):${NC}"
echo "  - https://www.ramsi.dev will work"
echo "  - Note: Apex domain (ramsi.dev) won't work with Azure Storage"
echo "  - Use www.ramsi.dev as your primary URL"