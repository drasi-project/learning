#!/bin/bash
# Unified script to build and push Docker images for Drasi tutorials
# This script is for Drasi maintainers only
# Copyright 2025 The Drasi Authors.
#
# Usage: ./build-and-push-tutorial.sh <tutorial-name> [tag]
# Examples:
#   ./build-and-push-tutorial.sh curbside-pickup
#   ./build-and-push-tutorial.sh building-comfort v1.0.0

set -e

# Validate arguments
if [ $# -lt 1 ]; then
    echo "Usage: $0 <tutorial-name> [tag]"
    echo "Available tutorials: curbside-pickup, building-comfort"
    echo "Default tag: latest"
    exit 1
fi

TUTORIAL=$1
TAG=${2:-latest}

# Get the script directory and project root
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/.." && pwd )"

# Validate tutorial name
case $TUTORIAL in
    "curbside-pickup"|"building-comfort")
        TUTORIAL_DIR="$PROJECT_ROOT/tutorial/$TUTORIAL"
        if [ ! -d "$TUTORIAL_DIR" ]; then
            echo "Error: Tutorial directory not found: $TUTORIAL_DIR"
            exit 1
        fi
        ;;
    *)
        echo "Error: Invalid tutorial name '$TUTORIAL'"
        echo "Available tutorials: curbside-pickup, building-comfort"
        exit 1
        ;;
esac

echo "Building images for $TUTORIAL tutorial with tag: $TAG"

# Function to check and generate package-lock.json if needed
check_npm_lock() {
    local dir=$1
    if [ -f "$dir/package.json" ] && [ ! -f "$dir/package-lock.json" ]; then
        echo "Missing package-lock.json in $dir, generating..."
        (cd "$dir" && npm install)
    fi
}

# Function to build and push an image
build_and_push() {
    local app=$1
    local context=$2
    
    echo "Building $app..."
    if ! docker buildx build \
        --platform linux/amd64,linux/arm64 \
        -t "ghcr.io/drasi-project/learning/$TUTORIAL/$app:$TAG" \
        --push \
        "$context"; then
        echo "ERROR: Failed to build $app"
        exit 1
    fi
    echo "Successfully built and pushed $app:$TAG"
}

# Ensure buildx is available
if ! docker buildx ls | grep -q multiarch-builder; then
    docker buildx create --use --name multiarch-builder --platform linux/amd64,linux/arm64
else
    docker buildx use multiarch-builder
fi

# Change to tutorial directory
cd "$TUTORIAL_DIR"

# Build images based on tutorial
case $TUTORIAL in
    "curbside-pickup")
        # Check for missing package-lock.json files
        check_npm_lock "./physical-ops/frontend"
        check_npm_lock "./retail-ops/frontend"
        check_npm_lock "./delivery-dashboard"
        check_npm_lock "./delay-dashboard"
        
        # Build all curbside-pickup images
        build_and_push "demo" "./demo"
        build_and_push "physical-ops" "./physical-ops"
        build_and_push "retail-ops" "./retail-ops"
        build_and_push "delivery-dashboard" "./delivery-dashboard"
        build_and_push "delay-dashboard" "./delay-dashboard"
        ;;
        
    "building-comfort")
        # Check for missing package-lock.json files
        check_npm_lock "./control-panel/frontend"
        check_npm_lock "./dashboard"
        
        # Build all building-comfort images
        build_and_push "control-panel" "./control-panel"
        build_and_push "dashboard" "./dashboard"
        build_and_push "demo" "./demo"
        ;;
esac

echo ""
echo "All images for $TUTORIAL tutorial have been built and pushed with tag: $TAG"
echo "Total images built: $([ "$TUTORIAL" = "curbside-pickup" ] && echo "5" || echo "3")"