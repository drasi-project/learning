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

#!/bin/bash
# Building Comfort Tutorial Setup Script
# This script deploys the Building Comfort tutorial applications to your Kubernetes cluster

set -euo pipefail

# Get script and project directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TUTORIAL_DIR="$(dirname "$SCRIPT_DIR")"
PROJECT_ROOT="$(dirname "$(dirname "$TUTORIAL_DIR")")"

# Colors for output
INFO='\033[0;36m'      # Cyan
SUCCESS='\033[0;32m'   # Green
WARNING='\033[0;33m'   # Yellow
ERROR='\033[0;31m'     # Red
NC='\033[0m'           # No Color

print_info() {
    printf "${INFO}[*] %s${NC}\n" "$1"
}

print_success() {
    printf "${SUCCESS}[+] %s${NC}\n" "$1"
}

print_warning() {
    printf "${WARNING}[!] %s${NC}\n" "$1"
}

print_error() {
    printf "${ERROR}[x] %s${NC}\n" "$1"
}

show_header() {
    echo
    printf "${INFO}=== Building Comfort Tutorial Setup ===${NC}\n"
    echo
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Portable timeout function using perl (available on all Linux and macOS systems)
timeout_command() {
    local duration=$1
    shift
    
    # Run command with timeout using perl
    perl -e '
        $SIG{ALRM} = sub { die "timeout\n" };
        alarm shift;
        $ret = system(@ARGV);
        alarm 0;
        exit($ret >> 8);
    ' "$duration" "$@"
}

test_prerequisites() {
    print_info "Checking prerequisites..."
    
    # Check kubectl
    if ! command_exists kubectl; then
        print_error "kubectl not found. Install from https://kubernetes.io/docs/tasks/tools/"
        exit 1
    fi
    print_success "kubectl: OK"
    
    # Check cluster connection
    print_info "Checking Kubernetes cluster connection..."
    timeout_command 20s kubectl cluster-info >/dev/null 2>&1
    local exit_code=$?
    
    if [ $exit_code -ne 0 ]; then
        # Check if it was a timeout (exit code 255 from our perl script when it dies)
        if [ $exit_code -eq 255 ]; then
            print_error "Cannot connect to Kubernetes cluster (timeout after 20 seconds)"
            print_error "Please ensure you have a k3d cluster running:"
            print_error "  k3d cluster create drasi-tutorial -p '8123:80@loadbalancer'"
            echo
            print_error "Or check your kubectl context:"
            print_error "  kubectl config current-context"
        else
            print_error "No Kubernetes cluster found or connection failed"
            print_error "Please create a k3d cluster first:"
            print_error "  k3d cluster create drasi-tutorial -p '8123:80@loadbalancer'"
        fi
        exit 1
    fi
    print_success "cluster: OK"
    
    # Check drasi CLI
    if ! command_exists drasi; then
        print_error "drasi CLI not found. Install from https://drasi.io/reference/command-line-interface/#get-the-drasi-cli"
        exit 1
    fi
    print_success "drasi: OK"
}

initialize_drasi() {
    print_info "Initializing Drasi (required)..."
    
    # Check if drasi-system namespace exists
    if kubectl get namespace drasi-system >/dev/null 2>&1; then
        print_success "Drasi is already initialized"
        return
    fi
    
    # Configure drasi environment
    print_info "Configuring Drasi environment..."
    if ! drasi env kube; then
        print_warning "Failed to configure Drasi environment, continuing anyway..."
    fi
    
    # Try to initialize Drasi (up to 3 attempts)
    max_attempts=3
    for i in $(seq 1 $max_attempts); do
        print_info "Initialization attempt $i of $max_attempts..."
        
        if drasi init; then
            print_success "Drasi initialized successfully"
            sleep 10  # Give resources time to create
            break
        fi
        
        if [ $i -lt $max_attempts ]; then
            print_warning "Initialization failed, cleaning up and retrying..."
            drasi uninstall -y >/dev/null 2>&1 || true
            kubectl delete ns drasi-system --force --grace-period=0 >/dev/null 2>&1 || true
            
            # Wait for namespace to be fully deleted
            print_info "Waiting for namespace cleanup..."
            local wait_time=0
            while kubectl get ns drasi-system >/dev/null 2>&1 && [ $wait_time -lt 30 ]; do
                sleep 2
                wait_time=$((wait_time + 2))
            done
            sleep 5
        else
            print_error "Failed to initialize Drasi after $max_attempts attempts"
            exit 1
        fi
    done
    
    # Verify Drasi is working
    print_info "Verifying Drasi installation..."
    if ! drasi list source >/dev/null 2>&1; then
        print_error "Drasi installation failed. Please check logs."
        exit 1
    fi
    print_success "Drasi is ready"
}

deploy_database() {
    print_info "Deploying PostgreSQL database..."
    
    cd "$TUTORIAL_DIR"
    if ! kubectl apply -f control-panel/k8s/postgres-database.yaml; then
        print_error "Failed to deploy PostgreSQL"
        exit 1
    fi
    
    print_info "Waiting for PostgreSQL to be ready..."
    if ! kubectl wait --for=condition=ready pod -l app=postgres --timeout=300s; then
        print_error "PostgreSQL failed to start"
        exit 1
    fi
    
    print_success "PostgreSQL: Ready"
}

deploy_applications() {
    print_info "Deploying applications..."
    
    cd "$TUTORIAL_DIR"
    
    # Deploy all applications
    kubectl apply -f dashboard/k8s/deployment.yaml
    kubectl apply -f demo/k8s/deployment.yaml
    kubectl apply -f control-panel/k8s/deployment.yaml
    
    # Wait for deployments to be ready
    print_info "Waiting for applications to be ready..."
    
    apps=("dashboard" "demo" "control-panel")
    for app in "${apps[@]}"; do
        if kubectl wait --for=condition=available deployment/$app --timeout=300s; then
            print_success "$app: Ready"
        else
            print_error "$app: Failed to start"
            exit 1
        fi
    done
}

setup_ingress() {
    print_info "Setting up ingress routes (required)..."
    
    # Check if Traefik CRDs exist (v2.x uses traefik.containo.us)
    if ! kubectl get crd ingressroutes.traefik.containo.us >/dev/null 2>&1; then
        print_error "Traefik v2.x not found. The tutorial requires Traefik v2.x ingress controller."
        echo
        echo "Solutions:"
        echo "1. Ensure your k3d cluster was created WITHOUT '--k3s-arg --disable=traefik@server:0'"
        echo "2. Recreate cluster: k3d cluster create drasi-tutorial -p '8123:80@loadbalancer'"
        echo
        print_error "Setup aborted. Please fix ingress and re-run."
        exit 1
    fi
    
    print_info "Deploying ingress routes..."
    cd "$TUTORIAL_DIR"
    
    # Deploy ingress routes (all must succeed)
    if ! kubectl apply -f dashboard/k8s/ingress.yaml; then
        print_error "Failed to deploy dashboard ingress"
        exit 1
    fi
    
    if ! kubectl apply -f demo/k8s/ingress.yaml; then
        print_error "Failed to deploy demo ingress"
        exit 1
    fi
    
    if ! kubectl apply -f control-panel/k8s/ingress.yaml; then
        print_error "Failed to deploy control-panel ingress"
        exit 1
    fi
    
    print_success "Ingress routes configured"
}

show_access_instructions() {
    echo
    print_success "Setup complete!"
    echo
    
    print_info "Access the applications at:"
    echo "  - Demo Portal:   http://localhost:8123/"
    echo "  - Dashboard:     http://localhost:8123/dashboard"
    echo "  - Control Panel: http://localhost:8123/control-panel"
    echo "  - API Docs:      http://localhost:8123/control-panel/docs"
    echo
    print_info "Note: This assumes your k3d cluster was created with port mapping 8123:80"
    
    echo
    print_info "Next steps:"
    echo "  1. Deploy Drasi resources: cd tutorial/building-comfort/drasi"
    echo "  2. Apply sources, queries, and reactions"
    echo
}

# Main execution
show_header
test_prerequisites
initialize_drasi
deploy_database
deploy_applications
setup_ingress
show_access_instructions