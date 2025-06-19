#!/bin/bash
# Script to build and push all images to GHCR

# Ensure buildx is available
docker buildx create --use --name multiarch-builder || docker buildx use multiarch-builder

# Build and push demo
echo "Building and pushing demo..."
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t ghcr.io/drasi-project/learning/curbside-pickup/demo:latest \
  --push \
  ./demo

# Build and push physical-ops
echo "Building and pushing physical-ops..."
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t ghcr.io/drasi-project/learning/curbside-pickup/physical-ops:latest \
  --push \
  ./physical-ops

# Build and push retail-ops
echo "Building and pushing retail-ops..."
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t ghcr.io/drasi-project/learning/curbside-pickup/retail-ops:latest \
  --push \
  ./retail-ops

# Build and push delivery-dashboard
echo "Building and pushing delivery-dashboard..."
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t ghcr.io/drasi-project/learning/curbside-pickup/delivery-dashboard:latest \
  --push \
  ./delivery-dashboard

# Build and push delay-dashboard
echo "Building and pushing delay-dashboard..."
docker buildx build \
  --platform linux/amd64,linux/arm64 \
  -t ghcr.io/drasi-project/learning/curbside-pickup/delay-dashboard:latest \
  --push \
  ./delay-dashboard

echo "All images built and pushed successfully!"