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

# Function to check if a port is already in use
check_port() {
  local port=$1
  if lsof -i :"$port" > /dev/null 2>&1; then
    echo "Port $port is already in use. Skipping port-forward."
    return 1
  fi
  return 0
}

# Set a known log directory
LOG_DIR="/tmp"
mkdir -p "$LOG_DIR" || echo "Warning: Could not create $LOG_DIR"

# Clean up any existing port-forward processes
pkill -f "kubectl port-forward svc/postgres" 2>/dev/null || echo "No prior postgres port-forward process found."

# Verify cluster connectivity
echo "Checking cluster connectivity..."
if ! kubectl cluster-info > /dev/null 2>&1; then
  echo "Error: Cannot connect to the cluster. Check k3d setup."
  exit 1
fi

# Verify services exist
echo "Checking for svc/postgres..."
kubectl get svc/postgres || echo "Warning: svc/postgres not found."

# Forward PostgreSQL port
if check_port 5432; then
  echo "Starting port-forward for PostgreSQL..."
  nohup kubectl port-forward svc/postgres 5432:5432 > "$LOG_DIR/postgres-port-forward.log" 2>&1 &
  sleep 1  # Give it a moment to start
  if ps aux | grep -q "[k]ubectl port-forward svc/postgres"; then
    echo "PostgreSQL port-forward started (logs at $LOG_DIR/postgres-port-forward.log)."
  else
    echo "Error: PostgreSQL port-forward failed to start. Check $LOG_DIR/postgres-port-forward.log."
  fi
else
  echo "PostgreSQL port-forward skipped due to port conflict."
fi

# Check for Traefik service
echo "Checking for Traefik in kube-system namespace..."
kubectl get svc -n kube-system -l app.kubernetes.io/name=traefik || echo "Warning: Traefik service not found in kube-system namespace."

# Forward Traefik port (for ingress access)
if check_port 8080; then
  echo "Starting port-forward for Traefik..."
  nohup kubectl port-forward -n kube-system svc/traefik 8080:80 > "$LOG_DIR/traefik-port-forward.log" 2>&1 &
  sleep 1  # Give it a moment to start
  if ps aux | grep -q "[k]ubectl port-forward -n kube-system svc/traefik"; then
    echo "Traefik port-forward started (logs at $LOG_DIR/traefik-port-forward.log)."
  else
    echo "Error: Traefik port-forward failed to start. Check $LOG_DIR/traefik-port-forward.log."
  fi
else
  echo "Traefik port-forward skipped due to port conflict."
fi

# Auto-patch ingress for GitHub Codespaces
if [ -n "$CODESPACE_NAME" ]; then
  echo "GitHub Codespace detected. Starting ingress watcher..."
  nohup bash -c '
    INGRESS_NAME="hello-world-debug-reaction-ingress"
    NAMESPACE="drasi-system"
    PATCH_FILE="./resources/ingress-codespace-patch.yaml"
    MAX_WAIT=1200
    INTERVAL=5

    echo "===== Ingress Patcher Started ====="
    echo "Watching for: $INGRESS_NAME in namespace $NAMESPACE"
    echo "Patch file: $PATCH_FILE"

    elapsed=0
    while [ $elapsed -lt $MAX_WAIT ]; do
      if kubectl get ingress "$INGRESS_NAME" -n "$NAMESPACE" &> /dev/null; then
        echo "Ingress found. Applying Codespace patch..."
        if kubectl patch ingress "$INGRESS_NAME" -n "$NAMESPACE" --type=json --patch-file="$PATCH_FILE" 2>&1; then
          echo "Successfully patched ingress for GitHub Codespaces at $(date)"
        else
          echo "Error: Failed to patch. Run manually: kubectl patch ingress $INGRESS_NAME -n $NAMESPACE --type=json --patch-file=$PATCH_FILE"
          exit 1
        fi
      fi
      sleep $INTERVAL
      elapsed=$((elapsed + INTERVAL))
    done
    echo "Timeout: Ingress not found within ${MAX_WAIT}s"
  ' > "$LOG_DIR/ingress-patch.log" 2>&1 &
  echo "Ingress watcher started (logs at $LOG_DIR/ingress-patch.log)."
fi


# Final check
echo "Running processes:"
ps aux | grep "[k]ubectl port-forward" || echo "No kubectl port-forward processes found."
