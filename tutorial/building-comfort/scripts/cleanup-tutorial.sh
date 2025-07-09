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

#!/bin/bash
# Building Comfort Tutorial Cleanup Script
# This script removes the Building Comfort tutorial applications from your Kubernetes cluster

set -euo pipefail

# Get script and tutorial directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TUTORIAL_DIR="$(dirname "$SCRIPT_DIR")"

# Colors for output
INFO='\033[0;36m'      # Cyan
SUCCESS='\033[0;32m'   # Green
WARNING='\033[0;33m'   # Yellow
ERROR='\033[0;31m'     # Red
NC='\033[0m'           # No Color

print_info() {
    printf "${INFO}[*] %s${NC}\n" "$1"
}

print_success() {
    printf "${SUCCESS}[+] %s${NC}\n" "$1"
}

print_warning() {
    printf "${WARNING}[!] %s${NC}\n" "$1"
}

print_error() {
    printf "${ERROR}[x] %s${NC}\n" "$1"
}

show_header() {
    echo
    printf "${INFO}=== Building Comfort Tutorial Cleanup ===${NC}\n"
    echo
}

remove_tutorial_resources() {
    print_info "Removing Building Comfort tutorial resources..."
    
    # Remove ingress and middleware
    print_info "Removing ingress routes..."
    kubectl delete ingress dashboard-ingress demo-ingress control-panel-ingress 2>/dev/null || true
    kubectl delete middleware dashboard-stripprefix control-panel-stripprefix 2>/dev/null || true
    
    # Remove applications
    print_info "Removing applications..."
    kubectl delete deployment dashboard demo control-panel 2>/dev/null || true
    kubectl delete service dashboard demo control-panel 2>/dev/null || true
    
    # Remove database
    print_info "Removing PostgreSQL database..."
    kubectl delete deployment postgres 2>/dev/null || true
    kubectl delete service postgres 2>/dev/null || true
    kubectl delete configmap postgres-init-scripts 2>/dev/null || true
    kubectl delete pvc postgres-pvc 2>/dev/null || true
    
    print_success "Tutorial resources removed"
}

# Main execution
show_header

echo -n "This will remove all Building Comfort tutorial resources. Continue? (y/n): "
read -r response

if [[ "$response" != "y" ]]; then
    print_info "Cleanup cancelled"
    exit 0
fi

remove_tutorial_resources

echo
print_success "Building Comfort tutorial cleanup complete!"
echo