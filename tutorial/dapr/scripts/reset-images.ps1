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
Write-Host "Dapr + Drasi Tutorial - Reset Images" -ForegroundColor Cyan
Write-Host "=========================================" -ForegroundColor Cyan

Write-Host "This script forces a fresh pull of all Docker images" -ForegroundColor Yellow
Write-Host ""

# Get all pods and delete them to force image repull
Write-Host "Deleting all pods to force fresh image pulls..." -ForegroundColor Yellow

kubectl delete pod -l app=products --force --grace-period=0 2>$null
kubectl delete pod -l app=customers --force --grace-period=0 2>$null
kubectl delete pod -l app=orders --force --grace-period=0 2>$null
kubectl delete pod -l app=reviews --force --grace-period=0 2>$null
kubectl delete pod -l app=catalogue --force --grace-period=0 2>$null
kubectl delete pod -l app=dashboard --force --grace-period=0 2>$null
kubectl delete pod -l app=notifications --force --grace-period=0 2>$null

Write-Host "Waiting for deployments to recreate pods..." -ForegroundColor Yellow
Start-Sleep -Seconds 10

Write-Host "Waiting for all pods to be ready..." -ForegroundColor Yellow
kubectl wait --for=condition=Ready pod --all --timeout=300s

Write-Host ""
Write-Host "=========================================" -ForegroundColor Green
Write-Host "Image Reset Complete!" -ForegroundColor Green
Write-Host "=========================================" -ForegroundColor Green
Write-Host ""
Write-Host "All pods have been recreated with fresh image pulls." -ForegroundColor White