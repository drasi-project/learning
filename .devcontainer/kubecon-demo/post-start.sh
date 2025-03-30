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
LOG_DIR="/workspaces/learning/apps/curbside-pickup/logs"
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


# Function to find an available port in a range
find_available_port() {
  local start_port=$1
  local end_port=$2
  local current_port=$start_port
  
  while [ $current_port -le $end_port ]; do
    if check_port $current_port; then
      echo $current_port
      return 0
    fi
    current_port=$((current_port+1))
  done
  
  echo "No available ports found in range $start_port-$end_port" >&2
  return 1
}

# Reusable function to set up services with port discovery
setup_service() {
  local service_name=$1
  local default_port=$2
  local start_port=${3:-8000}
  local end_port=${4:-9000}
  local port_file="$LOG_DIR/${service_name}_port.txt"
  
  # Debug output to stderr (won't be captured by command substitution)
  >&2 echo "Setting up $service_name service..."
  
  # Try to use default port first
  if check_port $default_port; then
    local service_port=$default_port
    >&2 echo "Using default port $service_port for $service_name"
  else
    >&2 echo "Default port $default_port for $service_name is in use, searching for available port..."
    
    # Check if find_available_port exists
    if ! type find_available_port >/dev/null 2>&1; then
      >&2 echo "ERROR: find_available_port function is not defined!"
      return 1
    fi
    
    local service_port=$(find_available_port $start_port $end_port)
    if [ $? -ne 0 ]; then
      >&2 echo "Error: Failed to find available port for $service_name. Exiting."
      return 1
    fi
    >&2 echo "Found available port $service_port for $service_name"
  fi
  
  # Store the port mapping for future reference
  echo $service_port > "$port_file"
  echo "PORT_${service_name^^}=$service_port" >> "$LOG_DIR/service_ports.env"
  
  # Only output the port number to stdout for capture
  echo "$service_port"
  return 0
}

# Initialize service port environment file
echo "# Service Ports" > "$LOG_DIR/service_ports.env"


# Function to check if process is running
check_process_running() {
  local service_name=$1
  local pid=$2
  local log_file=$3
  
  echo "Checking if $service_name process (PID: $pid) is running..."
  if ! ps -p $pid > /dev/null; then
    echo "ERROR: $service_name process died immediately after starting."
    echo "Check the logs for details: $log_file"
    # Display the last few lines of the log for easier debugging
    echo "--- Last 10 lines of log file ---"
    tail -n 10 "$log_file"
    echo "--------------------------------"
    return 1
  fi
  
  echo "$service_name process is running (PID: $pid)"
  return 0
}

# Function to check if service is responding to HTTP requests
check_service_health() {
  local service_name=$1
  local port=$2
  local pid=$3
  local log_file=$4
  local endpoints="${5:-/health,/,/docs}"  # Default endpoints to try
  local max_retries=${6:-20}
  local retry_delay=${7:-2}
  
  local retry_count=0
  local IFS=','
  local endpoint_array=($endpoints)
  
  echo "Waiting for $service_name to become ready on port $port..."
  while [ $retry_count -lt $max_retries ]; do
    # Try each endpoint in the list
    for endpoint in "${endpoint_array[@]}"; do
      if curl -s "http://localhost:$port$endpoint" > /dev/null 2>&1; then
        echo "$service_name is up and responding to HTTP requests on $endpoint!"
        return 0
      fi
    done
    
    retry_count=$((retry_count+1))
    if [ $retry_count -eq $max_retries ]; then
      echo "ERROR: $service_name not responding to HTTP requests after multiple attempts."
      echo "Process is running (PID: $pid), but not accepting connections."
      echo "Check the logs for details: $log_file"
      echo "--- Last 15 lines of log file ---"
      tail -n 15 "$log_file"
      echo "--------------------------------"
      return 1
    fi
    
    echo "Attempt $retry_count/$max_retries: Service not ready yet, retrying in ${retry_delay}s..."
    sleep $retry_delay
  done
}

# Comprehensive service health check function
verify_service_started() {
  local service_name=$1
  local pid=$2
  local port=$3
  local log_file=$4
  local endpoints="${5:-/health,/,/docs}"
  local max_retries=${6:-10}
  local retry_delay=${7:-2}
  local kill_on_failure=${8:-true}
  
  echo "Performing health check for $service_name..."
  
  # Give the service a moment to initialize
  sleep 3
  
  # Check 1: Process is running
  if ! check_process_running "$service_name" "$pid" "$log_file"; then
    # Process already dead, no need to kill it
    return 1
  fi
  
  # Check 2: Service is responding
  if ! check_service_health "$service_name" "$port" "$pid" "$log_file" "$endpoints" "$max_retries" "$retry_delay"; then
    # Process is running but not responding, kill it if requested
    if [ "$kill_on_failure" = true ]; then
      echo "Terminating unresponsive $service_name process (PID: $pid)..."
      kill $pid 2>/dev/null || true
    fi
    return 1
  fi
  
  echo "$service_name started successfully! (PID: $pid, Port: $port)"
  return 0
}

# Function to update frontend .env file with the correct backend URL & PORT
update_frontend_env() {
  local service_name=$1
  local port=$2
  local frontend_dir=$3
  local env_file="$frontend_dir/.env"
  
  echo "Updating $service_name frontend .env file..."
  
  # ERROR if frontend directory doesn't exist
  if [ ! -d "$frontend_dir" ]; then
    echo "ERROR: Frontend directory $frontend_dir not found, unable to do .env update."
    return 1
  fi
  
  # Determine the base URL based on environment
  local base_url
  if [ "$CODESPACES" = "true" ] && [ -n "$CODESPACE_NAME" ]; then
    # Get the codespace name (prefix of CODESPACE_NAME before any dot)
    local codespace_prefix="${CODESPACE_NAME%%.*}"
    base_url="https://${codespace_prefix}-${port}.app.github.dev"
    echo "Using Codespace URL: $base_url"
  else
    base_url="http://localhost:${port}"
    echo "Using localhost URL: $base_url"
  fi
  
  # Create or update the .env file
  if [ -f "$env_file" ]; then
    # Create a temporary file with the updated content
    grep -v "^VITE_API_BASE_URL=" "$env_file" > "$env_file.tmp"
    echo "VITE_API_BASE_URL=${base_url}" >> "$env_file.tmp"
    mv "$env_file.tmp" "$env_file"
    echo "Updated $env_file with API base URL: $base_url"
  else
    # Create new file
    echo "VITE_API_BASE_URL=${base_url}" > "$env_file"
    echo "VITE_PORT=3003" >> "$env_file"
    echo "Created new $env_file with API base URL: $base_url"
  fi
  
  return 0
}

# Function to update index.html iframe URLs for Codespace compatibility
update_dashboard_html() {
  local html_file=$1
  local delivery_port=$2
  local delay_port=$3
  local physical_port=$4
  local retail_port=$5
  
  echo "Updating dashboard HTML URLs in $html_file..."
  
  # Skip if HTML file doesn't exist
  if [ ! -f "$html_file" ]; then
    echo "ERROR: Dashboard HTML file $html_file not found."
    return 1
  fi
  
  # Create a backup of the original file
  cp "$html_file" "${html_file}.bak"
  
  # Determine if we're in a Codespace
  if [ "$CODESPACES" = "true" ] && [ -n "$CODESPACE_NAME" ]; then
    local codespace_prefix=$CODESPACE_NAME
    
    # Replace URLs with Codespace-compatible URLs
    sed -i.tmp \
      -e "s|http://localhost:3001|https://${codespace_prefix}-${delivery_port}.app.github.dev|g" \
      -e "s|http://localhost:3002|https://${codespace_prefix}-${delay_port}.app.github.dev|g" \
      -e "s|http://localhost:3003|https://${codespace_prefix}-${physical_port}.app.github.dev|g" \
      -e "s|http://localhost:3004|https://${codespace_prefix}-${retail_port}.app.github.dev|g" \
      "$html_file"
    
    echo "Updated HTML with Codespace URLs"
  else
    # Just update the ports for localhost URLs if they differ from defaults
    sed -i.tmp \
      -e "s|http://localhost:3001|http://localhost:${delivery_port}|g" \
      -e "s|http://localhost:3002|http://localhost:${delay_port}|g" \
      -e "s|http://localhost:3003|http://localhost:${physical_port}|g" \
      -e "s|http://localhost:3004|http://localhost:${retail_port}|g" \
      "$html_file"
    
    echo "Updated HTML with localhost URLs"
  fi
  
  # Remove temporary file
  rm -f "${html_file}.tmp"
  return 0
}

# Function to make a port public in Codespaces
make_port_public() {
  local port=$1
  local label=$2
  
  if [ "$CODESPACES" = "true" ] && [ -n "$CODESPACE_NAME" ]; then
    echo "Making port $port ($label) public in Codespaces..."
    
    # Check if gh CLI is available
    if command -v gh &>/dev/null; then
      gh codespace ports visibility $port:public -c $CODESPACE_NAME
      echo "Port $port is now public via gh CLI"
    else
      echo "Note: Install GitHub CLI (gh) for automatic port visibility configuration"
    fi
  else
    echo "Port $port ($label) is publicly available."
  fi
}

# Function to update dashboard .env file with the correct SignalR URL
update_dashboard_env() {
  local service_name=$1
  local port=$2
  local dashboard_dir=$3
  local env_file="$dashboard_dir/.env"
  
  echo "Updating $service_name dashboard .env file..."
  
  # ERROR if dashboard directory doesn't exist
  if [ ! -d "$dashboard_dir" ]; then
    echo "ERROR: Dashboard directory $dashboard_dir not found, unable to do .env update."
    return 1
  fi
  
  # Determine the base URL based on environment
  local signalr_url
  if [ "$CODESPACES" = "true" ] && [ -n "$CODESPACE_NAME" ]; then
    signalr_url="https://${CODESPACE_NAME}-${port}.app.github.dev/hub"
    echo "Using Codespace SignalR URL: $signalr_url"
  else
    signalr_url="http://localhost:${port}/hub"
    echo "Using localhost SignalR URL: $signalr_url"
  fi
  
  # Create or update the .env file
  if [ -f "$env_file" ]; then
    # Create a temporary file with the updated content
    grep -v "^VITE_SIGNALR_URL=" "$env_file" > "$env_file.tmp"
    echo "VITE_SIGNALR_URL=${signalr_url}" >> "$env_file.tmp"
    mv "$env_file.tmp" "$env_file"
    echo "Updated $env_file with SignalR URL: $signalr_url"
  else
    # Create new file with copyright notice and required content
    cat > "$env_file" << EOL
# SignalR endpoint URL
VITE_SIGNALR_URL=${signalr_url}

# Query ID for ready-for-delivery orders
VITE_QUERY_ID=delivery

# PORT for hosting this dashboard
VITE_PORT=3001
EOL
    echo "Created new $env_file with SignalR URL: $signalr_url"
  fi
  
  return 0
}

##### Retail Ops Backend #####
echo "Starting retail ops backend..."
RETAIL_OPS_BACKEND_DIR="/workspaces/learning/apps/curbside-pickup/retail-ops/backend"
cd $RETAIL_OPS_BACKEND_DIR || { echo "Error: Directory $RETAIL_OPS_BACKEND_DIR not found."; exit 1; }

echo "Retail Ops Backend: Installing python dependencies..."
python3 -m venv venv && source venv/bin/activate && pip3 install -r requirements.txt

echo "Retail Ops Backend: Configuring port..."
RETAIL_BACKEND_PORT=$(setup_service "retailBackend" 8004)
if [ $? -ne 0 ]; then
  echo "Error setting up Port for Retail Ops Backend. Exiting."
  exit 1
fi

echo "Running nohup command to start FastAPI server..."
nohup uvicorn main:app --reload --host 0.0.0.0 --port $RETAIL_BACKEND_PORT > "$LOG_DIR/retailBackend.log" 2>&1 &
RETAIL_BACKEND_PID=$!

echo "Verifying Retail Ops Backend service..."
if ! verify_service_started "Retail Ops Backend" "$RETAIL_BACKEND_PID" "$RETAIL_BACKEND_PORT" "$LOG_DIR/retailBackend.log"; then
  echo "Failed to start Retail Ops Backend service. Exiting."
  exit 1
fi

##### Physical Ops Backend #####
echo "Starting physical ops backend..."
PHYSICAL_OPS_BACKEND_DIR="/workspaces/learning/apps/curbside-pickup/physical-ops/backend"
cd $PHYSICAL_OPS_BACKEND_DIR || { echo "Error: Directory $PHYSICAL_OPS_BACKEND_DIR not found."; exit 1; }

echo "Physical Ops Backend: Installing python dependencies..."
python3 -m venv venv && source venv/bin/activate && pip3 install -r requirements.txt

echo "Physical Ops Backend: Configuring port..."
PHYSICAL_BACKEND_PORT=$(setup_service "physicalBackend" 8003)
if [ $? -ne 0 ]; then
  echo "Error setting up Port for Physical Ops Backend. Exiting."
  exit 1
fi

echo "Running nohup command to start FastAPI server..."
nohup uvicorn main:app --reload --host 0.0.0.0 --port $PHYSICAL_BACKEND_PORT > "$LOG_DIR/physicalBackend.log" 2>&1 &
PHYSICAL_BACKEND_PID=$!

echo "Verifying Physical Ops Backend service..."
if ! verify_service_started "Physical Ops Backend" "$PHYSICAL_BACKEND_PID" "$PHYSICAL_BACKEND_PORT" "$LOG_DIR/physicalBackend.log"; then
  echo "Failed to start Physical Ops Backend service. Exiting."
  exit 1
fi

##### Retail Ops Frontend #####
RETAIL_FRONTEND_DIR="/workspaces/learning/apps/curbside-pickup/retail-ops/frontend"
update_frontend_env "retailFrontend" "$RETAIL_BACKEND_PORT" "$RETAIL_FRONTEND_DIR"
RETAIL_FRONTEND_PORT=3004

##### Physical Ops Frontend #####
PHYSICAL_FRONTEND_DIR="/workspaces/learning/apps/curbside-pickup/physical-ops/frontend"
update_frontend_env "physicalFrontend" "$PHYSICAL_BACKEND_PORT" "$PHYSICAL_FRONTEND_DIR"
PHYSICAL_FRONTEND_PORT=3003

# Update the main dashboard HTML with all service URLs
echo "Updating main dashboard HTML..."
DASHBOARD_HTML="/workspaces/learning/apps/curbside-pickup/index.html"
DELIVERY_PORT=3001
DELAY_PORT=3002
update_dashboard_html "$DASHBOARD_HTML" "$DELIVERY_PORT" "$DELAY_PORT" "$PHYSICAL_FRONTEND_PORT" "$RETAIL_FRONTEND_PORT"

# Update delivery dashboard
DELIVERY_DASHBOARD_DIR="/workspaces/learning/apps/curbside-pickup/delivery-dashboard"
update_dashboard_env "deliveryDashboard" "8080" "$DELIVERY_DASHBOARD_DIR"

# Update delay dashboard
DELAY_DASHBOARD_DIR="/workspaces/learning/apps/curbside-pickup/delay-dashboard" 
update_dashboard_env "delayDashboard" "8080" "$DELAY_DASHBOARD_DIR"