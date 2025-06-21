#!/bin/bash
# Development helper script for rebuilding and reloading local images
# Copyright 2025 The Drasi Authors.

set -e

if [ $# -eq 0 ]; then
    echo "Usage: ./dev-reload.sh <app-name>"
    echo "Available apps: control-panel, dashboard, demo"
    exit 1
fi

APP=$1
VALID_APPS=("control-panel" "dashboard" "demo")

# Check if app name is valid
if [[ ! " ${VALID_APPS[@]} " =~ " ${APP} " ]]; then
    echo "Error: Invalid app name '$APP'"
    echo "Available apps: ${VALID_APPS[@]}"
    exit 1
fi

# Check if directory exists
if [ ! -d "$APP" ]; then
    echo "Error: Directory '$APP' not found"
    exit 1
fi

# Build image with consistent naming
IMAGE_NAME="ghcr.io/drasi-project/learning/building-comfort/$APP:dev"

echo "Building local image for $APP..."
docker build -t $IMAGE_NAME $APP/

echo "Importing image to k3d cluster..."
k3d image import $IMAGE_NAME -c devcluster

echo "Updating deployment to use local image..."
kubectl set image deployment/$APP $APP=$IMAGE_NAME

echo "Setting imagePullPolicy to Never..."
kubectl patch deployment $APP -p '{"spec":{"template":{"spec":{"containers":[{"name":"'$APP'","imagePullPolicy":"Never"}]}}}}'

echo "Restarting deployment..."
kubectl rollout restart deployment/$APP

echo "Waiting for rollout to complete..."
kubectl rollout status deployment/$APP

echo "Done! $APP is now running with your local changes."
echo ""
echo "To revert to the original image, run:"
echo "  ./reset-images.sh $APP"