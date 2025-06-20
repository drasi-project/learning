#!/bin/bash
# Build and push all images
set -e

# Function to check and generate package-lock.json if needed
check_npm_lock() {
  local dir=$1
  if [ -f "$dir/package.json" ] && [ ! -f "$dir/package-lock.json" ]; then
    echo "Missing package-lock.json in $dir, generating..."
    (cd "$dir" && npm install)
  fi
}

# Ensure buildx is available
if ! docker buildx ls | grep -q multiarch-builder; then
  docker buildx create --use --name multiarch-builder --platform linux/amd64,linux/arm64
else
  docker buildx use multiarch-builder
fi

# Check for missing package-lock.json files
check_npm_lock "./control-panel/frontend"
check_npm_lock "./dashboard"

echo "Building control-panel..."
if ! docker buildx build --platform linux/amd64,linux/arm64 -t ghcr.io/drasi-project/learning/building-comfort/control-panel:latest --push control-panel/; then
    echo "ERROR: Failed to build control-panel"
    exit 1
fi

echo "Building dashboard..."
if ! docker buildx build --platform linux/amd64,linux/arm64 -t ghcr.io/drasi-project/learning/building-comfort/dashboard:latest --push dashboard/; then
    echo "ERROR: Failed to build dashboard"
    exit 1
fi

echo "Building demo..."
if ! docker buildx build --platform linux/amd64,linux/arm64 -t ghcr.io/drasi-project/learning/building-comfort/demo:latest --push demo/; then
    echo "ERROR: Failed to build demo"
    exit 1
fi

echo "All images built and pushed successfully!"