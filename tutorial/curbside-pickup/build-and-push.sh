#!/bin/bash
# Script to build and push all images to GHCR
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
check_npm_lock "./physical-ops/frontend"
check_npm_lock "./retail-ops/frontend"
check_npm_lock "./delivery-dashboard"
check_npm_lock "./delay-dashboard"

# Build and push demo
echo "Building and pushing demo..."
if ! docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t ghcr.io/drasi-project/learning/curbside-pickup/demo:latest \
  --push \
  ./demo; then
  echo "ERROR: Failed to build demo"
  exit 1
fi

# Build and push physical-ops
echo "Building and pushing physical-ops..."
if ! docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t ghcr.io/drasi-project/learning/curbside-pickup/physical-ops:latest \
  --push \
  ./physical-ops; then
  echo "ERROR: Failed to build physical-ops"
  exit 1
fi

# Build and push retail-ops
echo "Building and pushing retail-ops..."
if ! docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t ghcr.io/drasi-project/learning/curbside-pickup/retail-ops:latest \
  --push \
  ./retail-ops; then
  echo "ERROR: Failed to build retail-ops"
  exit 1
fi

# Build and push delivery-dashboard
echo "Building and pushing delivery-dashboard..."
if ! docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t ghcr.io/drasi-project/learning/curbside-pickup/delivery-dashboard:latest \
  --push \
  ./delivery-dashboard; then
  echo "ERROR: Failed to build delivery-dashboard"
  exit 1
fi

# Build and push delay-dashboard
echo "Building and pushing delay-dashboard..."
if ! docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t ghcr.io/drasi-project/learning/curbside-pickup/delay-dashboard:latest \
  --push \
  ./delay-dashboard; then
  echo "ERROR: Failed to build delay-dashboard"
  exit 1
fi

echo "All images built and pushed successfully!"