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

set -e

# Define k3d version to use across all environments
K3D_VERSION="v5.6.0"

# Ensure kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "kubectl not found in PATH. Attempting to install..."
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    chmod +x kubectl
    sudo mv kubectl /usr/local/bin/
fi

# Verify kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "ERROR: kubectl is still not available. Please check the installation."
    exit 1
fi

# Install k3d if not present
if ! command -v k3d &> /dev/null; then
    echo "k3d not found. Installing k3d ${K3D_VERSION}..."
    curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | TAG=${K3D_VERSION} bash
else
    echo "k3d is already installed: $(k3d version | grep 'k3d version' || echo 'version unknown')"
fi

# Verify k3d is available
if ! command -v k3d &> /dev/null; then
    echo "ERROR: k3d installation failed."
    exit 1
fi

echo "Creating K3d cluster..."
# Delete existing cluster if it exists
k3d cluster delete drasi-tutorial 2>/dev/null || true
k3d cluster create drasi-tutorial --port "8123:80@loadbalancer"

echo "Waiting for cluster to be ready..."
kubectl wait --for=condition=ready node --all --timeout=60s

echo "Waiting for Traefik to be ready..."
# Wait for Traefik Helm job to complete
echo "Waiting for Traefik Helm installation..."
MAX_JOB_WAIT=30
JOB_WAITED=0
while [ $JOB_WAITED -lt $MAX_JOB_WAIT ]; do
    if kubectl get job -n kube-system helm-install-traefik >/dev/null 2>&1; then
        echo "Traefik Helm job found, waiting for completion..."
        kubectl wait --for=condition=complete job/helm-install-traefik -n kube-system --timeout=300s || {
            echo "Warning: Traefik Helm job didn't complete in time, continuing anyway..."
        }
        break
    fi
    echo "Waiting for Traefik Helm job to appear..."
    sleep 2
    JOB_WAITED=$((JOB_WAITED + 2))
done

if [ $JOB_WAITED -ge $MAX_JOB_WAIT ]; then
    echo "Warning: Traefik Helm job not found after ${MAX_JOB_WAIT}s, continuing anyway..."
fi

# Wait for Traefik CRDs to be available
echo "Waiting for Traefik CRDs..."
MAX_CRD_WAIT=60
CRD_WAITED=0
while [ $CRD_WAITED -lt $MAX_CRD_WAIT ]; do
    if kubectl get crd middlewares.traefik.containo.us >/dev/null 2>&1; then
        echo "Traefik CRDs are ready!"
        break
    fi
    echo "Waiting for Traefik CRDs to be created..."
    sleep 2
    CRD_WAITED=$((CRD_WAITED + 2))
done

if [ $CRD_WAITED -ge $MAX_CRD_WAIT ]; then
    echo "Warning: Traefik CRDs not found after ${MAX_CRD_WAIT}s, continuing anyway..."
fi

echo "Deploying PostgreSQL for Building Comfort..."
kubectl apply -f control-panel/k8s/postgres-database.yaml

echo "Waiting for PostgreSQL to be ready..."
kubectl wait --for=condition=ready pod -l app=postgres --timeout=120s

echo "Deploying dashboard application (no DB dependencies)..."
kubectl apply -f dashboard/k8s/deployment.yaml
kubectl apply -f dashboard/k8s/ingress.yaml

echo "Deploying demo application..."
kubectl apply -f demo/k8s/deployment.yaml
kubectl apply -f demo/k8s/ingress.yaml

echo "Waiting for dashboard and demo deployments to be ready..."
kubectl wait --for=condition=available deployment/dashboard deployment/demo --timeout=120s

echo "Deploying control panel application (with DB dependencies)..."
kubectl apply -f control-panel/k8s/deployment.yaml
kubectl apply -f control-panel/k8s/ingress.yaml

echo "Waiting for all deployments to be ready..."
kubectl wait --for=condition=available deployment --all --timeout=300s

echo "Initializing Drasi..."

# Configure Drasi to use kubectl context
echo "Configuring Drasi to use kubectl context..."
if drasi env kube 2>/dev/null; then
    echo "Drasi configured to use kubectl context"
else
    echo "WARNING: Failed to configure Drasi environment with 'drasi env kube'"
    echo "Continuing with initialization anyway..."
fi

MAX_ATTEMPTS=3
ATTEMPT=1
DRASI_INITIALIZED=false

while [ $ATTEMPT -le $MAX_ATTEMPTS ] && [ "$DRASI_INITIALIZED" = "false" ]; do
    echo "Drasi initialization attempt $ATTEMPT of $MAX_ATTEMPTS..."
    
    if drasi init; then
        DRASI_INITIALIZED=true
        echo "Drasi initialized successfully!"
    else
        echo "Drasi initialization failed."
        
        if [ $ATTEMPT -lt $MAX_ATTEMPTS ]; then
            echo "Uninstalling Drasi before retry..."
            drasi uninstall -y 2>/dev/null || true
            sleep 5
        else
            echo "ERROR: Failed to initialize Drasi after $MAX_ATTEMPTS attempts."
            exit 1
        fi
    fi
    
    ATTEMPT=$((ATTEMPT + 1))
done

# Install evaluation tools if running in tutorial evaluation workflow
source "$(dirname "$0")/../scripts/install-evaluation-tools.sh"

echo "Setup complete! Applications are available at:"
echo "  Demo (All Apps): http://localhost:8123/"
echo "  Control Panel: http://localhost:8123/control-panel"
echo "  Dashboard: http://localhost:8123/dashboard"
echo ""
echo "API Documentation:"
echo "  Swagger UI: http://localhost:8123/control-panel/docs"
echo "  ReDoc: http://localhost:8123/control-panel/redoc"
echo ""