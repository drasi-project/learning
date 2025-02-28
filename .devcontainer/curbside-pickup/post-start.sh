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
pkill -f "kubectl port-forward svc/mysql" 2>/dev/null || echo "No prior mysql port-forward process found."

# Verify cluster connectivity
echo "Checking cluster connectivity..."
if ! kubectl cluster-info > /dev/null 2>&1; then
  echo "Error: Cannot connect to the cluster. Check k3d setup."
  exit 1
fi

# Verify services exist
echo "Checking for svc/postgres..."
kubectl get svc/postgres || echo "Warning: svc/postgres not found."
echo "Checking for svc/mysql..."
kubectl get svc/mysql || echo "Warning: svc/mysql not found."

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

# Forward MySQL port
if check_port 3306; then
  echo "Starting port-forward for MySQL..."
  nohup kubectl port-forward svc/mysql 3306:3306 > "$LOG_DIR/mysql-port-forward.log" 2>&1 &
  sleep 1  # Give it a moment to start
  if ps aux | grep -q "[k]ubectl port-forward svc/mysql"; then
    echo "MySQL port-forward started (logs at $LOG_DIR/mysql-port-forward.log)."
  else
    echo "Error: MySQL port-forward failed to start. Check $LOG_DIR/mysql-port-forward.log."
  fi
else
  echo "MySQL port-forward skipped due to port conflict."
fi

# Final check
echo "Running processes:"
ps aux | grep "[k]ubectl port-forward" || echo "No kubectl port-forward processes found."