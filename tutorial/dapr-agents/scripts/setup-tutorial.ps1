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
Write-Host "Dapr Agents + Drasi Tutorial Setup" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

# Define k3d version
$K3D_VERSION = "v5.6.0"

function Install-With-Retries {
    param(
        [string]$ToolName,
        [scriptblock]$InstallScript,
        [scriptblock]$UninstallScript,
        [int]$MaxAttempts
    )
    
    $attempt = 1
    
    while ($attempt -le $MaxAttempts) {
        Write-Host "$ToolName installation attempt $attempt of $MaxAttempts..." -ForegroundColor Yellow
        
        if (& $InstallScript) {
            Write-Host "$ToolName initialized successfully!" -ForegroundColor Green
            return $true
        }
        
        Write-Host "$ToolName installation failed." -ForegroundColor Red
        
        if ($attempt -lt $MaxAttempts) {
            Write-Host "Uninstalling $ToolName before retry..." -ForegroundColor Yellow
            & $UninstallScript 2>$null
            Start-Sleep -Seconds 5
        } else {
            Write-Host "ERROR: Failed to initialize $ToolName after $MaxAttempts attempts." -ForegroundColor Red
            return $false
        }
        
        $attempt++
    }
}

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
# Wait for Traefik Helm job to complete
Write-Host "Waiting for Traefik Helm installation..." -ForegroundColor Yellow
$MAX_JOB_WAIT = 30
$JOB_WAITED = 0
while ($JOB_WAITED -lt $MAX_JOB_WAIT) {
    if (kubectl get job -n kube-system helm-install-traefik 2>$null) {
        Write-Host "Traefik Helm job found, waiting for completion..." -ForegroundColor Yellow
        kubectl wait --for=condition=complete job/helm-install-traefik -n kube-system --timeout=300s | Out-Null
        break
    }
    Write-Host "Waiting for Traefik Helm job to appear..." -ForegroundColor Yellow
    Start-Sleep -Seconds 2
    $JOB_WAITED += 2
}

if ($JOB_WAITED -ge $MAX_JOB_WAIT) {
    Write-Host "Warning: Traefik Helm job not found after $($MAX_JOB_WAIT)s, continuing anyway..." -ForegroundColor Yellow
}

# Wait for Traefik CRDs to be available
Write-Host "Waiting for Traefik CRDs..." -ForegroundColor Yellow
$MAX_CRD_WAIT = 60
$CRD_WAITED = 0
while ($CRD_WAITED -lt $MAX_CRD_WAIT) {
    # Check for both traefik.containo.us and traefik.io CRDs
    $crd1 = kubectl get crd middlewares.traefik.containo.us 2>$null
    $crd2 = kubectl get crd middlewares.traefik.io 2>$null
    $crd3 = kubectl get crd ingressroutes.traefik.io 2>$null
    
    if ($crd1 -and $crd2 -and $crd3) {
        Write-Host "All Traefik CRDs are ready!" -ForegroundColor Green
        break
    }
    Write-Host "Waiting for Traefik CRDs to be created..." -ForegroundColor Yellow
    Start-Sleep -Seconds 2
    $CRD_WAITED += 2
}

if ($CRD_WAITED -ge $MAX_CRD_WAIT) {
    Write-Host "Warning: Traefik CRDs not found after $($MAX_CRD_WAIT)s, continuing anyway..." -ForegroundColor Yellow
}

Write-Host "Initializing Dapr..." -ForegroundColor Yellow

# Dapr should use the current kubectl context automatically
$dapr_success = Install-With-Retries -ToolName "Dapr" `
    -InstallScript { dapr init -k --wait } `
    -UninstallScript { dapr uninstall -k -y 2>$null } `
    -MaxAttempts 3

if (-not $dapr_success) {
    exit 1
}

Write-Host "Initializing Drasi (this will also install Dapr if not installed already)..." -ForegroundColor Yellow

# Configure Drasi to use kubectl context
Write-Host "Configuring Drasi to use kubectl context..." -ForegroundColor Yellow
if (drasi env kube 2>$null) {
    Write-Host "Drasi configured to use kubectl context" -ForegroundColor Green
} else {
    Write-Host "WARNING: Failed to configure Drasi environment with 'drasi env kube'" -ForegroundColor Yellow
    Write-Host "Continuing with initialization anyway..." -ForegroundColor Yellow
}

$drasi_success = Install-With-Retries -ToolName "Drasi" `
    -InstallScript { drasi init } `
    -UninstallScript { drasi uninstall -y 2>$null } `
    -MaxAttempts 3

if (-not $drasi_success) {
    exit 1
}

Write-Host "Creating secrets..." -ForegroundColor Yellow

$openaiApiKey = $env:OPENAI_API_KEY
if ([string]::IsNullOrEmpty($openaiApiKey)) {
    Write-Host "ERROR: OPENAI_API_KEY environment variable not set" -ForegroundColor Red
    Write-Host "Please set it before running this script:" -ForegroundColor Red
    Write-Host "  `$env:OPENAI_API_KEY = 'your-api-key'" -ForegroundColor Red
    exit 1
}

# OPENAI_ENDPOINT defaults to standard OpenAI endpoint
$openaiEndpoint = $env:OPENAI_ENDPOINT
if ([string]::IsNullOrEmpty($openaiEndpoint)) {
    Write-Host "INFO: OPENAI_ENDPOINT not set, using default OpenAI endpoint: https://api.openai.com/v1" -ForegroundColor Green
    $openaiEndpoint = "https://api.openai.com/v1"
}

# Determine if using Azure or regular OpenAI for optional config
if ($openaiEndpoint -like "*azure*") {
    Write-Host "INFO: Azure OpenAI endpoint detected, using Azure defaults" -ForegroundColor Green
    
    $model = if ([string]::IsNullOrEmpty($env:OPENAI_MODEL)) { "gpt-4.1-nano" } else { $env:OPENAI_MODEL }
    $apiType = if ([string]::IsNullOrEmpty($env:OPENAI_API_TYPE)) { "azure" } else { $env:OPENAI_API_TYPE }
    $apiVersion = if ([string]::IsNullOrEmpty($env:OPENAI_API_VERSION)) { "2025-01-01-preview" } else { $env:OPENAI_API_VERSION }
} else {
    Write-Host "INFO: OpenAI endpoint detected, using OpenAI defaults" -ForegroundColor Green
    
    $model = if ([string]::IsNullOrEmpty($env:OPENAI_MODEL)) { "gpt-4-turbo" } else { $env:OPENAI_MODEL }
    $apiType = if ([string]::IsNullOrEmpty($env:OPENAI_API_TYPE)) { "openai" } else { $env:OPENAI_API_TYPE }
    $apiVersion = if ([string]::IsNullOrEmpty($env:OPENAI_API_VERSION)) { "2024-02-15" } else { $env:OPENAI_API_VERSION }
}

kubectl create secret generic openai-secret `
  --from-literal=api-key="$openaiApiKey" `
  --from-literal=endpoint="$openaiEndpoint" `
  --from-literal=model="$model" `
  --from-literal=apiType="$apiType" `
  --from-literal=apiVersion="$apiVersion" `
  --dry-run=client -o yaml | kubectl apply -f -

# Ensure secrets are created
Start-Sleep -Seconds 2

# Build services and load images into k3d
# TODO: make this optional
Write-Host "Building images..." -ForegroundColor Yellow
docker build -t ghcr.io/drasi-project/learning/dapr-agents/products-service:latest -f services/products/Dockerfile services/products
docker build -t ghcr.io/drasi-project/learning/dapr-agents/orders-service:latest -f services/orders/Dockerfile services/orders
docker build -t ghcr.io/drasi-project/learning/dapr-agents/notifications-service:latest -f services/notifications/Dockerfile services/notifications
docker build -t ghcr.io/drasi-project/learning/dapr-agents/workflow-service:latest -f services/workflow/Dockerfile services/workflow

Write-Host "Loading images into k3d cluster..." -ForegroundColor Yellow
k3d image import ghcr.io/drasi-project/learning/dapr-agents/products-service:latest -c drasi-tutorial
k3d image import ghcr.io/drasi-project/learning/dapr-agents/orders-service:latest -c drasi-tutorial
k3d image import ghcr.io/drasi-project/learning/dapr-agents/notifications-service:latest -c drasi-tutorial
k3d image import ghcr.io/drasi-project/learning/dapr-agents/workflow-service:latest -c drasi-tutorial

Write-Host "Deploying PostgreSQL databases..." -ForegroundColor Yellow
kubectl apply -f services/products/k8s/postgres/postgres.yaml
kubectl apply -f services/orders/k8s/postgres/postgres.yaml

Write-Host "Waiting for PostgreSQL databases to be ready..." -ForegroundColor Yellow
kubectl wait --for=condition=ready pod -l app=products-db --timeout=120s
kubectl wait --for=condition=ready pod -l app=orders-db --timeout=120s

Write-Host "Deploying Redis for workflow..." -ForegroundColor Yellow
kubectl apply -f services/workflow/k8s/redis/redis.yaml

Write-Host "Waiting for workflow Redis to be ready..." -ForegroundColor Yellow
kubectl wait --for=condition=ready pod -l app=workflow-redis --timeout=120s

Write-Host "Deploying Redis for notifications..." -ForegroundColor Yellow
kubectl apply -f services/notifications/k8s/redis/redis.yaml

Write-Host "Waiting for notifications Redis to be ready..." -ForegroundColor Yellow
kubectl wait --for=condition=ready pod -l app=notifications-redis --timeout=120s

Write-Host "Deploying Dapr components..." -ForegroundColor Yellow
kubectl apply -f services/products/k8s/dapr/statestore.yaml
kubectl apply -f services/orders/k8s/dapr/statestore.yaml
kubectl apply -f services/workflow/k8s/dapr/memory.yaml
kubectl apply -f services/workflow/k8s/dapr/openai.yaml
kubectl apply -f services/workflow/k8s/dapr/pubsub.yaml
kubectl apply -f services/workflow/k8s/dapr/registry.yaml
kubectl apply -f services/workflow/k8s/dapr/state.yaml
kubectl apply -f services/notifications/k8s/dapr/pubsub-drasi.yaml

Write-Host "Deploying applications..." -ForegroundColor Yellow
kubectl apply -f services/products/k8s/deployment.yaml
kubectl apply -f services/orders/k8s/deployment.yaml
kubectl apply -f services/notifications/k8s/deployment.yaml
kubectl apply -f services/workflow/k8s/deployment.yaml
kubectl apply -f services/workflow-dashboard/k8s/deployment.yaml

Write-Host "Waiting for all deployments to be ready..." -ForegroundColor Yellow
kubectl wait --for=condition=available deployment --all --timeout=300s

Write-Host "Waiting for all pods to be ready..." -ForegroundColor Yellow
kubectl wait --for=condition=Ready pod --all --timeout=300s

Write-Host "Loading initial data into services..." -ForegroundColor Yellow
Write-Host "Loading products data..." -ForegroundColor Yellow
bash services/products/setup/load-initial-data.sh "$BASE_URL/products-service"

Write-Host "Loading orders data..." -ForegroundColor Yellow
bash services/orders/setup/load-initial-data.sh "$BASE_URL/orders-service"

Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host "Setup Complete!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""
if ($env:CODESPACES) {
    Write-Host "Applications are available at:" -ForegroundColor Cyan
    Write-Host "  Notifications Service: https://<your-codespace>/notifications-service" -ForegroundColor White
    Write-Host "  Workflow Dashboard: https://<your-codespace>/" -ForegroundColor White
    Write-Host ""
    Write-Host "  API Endpoints:" -ForegroundColor Cyan
    Write-Host "  Products: https://<your-codespace>/products-service/products" -ForegroundColor White
    Write-Host "  Orders: https://<your-codespace>/orders-service/orders" -ForegroundColor White
} else {
    Write-Host "Applications are available at:" -ForegroundColor Cyan
    Write-Host "  Notifications Service: http://localhost:8123/notifications-service" -ForegroundColor White
    Write-Host "  Workflow Dashboard: http://localhost:8123/" -ForegroundColor White
    Write-Host ""
    Write-Host "  API Endpoints:" -ForegroundColor Cyan
    Write-Host "  Products: http://localhost:8123/products-service/products" -ForegroundColor White
    Write-Host "  Orders: http://localhost:8123/orders-service/orders" -ForegroundColor White
}
Write-Host ""
Write-Host "To deploy Drasi components, run:" -ForegroundColor Yellow
Write-Host "  drasi apply -f drasi/sources/*" -ForegroundColor White
Write-Host "  drasi apply -f drasi/queries/*" -ForegroundColor White
Write-Host "  drasi apply -f drasi/reactions/*" -ForegroundColor White
Write-Host ""
Write-Host "Then explore the demos:" -ForegroundColor Yellow
Write-Host "  cd demo" -ForegroundColor White
Write-Host "  ./demo-workflow-service.sh" -ForegroundColor White