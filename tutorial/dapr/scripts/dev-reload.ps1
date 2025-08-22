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
Write-Host "Dapr + Drasi Tutorial - Dev Reload" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

Write-Host "This script reloads all deployments to pull the latest images" -ForegroundColor Yellow
Write-Host ""

# Delete and recreate all deployments to force image pull
Write-Host "Reloading Products service..." -ForegroundColor Yellow
kubectl delete deployment products 2>$null
kubectl apply -f services/products/k8s/deployment.yaml

Write-Host "Reloading Customers service..." -ForegroundColor Yellow
kubectl delete deployment customers 2>$null
kubectl apply -f services/customers/k8s/deployment.yaml

Write-Host "Reloading Orders service..." -ForegroundColor Yellow
kubectl delete deployment orders 2>$null
kubectl apply -f services/orders/k8s/deployment.yaml

Write-Host "Reloading Reviews service..." -ForegroundColor Yellow
kubectl delete deployment reviews 2>$null
kubectl apply -f services/reviews/k8s/deployment.yaml

Write-Host "Reloading Catalogue service..." -ForegroundColor Yellow
kubectl delete deployment catalogue 2>$null
kubectl apply -f services/catalogue/k8s/deployment.yaml

Write-Host "Reloading Dashboard service..." -ForegroundColor Yellow
kubectl delete deployment dashboard 2>$null
kubectl apply -f services/dashboard/k8s/deployment.yaml

Write-Host "Reloading Notifications service..." -ForegroundColor Yellow
kubectl delete deployment notifications 2>$null
kubectl apply -f services/notifications/k8s/deployment.yaml

Write-Host "Waiting for all deployments to be ready..." -ForegroundColor Yellow
kubectl wait --for=condition=available deployment --all --timeout=300s

Write-Host "Waiting for all pods to be ready..." -ForegroundColor Yellow
kubectl wait --for=condition=Ready pod --all --timeout=300s

Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host "Dev Reload Complete!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""
Write-Host "All services have been reloaded with the latest images." -ForegroundColor White