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

# Dev reload script for local development (Windows PowerShell version)
#Requires -Version 5.1

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("retail-ops", "physical-ops", "delivery-dashboard", "delay-dashboard", "demo")]
    [string]$AppName
)

# Set strict mode for better error handling
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Get the directory where this script is located
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$TutorialDir = Split-Path -Parent $ScriptDir

Write-Host "Dev Reload: $AppName" -ForegroundColor Cyan
Write-Host ""

# Check if Docker is available
if (-not (Get-Command "docker" -ErrorAction SilentlyContinue)) {
    Write-Host "[ERROR] Docker is not installed or not in PATH" -ForegroundColor Red
    exit 1
}

# Check if k3d is available
if (-not (Get-Command "k3d" -ErrorAction SilentlyContinue)) {
    Write-Host "[ERROR] k3d is not installed or not in PATH" -ForegroundColor Red
    exit 1
}

# Build the Docker image
Write-Host "Building Docker image..." -ForegroundColor Yellow
$imageName = "curbside-pickup/$AppName-dev:latest"

try {
    docker build -t $imageName (Join-Path $TutorialDir $AppName)
    Write-Host "[OK] Docker image built successfully" -ForegroundColor Green
}
catch {
    Write-Host "[ERROR] Failed to build Docker image: $_" -ForegroundColor Red
    exit 1
}

# Import image into k3d cluster
Write-Host "Importing image into k3d cluster..." -ForegroundColor Yellow

# Get the current kubectl context
$currentContext = kubectl config current-context
if ($currentContext -match "k3d-(.+)") {
    $clusterName = $matches[1]
    Write-Host "   Using k3d cluster: $clusterName" -ForegroundColor Gray
}
else {
    Write-Host "[WARN] Current context doesn't appear to be a k3d cluster: $currentContext" -ForegroundColor Yellow
    $clusterName = Read-Host "Enter k3d cluster name (or press Enter for 'drasi-tutorial')"
    if ([string]::IsNullOrWhiteSpace($clusterName)) {
        $clusterName = "drasi-tutorial"
    }
}

try {
    k3d image import $imageName -c $clusterName
    Write-Host "[OK] Image imported successfully" -ForegroundColor Green
}
catch {
    Write-Host "[ERROR] Failed to import image: $_" -ForegroundColor Red
    exit 1
}

# Update the deployment to use the custom image
Write-Host "Updating deployment..." -ForegroundColor Yellow

# Update the deployment with the new image
$patchJson = @{
    spec = @{
        template = @{
            spec = @{
                containers = @(
                    @{
                        name = $AppName
                        image = $imageName
                        imagePullPolicy = "Never"
                    }
                )
            }
        }
    }
} | ConvertTo-Json -Depth 10

kubectl patch deployment $AppName --type merge -p $patchJson 2>&1 | Out-String | Write-Host
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Failed to update deployment - deployment '$AppName' may not exist" -ForegroundColor Red
    Write-Host "Please ensure the tutorial is set up by running: .\setup-tutorial.ps1" -ForegroundColor Yellow
    exit 1
}
Write-Host "[OK] Deployment updated" -ForegroundColor Green

# Restart the deployment to ensure fresh container
Write-Host "Restarting deployment..." -ForegroundColor Yellow
kubectl rollout restart deployment/$AppName 2>&1 | Out-String | Write-Host
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] Failed to restart deployment" -ForegroundColor Red
    exit 1
}

kubectl rollout status deployment/$AppName --timeout=60s 2>&1 | Out-String | Write-Host
if ($LASTEXITCODE -ne 0) {
    Write-Host "[WARN] Deployment restart may still be in progress" -ForegroundColor Yellow
}
else {
    Write-Host "[OK] Deployment restarted successfully" -ForegroundColor Green
}

Write-Host ""
Write-Host "Dev reload complete!" -ForegroundColor Green
Write-Host "   Your local changes are now running in the cluster." -ForegroundColor Gray
Write-Host ""
Write-Host "Tips:" -ForegroundColor Yellow
Write-Host "   - Changes to the code require rebuilding with this script" -ForegroundColor Gray
Write-Host "   - To revert to the official image, run: .\reset-images.ps1 $AppName" -ForegroundColor Gray
Write-Host ""