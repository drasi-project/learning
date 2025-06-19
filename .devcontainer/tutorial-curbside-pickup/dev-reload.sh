#!/bin/bash
# Development helper script for rebuilding and reloading local images

if [ $# -eq 0 ]; then
    echo "Usage: ./dev-reload.sh <app-name>"
    echo "Available apps: physical-ops, retail-ops, delivery-dashboard, delay-dashboard, demo"
    exit 1
fi

APP=$1
VALID_APPS=("physical-ops" "retail-ops" "delivery-dashboard" "delay-dashboard" "demo")

# Check if app name is valid
if [[ ! " ${VALID_APPS[@]} " =~ " ${APP} " ]]; then
    echo "Error: Invalid app name '$APP'"
    echo "Available apps: ${VALID_APPS[@]}"
    exit 1
fi

echo "Building local image for $APP..."
docker build -t $APP:dev $APP/

if [ $? -ne 0 ]; then
    echo "Error: Failed to build image"
    exit 1
fi

echo "Importing image to k3d cluster..."
k3d image import $APP:dev -c devcluster

echo "Updating deployment to use local image..."
kubectl set image deployment/$APP $APP=$APP:dev

echo "Setting imagePullPolicy to Never..."
kubectl patch deployment $APP -p '{"spec":{"template":{"spec":{"containers":[{"name":"'$APP'","imagePullPolicy":"Never"}]}}}}'

echo "Restarting deployment..."
kubectl rollout restart deployment/$APP

echo "Waiting for rollout to complete..."
kubectl rollout status deployment/$APP

echo "Done! $APP is now running with your local changes."