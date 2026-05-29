#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# Base URL for services
BASE_URL="http://localhost:8123"
WORKFLOW_POD_NAME=""

# Helper function to print headers
print_header() {
    echo
    echo -e "${CYAN}${BOLD}===================================================${NC}"
    echo -e "${CYAN}${BOLD}$1${NC}"
    echo -e "${CYAN}${BOLD}===================================================${NC}"
    echo
}

# Helper function to show command
show_command() {
    echo -e "${GREEN}Running command:${NC}"
    echo -e "${BOLD}$1${NC}"
    echo
}

# Helper function to execute curl with retries
execute_with_retry() {
    local cmd="$1"
    local max_retries=3
    local retry_delay=2
    
    for i in $(seq 1 $max_retries); do
        output=$(eval "$cmd" 2>&1)
        exit_code=$?
        
        if [ $exit_code -eq 0 ] && ! echo "$output" | grep -q "Connection refused\|ECONNREFUSED"; then
            echo "$output"
            return 0
        fi
        
        if [ $i -lt $max_retries ]; then
            sleep $retry_delay
        fi
    done
    
    return 1
}

# Helper function to wait for user to continue
wait_for_continue() {
    local prompt="${1:-Press Enter to continue...}"
    echo -e "${YELLOW}${prompt}${NC}"
    read -p "> " response
}

# Helper to get workflow pod name
get_workflow_pod() {
    WORKFLOW_POD_NAME=$(kubectl get pods -l app=workflow -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)
    if [ -z "$WORKFLOW_POD_NAME" ]; then
        echo -e "${RED}Error: Could not find workflow pod. Is it running?${NC}"
        echo "Run 'kubectl get pods' to check pod status"
        exit 1
    fi
}

# Helper to check workflow logs
show_workflow_logs() {
    local workflow_id="$1"
    echo
    echo -e "${CYAN}Workflow Execution Logs:${NC}"
    kubectl logs "$WORKFLOW_POD_NAME" --tail=50 | grep -E "$workflow_id|LowStockEvent|CriticalStockEvent|OpenAI|Activity" || echo "No recent workflow logs found"
}

# Start of demo
clear
print_header "Workflow Service Demo - Stock Event Orchestration"

echo -e "${GREEN}This demo showcases Dapr Workflow capabilities with Drasi events:${NC}"
echo
echo -e "${CYAN}${BOLD}Demonstrations:${NC}"
echo -e "${GREEN}1. Low Stock Workflow: Reorders stock when below threshold${NC}"
echo -e "${GREEN}2. Critical Stock Workflow: Sends alerts when critically low${NC}"
echo -e "${GREEN}3. Workflow Monitoring: View workflow execution in real-time${NC}"
echo
echo -e "${YELLOW}${BOLD}Workflow Dashboard URL: ${BASE_URL}${NC}"
echo -e "${YELLOW}You can open the workflow dashboard to monitor execution!${NC}"
echo

wait_for_continue "Press Enter to begin the workflow demo..."

# Get workflow pod for logging
get_workflow_pod
echo -e "${GREEN}Found workflow pod: ${WORKFLOW_POD_NAME}${NC}"
echo

# Generate test data
PRODUCT_ID=$((RANDOM % 9000 + 1000))
PRODUCT_NAME="Demo Product ${PRODUCT_ID}"
LOW_THRESHOLD=25

echo -e "${BLUE}Generated IDs for this demo:${NC}"
echo -e "${BLUE}• Product ID: ${PRODUCT_ID}${NC}"
echo -e "${BLUE}• Product Name: ${PRODUCT_NAME}${NC}"
echo -e "${BLUE}• Low Stock Threshold: ${LOW_THRESHOLD} units${NC}"
echo -e "${BLUE}• Critical Stock: 0 units (out of stock)${NC}"
echo

print_header "Scenario 1: LOW STOCK WORKFLOW"

echo -e "${CYAN}Creating a product with LOW stock level (triggers reorder workflow)...${NC}"
echo

# Create product with low stock
LOW_STOCK_EVENT=$(cat <<EOF
{
  "productId": ${PRODUCT_ID},
  "productName": "${PRODUCT_NAME}",
  "productDescription": "Test product for low stock workflow",
  "stockOnHand": 15,
  "lowStockThreshold": ${LOW_THRESHOLD}
}
EOF
)

echo -e "${GREEN}Low Stock Event Payload:${NC}"
echo "$LOW_STOCK_EVENT" | jq '.'
echo

echo -e "${CYAN}Posting product to Products Service...${NC}"
show_command "curl -X POST ${BASE_URL}/products-service/products \\\n  -H 'Content-Type: application/json' \\\n  -d '...'"

TEMP_FILE=$(mktemp)
echo "$LOW_STOCK_EVENT" > "$TEMP_FILE"
RESPONSE=$(execute_with_retry "curl -s -X POST ${BASE_URL}/products-service/products -H 'Content-Type: application/json' -d @${TEMP_FILE}")
rm -f "$TEMP_FILE"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Product Service Response:${NC}"
    echo "$RESPONSE" | jq '.' 2>/dev/null || echo "$RESPONSE"
else
    echo -e "${RED}Failed to post product to products service${NC}"
fi

echo
wait_for_continue "Press Enter to proceed to Critical Stock scenario..."
echo

print_header "Scenario 2: CRITICAL STOCK WORKFLOW"

echo -e "${CYAN}Creating a product with OUT OF STOCK status (0 units - triggers critical reorder workflow)...${NC}"
echo

# Create product with critical stock (0 units)
CRITICAL_STOCK_EVENT=$(cat <<EOF
{
  "productId": $((PRODUCT_ID + 1)),
  "productName": "${PRODUCT_NAME} (Out of Stock)",
  "productDescription": "Test product for critical stock workflow",
  "stockOnHand": 0,
  "lowStockThreshold": ${LOW_THRESHOLD}
}
EOF
)

echo -e "${GREEN}Critical Stock Event Payload:${NC}"
echo "$CRITICAL_STOCK_EVENT" | jq '.'
echo

echo -e "${CYAN}Posting product to Products Service...${NC}"
show_command "curl -X POST ${BASE_URL}/products-service/products \\\n  -H 'Content-Type: application/json' \\\n  -d '...'"

TEMP_FILE=$(mktemp)
echo "$CRITICAL_STOCK_EVENT" > "$TEMP_FILE"
RESPONSE=$(execute_with_retry "curl -s -X POST ${BASE_URL}/products-service/products -H 'Content-Type: application/json' -d @${TEMP_FILE}")
rm -f "$TEMP_FILE"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Product Service Response:${NC}"
    echo "$RESPONSE" | jq '.' 2>/dev/null || echo "$RESPONSE"
else
    echo -e "${RED}Failed to post product to products service${NC}"
fi

echo

print_header "Workflow Monitoring"

echo -e "${GREEN}To monitor workflow execution in real-time:${NC}"
echo
echo -e "${CYAN}1. Open the Workflow Dashboard:${NC}"
echo -e "${YELLOW}   ${BASE_URL}${NC}"
echo
echo -e "${CYAN}2. View workflow pod logs:${NC}"
echo -e "${YELLOW}   kubectl logs ${WORKFLOW_POD_NAME} -f${NC}"
echo
echo -e "${CYAN}3. Check workflow service traces:${NC}"
echo -e "${YELLOW}   kubectl logs ${WORKFLOW_POD_NAME} | grep -i workflow${NC}"
echo
echo -e "${CYAN}4. Inspect Dapr workflow state:${NC}"
echo -e "${YELLOW}   dapr invoke --app-id workflow-service --method get-workflow-status --data '{\"workflowId\":\"<id>\"}'${NC}"
echo

print_header "Demo Complete!"

echo -e "${GREEN}Summary of what we demonstrated:${NC}"
echo
echo -e "${CYAN}✓ Low Stock Workflow${NC}"
echo "  - Automatically triggered when stock falls below threshold"
echo "  - Uses Dapr Workflow for orchestration"
echo "  - Integrates with OpenAI for intelligent reordering"
echo
echo -e "${CYAN}✓ Critical Stock Workflow${NC}"
echo "  - Automatically triggered for severely low stock"
echo "  - Sends critical alerts to stakeholders"
echo "  - Coordinates with notification service"
echo
echo -e "${CYAN}✓ Event-Driven Architecture${NC}"
echo "  - Drasi detects stock changes automatically"
echo "  - Workflows react to events in real-time"
echo "  - Data validation ensures data integrity"
echo

echo -e "${YELLOW}Next Steps:${NC}"
echo -e "${GREEN}1. Try modifying stock levels to trigger different workflows${NC}"
echo -e "${GREEN}2. Monitor the workflow dashboard for execution details${NC}"
echo -e "${GREEN}3. Check notification service for alerts${NC}"
echo -e "${GREEN}4. Explore workflow state in Dapr state store${NC}"
echo
