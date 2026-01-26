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

# Define k3d version to use across all environments
K3D_VERSION="v5.6.0"

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

# Install k3d if not present
if ! command -v k3d &> /dev/null; then
    echo "k3d not found. Installing k3d ${K3D_VERSION}..."
    curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | TAG=${K3D_VERSION} bash
else
    echo "k3d is already installed: $(k3d version | grep 'k3d version' || echo 'version unknown')"
fi

# Verify k3d is available
if ! command -v k3d &> /dev/null; then
    echo "ERROR: k3d installation failed."
    exit 1
fi

echo "Running setup script..."
# The working directory is already set by workspaceFolder in devcontainer.json
bash scripts/setup-tutorial.sh

# Install evaluation tools if running in tutorial evaluation workflow
source "$(dirname "$0")/../scripts/install-evaluation-tools.sh"

echo ""
echo "Setup complete! Applications are available at:"
echo "  Catalog UI: http://localhost:8123/catalogue-service"
echo "  Dashboard UI: http://localhost:8123/dashboard"
echo "  Notifications UI: http://localhost:8123/notifications-service"
echo ""
echo "To deploy Drasi components:"
echo "  kubectl apply -f drasi/sources/"
echo "  kubectl apply -f drasi/queries/"
echo "  kubectl apply -f drasi/reactions/"
echo ""
echo "Then run the demo scripts:"
echo "  cd demo"
echo "  ./demo-catalogue-service.sh"
echo "  ./demo-dashboard-service.sh"
echo "  ./demo-notifications-service.sh"