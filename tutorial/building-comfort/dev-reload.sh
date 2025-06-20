#!/bin/bash

# Hot reload for development
# Usage: ./dev-reload.sh <app-name>

APP_NAME=$1

if [ -z "$APP_NAME" ]; then
    echo "Usage: ./dev-reload.sh <app-name>"
    echo "Available apps: control-panel, dashboard, demo"
    exit 1
fi

echo "Building $APP_NAME locally..."
docker build -t building-comfort/$APP_NAME:dev $APP_NAME/

echo "Importing to k3d..."
k3d image import -c devcluster building-comfort/$APP_NAME:dev

echo "Updating deployment..."
kubectl set image deployment/$APP_NAME $APP_NAME=building-comfort/$APP_NAME:dev

echo "Setting imagePullPolicy to Never..."
kubectl patch deployment $APP_NAME -p '{"spec":{"template":{"spec":{"containers":[{"name":"'$APP_NAME'","imagePullPolicy":"Never"}]}}}}'

echo "Restarting deployment..."
kubectl rollout restart deployment/$APP_NAME

echo "Done! Check status with: kubectl rollout status deployment/$APP_NAME"