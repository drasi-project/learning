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

echo "Creating K3d cluster..."
# Delete existing cluster if it exists
k3d cluster delete devcluster 2>/dev/null || true
k3d cluster create devcluster --port "80:80@loadbalancer"

echo "Waiting for cluster to be ready..."
kubectl wait --for=condition=ready node --all --timeout=60s

echo "Deploying PostgreSQL for Building Comfort..."
kubectl apply -f control-panel/k8s/postgres-database.yaml

echo "Waiting for PostgreSQL to be ready..."
kubectl wait --for=condition=ready pod -l app=postgres --timeout=120s

echo "Deploying dashboard application (no DB dependencies)..."
kubectl apply -f dashboard/k8s/deployment.yaml

echo "Deploying demo application..."
kubectl apply -f demo/k8s/deployment.yaml

echo "Waiting for dashboard and demo deployments to be ready..."
kubectl wait --for=condition=available deployment/dashboard deployment/demo --timeout=120s

echo "Deploying control panel application (with DB dependencies)..."
kubectl apply -f control-panel/k8s/deployment.yaml

echo "Waiting for all deployments to be ready..."
kubectl wait --for=condition=available deployment --all --timeout=300s

echo "Initializing Drasi..."
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
            drasi uninstall --force -y 2>/dev/null || true
            sleep 5
        else
            echo "ERROR: Failed to initialize Drasi after $MAX_ATTEMPTS attempts."
            exit 1
        fi
    fi
    
    ATTEMPT=$((ATTEMPT + 1))
done

echo "Setup complete! Applications are available at:"
echo "  Demo (Combined View): http://localhost/"
echo "  Control Panel: http://localhost/control-panel"
echo "  Dashboard: http://localhost/dashboard"
echo ""
echo "API Documentation:"
echo "  Swagger UI: http://localhost/control-panel/docs"
echo "  ReDoc: http://localhost/control-panel/redoc"
echo ""