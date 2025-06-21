#!/bin/bash
# Shared functions for tutorial setup scripts
# Copyright 2025 The Drasi Authors.

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
    
    while true; do
        echo -e "\n${YELLOW}$prompt${NC}"
        echo "Options:"
        echo "  y) Yes - proceed with installation"
        echo "  s) Skip - skip this step"
        echo "  q) Quit - stop the setup"
        read -p "Your choice [y/s/q]: " action
        
        case $action in
            [Yy]* ) return 0;;
            [Ss]* ) return 1;;
            [Qq]* ) print_info "Setup cancelled by user."; exit 0;;
            * ) echo "Please answer y (yes), s (skip), or q (quit).";;
        esac
    done
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

# Function to check cluster connectivity
check_cluster() {
    print_info "Checking Kubernetes cluster connectivity..."
    if kubectl cluster-info >/dev/null 2>&1; then
        print_success "Connected to Kubernetes cluster"
        kubectl cluster-info
    else
        print_error "Cannot connect to Kubernetes cluster. Please ensure you have a valid kubeconfig."
        exit 1
    fi
}

# Function to check and install Traefik
check_traefik() {
    print_info "Checking for Traefik ingress controller..."
    if kubectl get deployment -A | grep -q traefik; then
        print_success "Traefik is already installed"
    else
        print_warning "Traefik ingress controller not found"
        if ask_user "Would you like to install Traefik? (Required for ingress routing)"; then
            print_info "Installing Traefik using Helm..."
            
            # Check for Helm
            if ! command_exists helm; then
                print_error "Helm is not installed. Please install Helm first or install Traefik manually."
                print_info "Visit: https://helm.sh/docs/intro/install/"
                exit 1
            fi
            
            # Add Traefik Helm repository
            helm repo add traefik https://helm.traefik.io/traefik
            helm repo update
            
            # Install Traefik
            helm install traefik traefik/traefik \
                --create-namespace \
                --namespace traefik \
                --set ports.web.nodePort=30080 \
                --set ports.websecure.nodePort=30443 \
                --set service.type=NodePort
                
            print_success "Traefik installed successfully"
            print_info "Traefik is accessible on NodePort 30080 (HTTP) and 30443 (HTTPS)"
        else
            print_warning "Skipping Traefik installation. Note that ingress routing will not work without it."
        fi
    fi
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
            
            # Detect OS and architecture
            OS=$(uname -s | tr '[:upper:]' '[:lower:]')
            ARCH=$(uname -m)
            
            case $ARCH in
                x86_64) ARCH="x64" ;;
                aarch64|arm64) ARCH="arm64" ;;
                *) print_error "Unsupported architecture: $ARCH"; exit 1 ;;
            esac
            
            # Download and install Drasi CLI
            DRASI_VERSION="latest"  # You can change this to a specific version
            DOWNLOAD_URL="https://github.com/drasi-project/drasi-platform/releases/download/${DRASI_VERSION}/drasi-${OS}-${ARCH}"
            
            curl -L -o drasi "$DOWNLOAD_URL"
            chmod +x drasi
            sudo mv drasi /usr/local/bin/
            
            print_success "Drasi CLI installed successfully"
        else
            print_warning "Skipping Drasi CLI installation. Note that Drasi is required for this tutorial."
            exit 1
        fi
    fi
}

# Function to initialize Drasi
init_drasi() {
    print_info "Checking Drasi installation..."
    if kubectl get namespace drasi-system >/dev/null 2>&1; then
        print_success "Drasi is already initialized"
    else
        print_warning "Drasi is not initialized"
        if ask_user "Would you like to initialize Drasi on this cluster?"; then
            print_info "Initializing Drasi..."
            
            MAX_ATTEMPTS=3
            ATTEMPT=1
            DRASI_INITIALIZED=false
            
            while [ $ATTEMPT -le $MAX_ATTEMPTS ] && [ "$DRASI_INITIALIZED" = "false" ]; do
                print_info "Drasi initialization attempt $ATTEMPT of $MAX_ATTEMPTS..."
                
                if drasi init; then
                    DRASI_INITIALIZED=true
                    print_success "Drasi initialized successfully!"
                else
                    print_error "Drasi initialization failed."
                    
                    if [ $ATTEMPT -lt $MAX_ATTEMPTS ]; then
                        print_info "Uninstalling Drasi before retry..."
                        drasi uninstall --force -y 2>/dev/null || true
                        sleep 5
                    else
                        print_error "Failed to initialize Drasi after $MAX_ATTEMPTS attempts."
                        exit 1
                    fi
                fi
                
                ATTEMPT=$((ATTEMPT + 1))
            done
        else
            print_warning "Skipping Drasi initialization. Note that Drasi is required for this tutorial."
            exit 1
        fi
    fi
}

# Function to display tutorial header
show_header() {
    local tutorial_name=$1
    echo -e "${GREEN}================================${NC}"
    echo -e "${GREEN}$tutorial_name Tutorial Setup${NC}"
    echo -e "${GREEN}================================${NC}"
    echo ""
    print_info "This script will set up all required components for the $tutorial_name tutorial."
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
    print_info "Tutorial applications have been deployed."
    echo ""
}

# Function to get ingress IP or hostname
get_ingress_address() {
    local ingress_ip=""
    
    # Try to get LoadBalancer IP
    ingress_ip=$(kubectl get svc -n traefik traefik -o jsonpath='{.status.loadBalancer.ingress[0].ip}' 2>/dev/null)
    
    if [ -z "$ingress_ip" ]; then
        # Try to get LoadBalancer hostname
        ingress_ip=$(kubectl get svc -n traefik traefik -o jsonpath='{.status.loadBalancer.ingress[0].hostname}' 2>/dev/null)
    fi
    
    if [ -z "$ingress_ip" ]; then
        # Fallback to NodePort
        ingress_ip="<NODE_IP>:30080"
    fi
    
    echo "$ingress_ip"
}