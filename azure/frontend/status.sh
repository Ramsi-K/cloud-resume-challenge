#!/bin/bash

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}Azure Frontend Status Check${NC}"
echo "=================================="

# Get Terraform outputs
STORAGE_ENDPOINT=$(terraform output -raw storage_website_endpoint)
STORAGE_HOST=$(terraform output -raw storage_website_host)

echo -e "${BLUE}Infrastructure:${NC}"
echo "  Resource Group: $(terraform output -raw resource_group_name)"
echo "  Storage Account: $(terraform output -raw storage_account_name)"
echo "  Storage Endpoint: $STORAGE_ENDPOINT"
echo ""

echo -e "${BLUE}Testing endpoints:${NC}"

# Test storage endpoint
echo -n "  Storage endpoint: "
if curl -s -o /dev/null -w "%{http_code}" "$STORAGE_ENDPOINT" | grep -q "200"; then
    echo -e "${GREEN}✓ Working${NC}"
else
    echo -e "${RED}✗ Failed${NC}"
fi

# Test www subdomain
echo -n "  www.ramsi.dev: "
if curl -s -o /dev/null -w "%{http_code}" "https://www.ramsi.dev" | grep -q "200"; then
    echo -e "${GREEN}✓ Working${NC}"
else
    echo -e "${YELLOW}⚠ Not yet configured (DNS propagation needed)${NC}"
fi

echo ""
echo -e "${BLUE}DNS Configuration:${NC}"
echo "Update nameservers in Namecheap to:"
terraform output dns_zone_nameservers

echo ""
echo -e "${BLUE}Next Steps:${NC}"
echo "1. Update DNS nameservers in Namecheap"
echo "2. Wait 5-60 minutes for DNS propagation"
echo "3. Test https://www.ramsi.dev"
echo "4. Deploy backend for visitor counter API"