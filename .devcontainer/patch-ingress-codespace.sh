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

# This script watches for the hello-world-debug-reaction ingress resource
# and automatically patches it for GitHub Codespaces compatibility

echo "===== Ingress Patcher Script Started ====="
echo "Timestamp: $(date)"
echo "Working directory: $(pwd)"
echo "CODESPACE_NAME: $CODESPACE_NAME"

# Only run in GitHub Codespaces
if [ -z "$CODESPACE_NAME" ]; then
  echo "Not running in GitHub Codespace, skipping ingress patch."
  exit 0
fi

INGRESS_NAME="hello-world-debug-reaction-ingress"
NAMESPACE="drasi-system"
PATCH_FILE="./resources/ingress-codespace-patch.yaml"
MAX_WAIT=1200
INTERVAL=5    # Check every 5 seconds

echo "GitHub Codespace detected. Watching for ingress resource: $INGRESS_NAME in namespace: $NAMESPACE"
echo "Patch file: $PATCH_FILE"
echo "Checking if patch file exists..."
if [ ! -f "$PATCH_FILE" ]; then
  echo "ERROR: Patch file not found at: $PATCH_FILE"
  echo "Current directory: $(pwd)"
  echo "Listing files in resources/:"
  ls -la ./resources/ 2>&1 || echo "resources/ directory not found"
  exit 1
fi
echo "Patch file found. Starting watch loop..."

elapsed=0
while [ $elapsed -lt $MAX_WAIT ]; do
  echo "[${elapsed}s] Checking for ingress $INGRESS_NAME in namespace $NAMESPACE..."

  # Check if the ingress exists
  if kubectl get ingress "$INGRESS_NAME" -n "$NAMESPACE" &> /dev/null; then
    echo "Ingress $INGRESS_NAME found in namespace $NAMESPACE. Applying Codespace patch..."
    echo "Patch command: kubectl patch ingress $INGRESS_NAME -n $NAMESPACE --type=json --patch-file=$PATCH_FILE"

    # Apply the patch with verbose output
    if kubectl patch ingress "$INGRESS_NAME" -n "$NAMESPACE" --type=json --patch-file="$PATCH_FILE" 2>&1; then
      echo "Successfully patched ingress $INGRESS_NAME for GitHub Codespaces."
      echo "Verification - Current ingress state:"
      kubectl get ingress "$INGRESS_NAME" -n "$NAMESPACE" -o yaml
      exit 0
    else
      echo "Error: Failed to patch ingress. Exit code: $?"
      echo "Please run manually:"
      echo "  kubectl patch ingress $INGRESS_NAME -n $NAMESPACE --type=json --patch-file=$PATCH_FILE"
      exit 1
    fi
  fi

  sleep $INTERVAL
  elapsed=$((elapsed + INTERVAL))
done

echo "Timeout: Ingress $INGRESS_NAME was not created within ${MAX_WAIT}s."
echo "If you need to patch it manually later, run:"
echo "  kubectl patch ingress $INGRESS_NAME -n $NAMESPACE --type=json --patch-file=$PATCH_FILE"
exit 0
