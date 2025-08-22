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

Write-Host "=========================================" -ForegroundColor Cyan
Write-Host "Dapr + Drasi Tutorial Setup" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

# Define k3d version
$K3D_VERSION = "v5.6.0"

# Check if we're in GitHub Codespaces
if ($env:CODESPACES) {
    Write-Host "Running in GitHub Codespaces environment" -ForegroundColor Green
    $PORT_MAPPING = "80:80@loadbalancer"
    $BASE_URL = "http://localhost"
} else {
    Write-Host "Running in local/DevContainer environment" -ForegroundColor Green
    $PORT_MAPPING = "8123:80@loadbalancer"
    $BASE_URL = "http://localhost:8123"
}

Write-Host "Creating K3d cluster..." -ForegroundColor Yellow
# Delete existing cluster if it exists
k3d cluster delete drasi-tutorial 2>$null
k3d cluster create drasi-tutorial --port $PORT_MAPPING

Write-Host "Waiting for cluster to be ready..." -ForegroundColor Yellow
kubectl wait --for=condition=ready node --all --timeout=60s

Write-Host "Waiting for Traefik to be ready..." -ForegroundColor Yellow
$MAX_JOB_WAIT = 30
$JOB_WAITED = 0
while ($JOB_WAITED -lt $MAX_JOB_WAIT) {
    if (kubectl get job -n kube-system helm-install-traefik 2>$null) {
        Write-Host "Traefik Helm job found, waiting for completion..." -ForegroundColor Yellow
        kubectl wait --for=condition=complete job/helm-install-traefik -n kube-system --timeout=300s
        break
    }
    Write-Host "Waiting for Traefik Helm job to appear..." -ForegroundColor Yellow
    Start-Sleep -Seconds 2
    $JOB_WAITED += 2
}

Write-Host "Initializing Drasi (this will also install Dapr)..." -ForegroundColor Yellow

# Configure Drasi to use kubectl context
Write-Host "Configuring Drasi to use kubectl context..." -ForegroundColor Yellow
drasi env kube 2>$null

$MAX_ATTEMPTS = 3
$ATTEMPT = 1
$DRASI_INITIALIZED = $false

while (($ATTEMPT -le $MAX_ATTEMPTS) -and (-not $DRASI_INITIALIZED)) {
    Write-Host "Drasi initialization attempt $ATTEMPT of $MAX_ATTEMPTS..." -ForegroundColor Yellow
    
    if (drasi init) {
        $DRASI_INITIALIZED = $true
        Write-Host "Drasi initialized successfully!" -ForegroundColor Green
    } else {
        Write-Host "Drasi initialization failed." -ForegroundColor Red
        
        if ($ATTEMPT -lt $MAX_ATTEMPTS) {
            Write-Host "Uninstalling Drasi before retry..." -ForegroundColor Yellow
            drasi uninstall -y 2>$null
            Start-Sleep -Seconds 5
        } else {
            Write-Host "ERROR: Failed to initialize Drasi after $MAX_ATTEMPTS attempts." -ForegroundColor Red
            exit 1
        }
    }
    
    $ATTEMPT++
}

Write-Host "Deploying PostgreSQL databases..." -ForegroundColor Yellow
kubectl apply -f services/products/k8s/postgres/postgres.yaml
kubectl apply -f services/customers/k8s/postgres/postgres.yaml
kubectl apply -f services/orders/k8s/postgres/postgres.yaml
kubectl apply -f services/reviews/k8s/postgres/postgres.yaml
kubectl apply -f services/catalogue/k8s/postgres/postgres.yaml

Write-Host "Waiting for PostgreSQL databases to be ready..." -ForegroundColor Yellow
kubectl wait --for=condition=ready pod -l app=products-db --timeout=120s
kubectl wait --for=condition=ready pod -l app=customers-db --timeout=120s
kubectl wait --for=condition=ready pod -l app=orders-db --timeout=120s
kubectl wait --for=condition=ready pod -l app=reviews-db --timeout=120s
kubectl wait --for=condition=ready pod -l app=catalogue-db --timeout=120s

Write-Host "Deploying Redis for notifications..." -ForegroundColor Yellow
kubectl apply -f services/notifications/k8s/redis/redis.yaml

Write-Host "Waiting for Redis to be ready..." -ForegroundColor Yellow
kubectl wait --for=condition=ready pod -l app=notifications-redis --timeout=120s

Write-Host "Deploying Dapr components..." -ForegroundColor Yellow
kubectl apply -f services/products/k8s/dapr/statestore.yaml
kubectl apply -f services/customers/k8s/dapr/statestore.yaml
kubectl apply -f services/orders/k8s/dapr/statestore.yaml
kubectl apply -f services/reviews/k8s/dapr/statestore.yaml
kubectl apply -f services/catalogue/k8s/dapr/statestore.yaml
kubectl apply -f services/catalogue/k8s/dapr/statestore-drasi.yaml
kubectl apply -f services/notifications/k8s/dapr/pubsub.yaml
kubectl apply -f services/notifications/k8s/dapr/pubsub-drasi.yaml

Write-Host "Deploying applications..." -ForegroundColor Yellow
kubectl apply -f services/products/k8s/deployment.yaml
kubectl apply -f services/customers/k8s/deployment.yaml
kubectl apply -f services/orders/k8s/deployment.yaml
kubectl apply -f services/reviews/k8s/deployment.yaml
kubectl apply -f services/catalogue/k8s/deployment.yaml
kubectl apply -f services/dashboard/k8s/deployment.yaml
kubectl apply -f services/notifications/k8s/deployment.yaml

Write-Host "Deploying SignalR ingress..." -ForegroundColor Yellow
kubectl apply -f services/dashboard/k8s/signalr-ingress.yaml

Write-Host "Waiting for all deployments to be ready..." -ForegroundColor Yellow
kubectl wait --for=condition=available deployment --all --timeout=300s

Write-Host "Waiting for all pods to be ready..." -ForegroundColor Yellow
kubectl wait --for=condition=Ready pod --all --timeout=300s

Write-Host "Loading initial data into services..." -ForegroundColor Yellow
Write-Host "Loading products data..." -ForegroundColor Yellow
bash services/products/setup/load-initial-data.sh "$BASE_URL/products-service"

Write-Host "Loading customers data..." -ForegroundColor Yellow
bash services/customers/setup/load-initial-data.sh "$BASE_URL/customers-service"

Write-Host "Loading orders data..." -ForegroundColor Yellow
bash services/orders/setup/load-initial-data.sh "$BASE_URL/orders-service"

Write-Host "Loading reviews data..." -ForegroundColor Yellow
bash services/reviews/setup/load-initial-data.sh "$BASE_URL/reviews-service"

Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host "Setup Complete!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""
if ($env:CODESPACES) {
    Write-Host "Applications are available at:" -ForegroundColor Cyan
    Write-Host "  Catalog UI: https://<your-codespace>/catalogue-service" -ForegroundColor White
    Write-Host "  Dashboard UI: https://<your-codespace>/dashboard" -ForegroundColor White
    Write-Host "  Notifications UI: https://<your-codespace>/notifications-service" -ForegroundColor White
    Write-Host ""
    Write-Host "  API Endpoints:" -ForegroundColor Cyan
    Write-Host "  Products: https://<your-codespace>/products-service/products" -ForegroundColor White
    Write-Host "  Customers: https://<your-codespace>/customers-service/customers" -ForegroundColor White
    Write-Host "  Orders: https://<your-codespace>/orders-service/orders" -ForegroundColor White
    Write-Host "  Reviews: https://<your-codespace>/reviews-service/reviews" -ForegroundColor White
} else {
    Write-Host "Applications are available at:" -ForegroundColor Cyan
    Write-Host "  Catalog UI: http://localhost:8123/catalogue-service" -ForegroundColor White
    Write-Host "  Dashboard UI: http://localhost:8123/dashboard" -ForegroundColor White
    Write-Host "  Notifications UI: http://localhost:8123/notifications-service" -ForegroundColor White
    Write-Host ""
    Write-Host "  API Endpoints:" -ForegroundColor Cyan
    Write-Host "  Products: http://localhost:8123/products-service/products" -ForegroundColor White
    Write-Host "  Customers: http://localhost:8123/customers-service/customers" -ForegroundColor White
    Write-Host "  Orders: http://localhost:8123/orders-service/orders" -ForegroundColor White
    Write-Host "  Reviews: http://localhost:8123/reviews-service/reviews" -ForegroundColor White
}
Write-Host ""
Write-Host "To deploy Drasi components, run:" -ForegroundColor Yellow
Write-Host "  kubectl apply -f drasi/sources/" -ForegroundColor White
Write-Host "  kubectl apply -f drasi/queries/" -ForegroundColor White
Write-Host "  kubectl apply -f drasi/reactions/" -ForegroundColor White
Write-Host ""
Write-Host "Then explore the demos:" -ForegroundColor Yellow
Write-Host "  cd demo" -ForegroundColor White
Write-Host "  ./demo-catalogue-service.sh" -ForegroundColor White
Write-Host "  ./demo-dashboard-service.sh" -ForegroundColor White
Write-Host "  ./demo-notifications-service.sh" -ForegroundColor White