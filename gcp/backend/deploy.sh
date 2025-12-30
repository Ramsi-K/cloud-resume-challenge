#!/bin/bash

set -e

# Colors
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Configuration
PROJECT_ID="cloud-resume-challenge-482812"
REGION="us-central1"

echo -e "${BLUE}Starting GCP backend deployment...${NC}"

# Initialize Terraform if needed
if [ ! -d ".terraform" ]; then
    echo -e "${BLUE}Initializing Terraform...${NC}"
    terraform init
fi

# Plan deployment
echo -e "${BLUE}Planning Terraform deployment...${NC}"
terraform plan

# Ask for confirmation
echo -e "${YELLOW}Do you want to apply these changes? (y/N)${NC}"
read -r response
if [[ "$response" =~ ^([yY][eE][sS]|[yY])$ ]]; then
    # Apply deployment
    echo -e "${BLUE}Applying Terraform configuration...${NC}"
    terraform apply -auto-approve
    
    # Get function URL
    FUNCTION_URL=$(terraform output -raw visitor_counter_function_url 2>/dev/null || echo "")
    
    if [ -n "$FUNCTION_URL" ]; then
        echo -e "${GREEN}✓ Backend deployment complete!${NC}"
        echo ""
        echo "Function URL: $FUNCTION_URL"
        echo ""
        echo -e "${BLUE}Testing visitor counter...${NC}"
        
        # Test GET request
        echo "Testing GET request:"
        curl -s "$FUNCTION_URL" | jq '.' || curl -s "$FUNCTION_URL"
        
        echo ""
        echo "Testing POST request:"
        curl -s -X POST "$FUNCTION_URL" | jq '.' || curl -s -X POST "$FUNCTION_URL"
        
        echo ""
        echo -e "${GREEN}✓ Backend is ready!${NC}"
        echo "Next step: Update DNS record for api.ramsi.dev"
    else
        echo -e "${YELLOW}Deployment complete, but couldn't retrieve function URL${NC}"
        echo "Check terraform output manually"
    fi
else
    echo "Deployment cancelled"
fi