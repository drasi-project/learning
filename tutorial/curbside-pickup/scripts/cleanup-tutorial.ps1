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

#!/usr/bin/env pwsh
# Curbside Pickup Tutorial Cleanup Script
# This script removes the Curbside Pickup tutorial applications from your Kubernetes cluster

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

# Output functions with color
function Write-Info($message) {
    Write-Host "[*] $message" -ForegroundColor Cyan
}

function Write-Success($message) {
    Write-Host "[+] $message" -ForegroundColor Green
}

function Write-Warning($message) {
    Write-Host "[!] $message" -ForegroundColor Yellow
}

function Write-Error($message) {
    Write-Host "[x] $message" -ForegroundColor Red
}

function Show-Header {
    Write-Host ""
    Write-Host "=== Curbside Pickup Tutorial Cleanup ===" -ForegroundColor Cyan
    Write-Host ""
}

function Remove-TutorialResources {
    Write-Info "Removing Curbside Pickup tutorial resources..."
    
    # Remove ingress and middleware
    Write-Info "Removing ingress routes..."
    kubectl delete ingress delivery-dashboard-ingress delay-dashboard-ingress demo-ingress physical-ops-ingress retail-ops-ingress 2>$null
    kubectl delete middleware delivery-dashboard-stripprefix delay-dashboard-stripprefix physical-ops-stripprefix retail-ops-stripprefix 2>$null
    
    # Remove applications
    Write-Info "Removing applications..."
    kubectl delete deployment delivery-dashboard delay-dashboard demo physical-ops retail-ops 2>$null
    kubectl delete service delivery-dashboard delay-dashboard demo physical-ops retail-ops 2>$null
    
    # Remove databases
    Write-Info "Removing PostgreSQL database..."
    kubectl delete deployment postgres 2>$null
    kubectl delete service postgres 2>$null
    kubectl delete configmap postgres-init-scripts 2>$null
    kubectl delete pvc postgres-pvc 2>$null
    
    Write-Info "Removing MySQL database..."
    kubectl delete deployment mysql 2>$null
    kubectl delete service mysql 2>$null
    kubectl delete configmap mysql-init-scripts 2>$null
    kubectl delete pvc mysql-pvc 2>$null
    
    Write-Success "Tutorial resources removed"
}

# Main execution
Show-Header

$response = Read-Host "This will remove all Curbside Pickup tutorial resources. Continue? (y/n)"

if ($response -ne 'y') {
    Write-Info "Cleanup cancelled"
    exit 0
}

# Set error action to continue for cleanup operations
$ErrorActionPreference = "Continue"

Remove-TutorialResources

Write-Host ""
Write-Success "Curbside Pickup tutorial cleanup complete!"
Write-Host ""