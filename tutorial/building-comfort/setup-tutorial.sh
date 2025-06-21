#!/bin/bash
# Setup script for Building Comfort tutorial on any Kubernetes cluster
# Copyright 2025 The Drasi Authors.

set -e

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/../.." && pwd )"

# Source shared functions
source "$PROJECT_ROOT/scripts/setup-functions.sh"

# Display header
show_header "Building Comfort"

# Step 1: Check kubectl
check_kubectl

# Step 2: Check cluster connectivity
check_cluster

# Step 3: Check for Traefik
check_traefik

# Step 4: Check for Drasi CLI
check_drasi_cli

# Step 5: Initialize Drasi
init_drasi

# Step 6: Deploy database
print_info "Preparing to deploy database..."
if ask_user "Would you like to deploy the PostgreSQL database?"; then
    if k8s_resource_exists deployment postgres; then
        print_warning "PostgreSQL is already deployed"
    else
        print_info "Deploying PostgreSQL for Building Comfort..."
        kubectl apply -f "$SCRIPT_DIR/control-panel/k8s/postgres-database.yaml"
        wait_for_deployment postgres
    fi
else
    print_warning "Skipping database deployment"
fi

# Step 7: Deploy applications
print_info "Preparing to deploy tutorial applications..."
if ask_user "Would you like to deploy all tutorial applications?"; then
    # Deploy applications
    APPS=(
        "control-panel"
        "dashboard"
        "demo"
    )
    
    for APP in "${APPS[@]}"; do
        if k8s_resource_exists deployment $APP; then
            print_warning "$APP is already deployed"
        else
            print_info "Deploying $APP..."
            kubectl apply -f "$SCRIPT_DIR/$APP/k8s/deployment.yaml"
        fi
    done
    
    # Wait for all deployments
    print_info "Waiting for all applications to be ready..."
    for APP in "${APPS[@]}"; do
        wait_for_deployment $APP || true
    done
else
    print_warning "Skipping application deployment"
fi

# Display completion message
show_completion

# Get ingress information
INGRESS_IP=$(get_ingress_address)

if kubectl get ingress >/dev/null 2>&1; then
    print_info "Application URLs:"
    echo "  Demo: http://$INGRESS_IP/"
    echo "  Control Panel: http://$INGRESS_IP/control-panel"
    echo "  Dashboard: http://$INGRESS_IP/dashboard"
else
    print_warning "No ingress resources found. You may need to configure access manually."
fi

echo ""
print_info "Next steps:"
echo "1. Deploy Drasi sources, queries, and reactions from the drasi-sources directory"
echo "2. For SignalR reactions, you'll need to port-forward:"
echo "   kubectl port-forward service/signalr-hub 8080:80"
echo ""
print_success "Happy learning!"