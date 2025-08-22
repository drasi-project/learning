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

echo "========================================="
echo "Dapr + Drasi Tutorial Setup"
echo "========================================="

# Define k3d version to use across all environments
K3D_VERSION="v5.6.0"

# Check if we're in GitHub Codespaces
if [ -n "$CODESPACES" ]; then
    echo "Running in GitHub Codespaces environment"
    PORT_MAPPING="80:80@loadbalancer"
    BASE_URL="http://localhost"
else
    echo "Running in local/DevContainer environment"
    PORT_MAPPING="8123:80@loadbalancer"
    BASE_URL="http://localhost:8123"
fi

echo "Creating K3d cluster..."
# Delete existing cluster if it exists
k3d cluster delete drasi-tutorial 2>/dev/null || true
k3d cluster create drasi-tutorial --port "$PORT_MAPPING"

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
    # Check for both traefik.containo.us and traefik.io CRDs
    if kubectl get crd middlewares.traefik.containo.us >/dev/null 2>&1 && \
       kubectl get crd middlewares.traefik.io >/dev/null 2>&1 && \
       kubectl get crd ingressroutes.traefik.io >/dev/null 2>&1; then
        echo "All Traefik CRDs are ready!"
        break
    fi
    echo "Waiting for Traefik CRDs to be created..."
    sleep 2
    CRD_WAITED=$((CRD_WAITED + 2))
done

if [ $CRD_WAITED -ge $MAX_CRD_WAIT ]; then
    echo "Warning: Traefik CRDs not found after ${MAX_CRD_WAIT}s, continuing anyway..."
fi

echo "Initializing Drasi (this will also install Dapr)..."

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

echo "Deploying PostgreSQL databases..."
kubectl apply -f services/products/k8s/postgres/postgres.yaml
kubectl apply -f services/customers/k8s/postgres/postgres.yaml
kubectl apply -f services/orders/k8s/postgres/postgres.yaml
kubectl apply -f services/reviews/k8s/postgres/postgres.yaml
kubectl apply -f services/catalogue/k8s/postgres/postgres.yaml

echo "Waiting for PostgreSQL databases to be ready..."
kubectl wait --for=condition=ready pod -l app=products-db --timeout=120s
kubectl wait --for=condition=ready pod -l app=customers-db --timeout=120s
kubectl wait --for=condition=ready pod -l app=orders-db --timeout=120s
kubectl wait --for=condition=ready pod -l app=reviews-db --timeout=120s
kubectl wait --for=condition=ready pod -l app=catalogue-db --timeout=120s

echo "Deploying Redis for notifications..."
kubectl apply -f services/notifications/k8s/redis/redis.yaml

echo "Waiting for Redis to be ready..."
kubectl wait --for=condition=ready pod -l app=notifications-redis --timeout=120s

echo "Deploying Dapr components..."
kubectl apply -f services/products/k8s/dapr/statestore.yaml
kubectl apply -f services/customers/k8s/dapr/statestore.yaml
kubectl apply -f services/orders/k8s/dapr/statestore.yaml
kubectl apply -f services/reviews/k8s/dapr/statestore.yaml
kubectl apply -f services/catalogue/k8s/dapr/statestore.yaml
kubectl apply -f services/catalogue/k8s/dapr/statestore-drasi.yaml
kubectl apply -f services/notifications/k8s/dapr/pubsub.yaml
kubectl apply -f services/notifications/k8s/dapr/pubsub-drasi.yaml

echo "Deploying applications..."
kubectl apply -f services/products/k8s/deployment.yaml
kubectl apply -f services/customers/k8s/deployment.yaml
kubectl apply -f services/orders/k8s/deployment.yaml
kubectl apply -f services/reviews/k8s/deployment.yaml
kubectl apply -f services/catalogue/k8s/deployment.yaml
kubectl apply -f services/dashboard/k8s/deployment.yaml
kubectl apply -f services/notifications/k8s/deployment.yaml

echo "Deploying SignalR ingress..."
kubectl apply -f services/dashboard/k8s/signalr-ingress.yaml

echo "Waiting for all deployments to be ready..."
kubectl wait --for=condition=available deployment --all --timeout=300s

echo "Waiting for all pods to be ready..."
kubectl wait --for=condition=Ready pod --all --timeout=300s

echo "Loading initial data into services..."
echo "Loading products data..."
bash services/products/setup/load-initial-data.sh "$BASE_URL/products-service"

echo "Loading customers data..."
bash services/customers/setup/load-initial-data.sh "$BASE_URL/customers-service"

echo "Loading orders data..."
bash services/orders/setup/load-initial-data.sh "$BASE_URL/orders-service"

echo "Loading reviews data..."
bash services/reviews/setup/load-initial-data.sh "$BASE_URL/reviews-service"

echo ""
echo "========================================="
echo "Setup Complete!"
echo "========================================="
echo ""
if [ -n "$CODESPACES" ]; then
    echo "Applications are available at:"
    echo "  Catalog UI: https://<your-codespace>/catalogue-service"
    echo "  Dashboard UI: https://<your-codespace>/dashboard"
    echo "  Notifications UI: https://<your-codespace>/notifications-service"
    echo ""
    echo "  API Endpoints:"
    echo "  Products: https://<your-codespace>/products-service/products"
    echo "  Customers: https://<your-codespace>/customers-service/customers"
    echo "  Orders: https://<your-codespace>/orders-service/orders"
    echo "  Reviews: https://<your-codespace>/reviews-service/reviews"
else
    echo "Applications are available at:"
    echo "  Catalog UI: http://localhost:8123/catalogue-service"
    echo "  Dashboard UI: http://localhost:8123/dashboard"
    echo "  Notifications UI: http://localhost:8123/notifications-service"
    echo ""
    echo "  API Endpoints:"
    echo "  Products: http://localhost:8123/products-service/products"
    echo "  Customers: http://localhost:8123/customers-service/customers"
    echo "  Orders: http://localhost:8123/orders-service/orders"
    echo "  Reviews: http://localhost:8123/reviews-service/reviews"
fi
echo ""
echo "To deploy Drasi components, run:"
echo "  kubectl apply -f drasi/sources/"
echo "  kubectl apply -f drasi/queries/"
echo "  kubectl apply -f drasi/reactions/"
echo ""
echo "Then explore the demos:"
echo "  cd demo"
echo "  ./demo-catalogue-service.sh"
echo "  ./demo-dashboard-service.sh"
echo "  ./demo-notifications-service.sh"