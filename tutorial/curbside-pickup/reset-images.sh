#!/bin/bash
# Reset app deployment to use official GHCR images
# Copyright 2025 The Drasi Authors.

set -e

if [ $# -eq 0 ]; then
    echo "Usage: ./reset-images.sh <app-name>"
    echo "Available apps: physical-ops, retail-ops, delivery-dashboard, delay-dashboard, demo"
    echo ""
    echo "To reset all apps, run: ./reset-images.sh all"
    exit 1
fi

APP=$1

# Function to reset a single app
reset_app() {
    local app=$1
    echo "Resetting $app to use official GHCR image..."
    
    kubectl set image deployment/$app $app=ghcr.io/drasi-project/learning/curbside-pickup/$app:latest
    kubectl patch deployment $app -p '{"spec":{"template":{"spec":{"containers":[{"name":"'$app'","imagePullPolicy":"Always"}]}}}}'
    
    echo "Restarting $app deployment..."
    kubectl rollout restart deployment/$app
    kubectl rollout status deployment/$app
    
    echo "$app reset to official image successfully!"
}

# Handle 'all' option
if [ "$APP" = "all" ]; then
    APPS=("physical-ops" "retail-ops" "delivery-dashboard" "delay-dashboard" "demo")
    for app in "${APPS[@]}"; do
        reset_app $app
    done
    echo "All apps have been reset to official images!"
else
    # Validate app name
    VALID_APPS=("physical-ops" "retail-ops" "delivery-dashboard" "delay-dashboard" "demo")
    if [[ ! " ${VALID_APPS[@]} " =~ " ${APP} " ]]; then
        echo "Error: Invalid app name '$APP'"
        echo "Available apps: ${VALID_APPS[@]}"
        exit 1
    fi
    
    reset_app $APP
fi