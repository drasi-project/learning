#!/bin/bash

# Build script for Delivery Dashboard

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
IMAGE_NAME="delivery-dashboard"
IMAGE_TAG="latest"

echo -e "${YELLOW}Building Delivery Dashboard Docker image...${NC}"

# Build the Docker image
docker build -t ${IMAGE_NAME}:${IMAGE_TAG} .

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Docker image built successfully: ${IMAGE_NAME}:${IMAGE_TAG}${NC}"
    
    # Import to k3d if available
    if command -v k3d &> /dev/null; then
        echo -e "${YELLOW}Importing image to k3d cluster...${NC}"
        k3d image import ${IMAGE_NAME}:${IMAGE_TAG} -c physical-ops-demo
        if [ $? -eq 0 ]; then
            echo -e "${GREEN}✓ Image imported to k3d successfully${NC}"
        else
            echo -e "${RED}✗ Failed to import image to k3d${NC}"
        fi
    fi
else
    echo -e "${RED}✗ Failed to build Docker image${NC}"
    exit 1
fi