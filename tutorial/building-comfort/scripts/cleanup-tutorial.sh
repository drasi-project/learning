#!/bin/bash
# Copyright 2025 The Drasi Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
# Cleanup script for Building Comfort tutorial

set -e

# Get the directory where this script is located
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$( cd "$SCRIPT_DIR/../../.." && pwd )"

# Source shared functions
source "$PROJECT_ROOT/scripts/setup-functions.sh"

# Display header
show_header "Building Comfort Cleanup"

# Step 1: Delete tutorial Kubernetes resources
if ask_user "Delete all Building Comfort tutorial resources from Kubernetes?"; then
    print_info "Deleting application deployments and services..."
    delete_k8s_resources deployment dashboard control-panel demo postgres
    delete_k8s_resources service dashboard control-panel demo postgres
    
    print_info "Deleting ingresses..."
    delete_k8s_resources ingress dashboard-ingress control-panel-ingress demo-ingress
    
    print_info "Deleting configmaps..."
    # PostgreSQL related configmaps
    delete_k8s_resources configmap postgres-init postgres-config
    
    # Delete any other configmaps that might have been created
    kubectl get configmap -o name | grep -E "(dashboard|control-panel|demo|postgres)" | xargs -r kubectl delete --ignore-not-found=true
    
    print_success "Tutorial resources deleted"
else
    print_info "Skipping tutorial resource deletion"
fi

echo ""

# Step 2: Uninstall Drasi
if ask_user "Uninstall Drasi from the cluster?"; then
    print_info "Checking if Drasi is installed..."
    if kubectl get namespace drasi-system >/dev/null 2>&1; then
        print_info "Uninstalling Drasi (this will not remove Dapr)..."
        if drasi uninstall -y; then
            print_success "Drasi uninstalled successfully"
        else
            print_warning "Drasi uninstall failed - it may not be installed or the CLI is not available"
        fi
    else
        print_info "Drasi is not installed"
    fi
else
    print_info "Skipping Drasi uninstallation"
fi

echo ""

# Step 3: Delete k3d cluster
if ask_user "Delete k3d cluster?"; then
    print_info "Checking for k3d clusters..."
    if command_exists k3d; then
        # Show available k3d clusters
        CLUSTERS=$(k3d cluster list -o json 2>/dev/null | jq -r '.[].name' 2>/dev/null || echo "")
        
        if [ -z "$CLUSTERS" ]; then
            print_info "No k3d clusters found"
        else
            print_info "Available k3d clusters:"
            echo "$CLUSTERS" | nl -nrz -w2
            
            # Check if drasi-tutorial exists
            if echo "$CLUSTERS" | grep -q "^drasi-tutorial$"; then
                if ask_user "Delete k3d cluster 'drasi-tutorial'?"; then
                    print_info "Deleting k3d cluster 'drasi-tutorial'..."
                    if k3d cluster delete drasi-tutorial; then
                        print_success "k3d cluster deleted successfully"
                    else
                        print_warning "Failed to delete k3d cluster"
                    fi
                fi
            else
                print_info "Tutorial cluster not found. You can manually delete any cluster using: k3d cluster delete <name>"
            fi
        fi
    else
        print_info "k3d is not installed"
    fi
else
    print_info "Skipping k3d cluster deletion"
fi

echo ""
print_success "Cleanup complete!"
echo ""
print_info "Note: This script does not remove installed CLI tools (kubectl, k3d, drasi)."
print_info "If you want to remove them, please do so manually."