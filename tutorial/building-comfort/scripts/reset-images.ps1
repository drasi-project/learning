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

# Reset images to official versions (Windows PowerShell version)
#Requires -Version 5.1

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("control-panel", "dashboard", "demo", "all")]
    [string]$AppName
)

# Set strict mode for better error handling
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

Write-Host "Resetting images to official versions" -ForegroundColor Cyan
Write-Host ""

# Define the official images
$officialImages = @{
    "control-panel" = "ghcr.io/drasi-project/learning/building-comfort/control-panel:latest"
    "dashboard" = "ghcr.io/drasi-project/learning/building-comfort/dashboard:latest"
    "demo" = "ghcr.io/drasi-project/learning/building-comfort/demo:latest"
}

# Function to reset a single app
function Reset-AppImage {
    param([string]$App)
    
    if (-not $officialImages.ContainsKey($App)) {
        Write-Host "[ERROR] Unknown app: $App" -ForegroundColor Red
        return
    }
    
    $image = $officialImages[$App]
    Write-Host "[INFO] Resetting $App to: $image" -ForegroundColor Yellow
    
    # Update the deployment with the official image
    $patchJson = @{
        spec = @{
            template = @{
                spec = @{
                    containers = @(
                        @{
                            name = $App
                            image = $image
                            imagePullPolicy = "Always"
                        }
                    )
                }
            }
        }
    } | ConvertTo-Json -Depth 10
    
    # Check if deployment exists
    $ErrorActionPreference = 'SilentlyContinue'
    kubectl get deployment $App 2>&1 | Out-Null
    $deploymentExists = $LASTEXITCODE -eq 0
    $ErrorActionPreference = 'Stop'
    
    if (-not $deploymentExists) {
        Write-Host "[ERROR] Deployment '$App' not found" -ForegroundColor Red
        return
    }
    
    kubectl patch deployment $App --type merge -p $patchJson 2>&1 | Out-String | Write-Host
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERROR] Failed to patch deployment $App" -ForegroundColor Red
        return
    }
    Write-Host "[OK] $App reset to official image" -ForegroundColor Green
    
    # Restart to ensure fresh pull
    kubectl rollout restart deployment/$App 2>&1 | Out-String | Write-Host
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERROR] Failed to restart deployment $App" -ForegroundColor Red
        return
    }
}

# Reset based on parameter
if ($AppName -eq "all") {
    Write-Host "Resetting all applications..." -ForegroundColor Yellow
    foreach ($app in $officialImages.Keys) {
        Reset-AppImage -App $app
    }
}
else {
    Reset-AppImage -App $AppName
}

Write-Host ""
Write-Host "Waiting for rollouts to complete..." -ForegroundColor Yellow

# Wait for rollouts
if ($AppName -eq "all") {
    foreach ($app in $officialImages.Keys) {
        kubectl rollout status deployment/$app --timeout=60s 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) {
            Write-Host "[WARNING] $app rollout may still be in progress" -ForegroundColor Yellow
        }
    }
}
else {
    kubectl rollout status deployment/$AppName --timeout=60s 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[WARNING] Rollout may still be in progress" -ForegroundColor Yellow
    }
}

Write-Host ""
Write-Host "Image reset complete!" -ForegroundColor Green
Write-Host "   Applications are now using official images from GitHub Container Registry." -ForegroundColor Gray
Write-Host ""