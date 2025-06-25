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
#
# Shared functions for Drasi setup scripts

# Color codes for output
export RED='\033[0;31m'
export GREEN='\033[0;32m'
export YELLOW='\033[1;33m'
export BLUE='\033[0;34m'
export NC='\033[0m' # No Color

# Function to print colored output
print_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Function to ask user for action
ask_user() {
    local prompt=$1
    local action
    
    echo -e "\n${YELLOW}$prompt${NC}"
    echo "Options:"
    echo "  y) Yes - proceed with installation (default)"
    echo "  s) Skip - skip this step"
    echo "  q) Quit - stop the setup"
    read -p "Your choice [y/s/q] (default: y): " action
    
    # Default to yes if user just presses enter
    if [ -z "$action" ]; then
        action="y"
    fi
    
    case $action in
        [Yy]* ) return 0;;
        [Ss]* ) return 1;;
        [Qq]* ) print_info "Setup cancelled by user."; exit 0;;
        * ) echo "Invalid choice. Defaulting to Yes."; return 0;;
    esac
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if a Kubernetes resource exists
k8s_resource_exists() {
    kubectl get "$1" "$2" >/dev/null 2>&1
}

# Function to wait for deployment to be ready
wait_for_deployment() {
    local deployment=$1
    local namespace=${2:-default}
    local timeout=${3:-300}
    
    print_info "Waiting for deployment $deployment to be ready..."
    if kubectl wait --for=condition=available deployment/$deployment -n $namespace --timeout=${timeout}s; then
        print_success "Deployment $deployment is ready"
        return 0
    else
        print_error "Deployment $deployment failed to become ready"
        return 1
    fi
}

# Function to check and install kubectl
check_kubectl() {
    print_info "Checking for kubectl..."
    if command_exists kubectl; then
        print_success "kubectl is installed ($(kubectl version --client --short 2>/dev/null || echo 'version info not available'))"
    else
        print_warning "kubectl is not installed or not in PATH"
        if ask_user "Would you like to install kubectl?"; then
            print_info "Installing kubectl..."
            if [[ "$OSTYPE" == "darwin"* ]]; then
                # macOS
                curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/$(uname -m)/kubectl"
                chmod +x ./kubectl
                sudo mv ./kubectl /usr/local/bin/kubectl
            elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
                # Linux
                curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
                chmod +x ./kubectl
                sudo mv ./kubectl /usr/local/bin/kubectl
            else
                print_error "Unsupported OS. Please install kubectl manually."
                exit 1
            fi
            print_success "kubectl installed successfully"
        else
            print_warning "Skipping kubectl installation. Note that kubectl is required for the rest of the setup."
            exit 1
        fi
    fi
}



# Function to check Traefik in k3d cluster
check_traefik() {
    print_info "Checking Traefik in k3d cluster..."
    
    # Wait for k3d to fully initialize Traefik
    print_info "Waiting for Traefik to initialize..."
    local max_wait=60
    local waited=0
    
    # Wait for Traefik helm job to complete
    while [ $waited -lt $max_wait ]; do
        if kubectl get job -n kube-system helm-install-traefik >/dev/null 2>&1; then
            if kubectl wait --for=condition=complete job/helm-install-traefik -n kube-system --timeout=5s >/dev/null 2>&1; then
                print_success "Traefik installation completed"
                break
            fi
        fi
        sleep 2
        waited=$((waited + 2))
    done
    
    # Check for Traefik in both possible locations (k3d v4 vs v5)
    local traefik_found=false
    local traefik_namespace=""
    
    # Check kube-system namespace first (k3d default)
    if kubectl get deployment -n kube-system traefik >/dev/null 2>&1; then
        traefik_found=true
        traefik_namespace="kube-system"
    # Also check for DaemonSet (some k3d versions use this)
    elif kubectl get daemonset -n kube-system traefik >/dev/null 2>&1; then
        traefik_found=true
        traefik_namespace="kube-system"
    # Check if svclb-traefik exists (indicates Traefik is there)
    elif kubectl get daemonset -n kube-system svclb-traefik >/dev/null 2>&1; then
        traefik_found=true
        traefik_namespace="kube-system"
    fi
    
    if [ "$traefik_found" = "true" ]; then
        print_success "Traefik found in $traefik_namespace namespace"
        
        # Check if CRDs are available
        if kubectl get crd middlewares.traefik.containo.us >/dev/null 2>&1; then
            print_success "Traefik CRDs are available"
            return 0
        else
            print_warning "Traefik is running but CRDs are missing"
            print_info "Waiting for CRDs to be created..."
            sleep 5
            
            # Try one more time
            if kubectl get crd middlewares.traefik.containo.us >/dev/null 2>&1; then
                print_success "Traefik CRDs are now available"
                return 0
            else
                print_warning "Traefik CRDs still not available"
            fi
        fi
    else
        print_warning "Traefik not found in standard locations"
        
        # Check all namespaces as last resort
        print_info "Searching for Traefik in all namespaces..."
        if kubectl get deployment,daemonset -A | grep -i traefik; then
            print_info "Found Traefik components above"
        else
            print_warning "No Traefik components found in the cluster"
        fi
    fi
    
    # Traefik is missing or incompatible
    echo ""
    print_warning "Traefik is missing or incompatible."
    echo "Traefik v2.x with CRDs is required for ingress routing."
    echo ""
    echo "Options:"
    echo "  1) I'll fix Traefik myself (script will wait for you)"
    echo "  2) Skip ingress setup (you'll need to use kubectl port-forward)"
    echo "  3) Quit setup"
    
    local choice
    read -p "Your choice [1-3]: " choice
    
    case $choice in
        1)
            print_info "Waiting for you to fix Traefik..."
            echo "Please ensure:"
            echo "  - Traefik v2.x is installed in your cluster"
            echo "  - CRD 'middlewares.traefik.containo.us' exists"
            echo ""
            read -p "Press Enter when ready to continue..."
            
            # Re-check after user says they're ready
            if kubectl get deployment -n kube-system traefik >/dev/null 2>&1 && \
               kubectl get crd middlewares.traefik.containo.us >/dev/null 2>&1; then
                print_success "Traefik verified successfully!"
                return 0
            else
                print_error "Traefik still not properly configured"
                return 1
            fi
            ;;
        2)
            print_info "Continuing without ingress setup"
            print_warning "You'll need to use kubectl port-forward to access applications"
            return 1
            ;;
        3)
            print_info "Setup cancelled by user"
            exit 0
            ;;
        *)
            print_error "Invalid choice"
            return 1
            ;;
    esac
}



# Function to check and install Drasi CLI
check_drasi_cli() {
    print_info "Checking for Drasi CLI..."
    if command_exists drasi; then
        print_success "Drasi CLI is installed ($(drasi version 2>/dev/null || echo 'version info not available'))"
    else
        print_warning "Drasi CLI is not installed"
        if ask_user "Would you like to install Drasi CLI?"; then
            print_info "Installing Drasi CLI..."
            
            # Use the official installer script
            curl -fsSL https://raw.githubusercontent.com/drasi-project/drasi-platform/main/cli/installers/install-drasi-cli.sh | /bin/bash
            
            if command_exists drasi; then
                print_success "Drasi CLI installed successfully"
            else
                print_error "Drasi CLI installation failed"
                return 1
            fi
        else
            print_warning "Skipping Drasi CLI installation."
            exit 1
        fi
    fi
}

# Function to initialize Drasi
init_drasi() {
    print_info "Initializing Drasi on the cluster..."
    
    MAX_ATTEMPTS=3
    ATTEMPT=1
    
    while [ $ATTEMPT -le $MAX_ATTEMPTS ]; do
        print_info "Drasi initialization attempt $ATTEMPT of $MAX_ATTEMPTS..."
        
        if drasi init; then
            print_success "Drasi initialized successfully!"
            return 0
        else
            print_error "Drasi initialization failed."
            
            if [ $ATTEMPT -lt $MAX_ATTEMPTS ]; then
                print_info "Cleaning up failed installation before retry..."
                drasi uninstall -y 2>/dev/null || true
                sleep 5
            else
                print_error "Failed to initialize Drasi after $MAX_ATTEMPTS attempts."
                return 1
            fi
        fi
        
        ATTEMPT=$((ATTEMPT + 1))
    done
}

# Function to display header
show_header() {
    local app_name=$1
    echo -e "${GREEN}================================${NC}"
    echo -e "${GREEN}$app_name Setup${NC}"
    echo -e "${GREEN}================================${NC}"
    echo ""
    print_info "This script will set up all required components."
    print_info "You will be prompted before each major step."
    echo ""
}

# Function to display completion message
show_completion() {
    echo ""
    echo -e "${GREEN}================================${NC}"
    echo -e "${GREEN}Setup Complete!${NC}"
    echo -e "${GREEN}================================${NC}"
    echo ""
    print_info "Applications have been deployed."
    echo ""
}



# Function to select deployment mode
select_deployment_mode() {
    echo "" >&2
    echo -e "${BLUE}[INFO]${NC} Select deployment mode:" >&2
    echo "" >&2
    echo -e "  1) ${GREEN}k3d Setup${NC} (Recommended)" >&2
    echo "     - Sets up k3d cluster with Traefik" >&2
    echo "     - Installs Drasi platform (includes Dapr)" >&2
    echo "     - Deploys databases and applications" >&2
    echo "     - Access apps via: http://localhost/" >&2
    echo "" >&2
    echo -e "  2) ${YELLOW}Apps Only${NC} (For existing infrastructure)" >&2
    echo "     - Assumes Kubernetes cluster exists" >&2
    echo "     - Assumes Drasi is already installed" >&2
    echo "     - Only deploys databases and applications" >&2
    echo "     - No ingress setup (use kubectl port-forward)" >&2
    echo "" >&2
    
    local mode
    while true; do
        read -p "Enter your choice [1-2] (default: 1): " mode
        
        # Default to 1 if empty
        if [ -z "$mode" ]; then
            mode="1"
        fi
        
        case $mode in
            1) echo "k3d"; return 0;;
            2) echo "apps-only"; return 0;;
            *) echo "Invalid choice. Please enter 1 or 2." >&2;;
        esac
    done
}

# Function to deploy application based on mode
deploy_app() {
    local app=$1
    local deployment_yaml=$2
    local ingress_yaml=$3
    local deploy_ingress=$4
    
    # Always deploy the main deployment and service
    kubectl apply -f "$deployment_yaml"
    
    # Deploy ingress only if requested and file exists
    if [ "$deploy_ingress" = "true" ] && [ -f "$ingress_yaml" ]; then
        kubectl apply -f "$ingress_yaml"
    fi
}

# Function to delete K8s resources safely
delete_k8s_resources() {
    local resource_type=$1
    shift
    local resources="$@"
    
    if [ -n "$resources" ]; then
        print_info "Deleting $resource_type: $resources"
        kubectl delete $resource_type $resources --ignore-not-found=true
    fi
}

# Function to delete all resources with a specific label
delete_by_label() {
    local label=$1
    print_info "Deleting all resources with label: $label"
    kubectl delete all -l "$label" --ignore-not-found=true
}