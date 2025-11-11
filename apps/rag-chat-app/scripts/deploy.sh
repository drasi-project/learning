#!/bin/bash

# Drasi RAG Demo Deployment Script

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
DB_DIR="$PROJECT_ROOT/databases"
DEVOPS_DIR="$PROJECT_ROOT/drasi"
APP_DIR="$PROJECT_ROOT/app"

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Parse command line arguments
AUTO_MODE=false
for arg in "$@"; do
    case $arg in
        -y|--yes|--auto)
            AUTO_MODE=true
            shift
            ;;
    esac
done

# Function to print colored output
print_info() {
    echo -e "${BLUE}$1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

# Function to ask for confirmation
confirm() {
    local prompt="$1"

    # Skip confirmation in auto mode
    if [ "$AUTO_MODE" = true ]; then
        return 0
    fi

    echo ""
    echo -e "${YELLOW}$prompt${NC}"
    echo -e "${BLUE}Press Enter to continue, or Ctrl+C to cancel...${NC}"
    read -r
}

# Banner
clear
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║          Drasi RAG Demo - Interactive Deployment             ║"
echo "║                                                              ║"
echo "║  This will deploy a complete RAG demo environment with:      ║"
echo "║  • PostgreSQL (product catalog)                              ║"
echo "║  • MySQL (customer reviews)                                  ║"
echo "║  • Qdrant (vector database)                                  ║"
echo "║  • Drasi Continuous Queries                                  ║"
echo "║  • Drasi Sync Vector store reaction.                         ║"
echo "║                                                              ║"
echo "║  Usage: ./deploy.sh [-y|--yes|--auto]                        ║"
echo "║  Use -y flag for automated deployment without prompts        ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

if [ "$AUTO_MODE" = true ]; then
    print_info "Running in automated mode (no confirmations)"
    echo ""
fi

# Step 1: Prerequisites Check
print_info "Step 1: Checking prerequisites..."
echo ""

# Check kubectl
if ! command -v kubectl &> /dev/null; then
    print_error "kubectl is not installed"
    exit 1
fi
print_success "kubectl found"

# Check drasi CLI
if ! command -v drasi &> /dev/null; then
    print_error "drasi CLI is not installed"
    exit 1
fi
print_success "drasi CLI found"

# Check cluster connection
if ! kubectl cluster-info &> /dev/null; then
    print_error "Not connected to a Kubernetes cluster"
    echo "Please ensure you have a Kind cluster running and kubectl is configured"
    exit 1
fi
CLUSTER_NAME=$(kubectl config current-context)
print_success "Connected to cluster: $CLUSTER_NAME"

# Check Drasi installation
if ! kubectl get namespace drasi-system &> /dev/null; then
    print_error "Drasi is not installed in the cluster"
    echo "Please install Drasi first using: drasi init"
    exit 1
fi
print_success "Drasi is installed"

# Check for .env file or create it
ENV_FILE="$APP_DIR/.env"
if [ -f "$ENV_FILE" ]; then
    print_info "Loading Azure OpenAI credentials from $ENV_FILE"
    # Load environment variables from .env file
    export $(grep -v '^#' "$ENV_FILE" | xargs)
    print_success "Credentials loaded from .env file"
else
    print_warning ".env file not found at $ENV_FILE"
    echo ""
    echo "Please provide your Azure OpenAI credentials:"
    
    # Prompt for credentials
    read -p "Azure OpenAI Endpoint (e.g., https://your-resource.cognitiveservices.azure.com/): " AZURE_OPENAI_ENDPOINT
    read -p "Azure OpenAI API Key: " AZURE_OPENAI_API_KEY
    read -p "Chat deployment name (default: gpt-4): " AZURE_OPENAI_CHAT_DEPLOYMENT
    AZURE_OPENAI_CHAT_DEPLOYMENT=${AZURE_OPENAI_CHAT_DEPLOYMENT:-gpt-4}
    read -p "Embedding deployment name (default: text-embedding-3-large): " AZURE_OPENAI_EMBEDDING_DEPLOYMENT
    AZURE_OPENAI_EMBEDDING_DEPLOYMENT=${AZURE_OPENAI_EMBEDDING_DEPLOYMENT:-text-embedding-3-large}
    
    # Create .env file
    cat > "$ENV_FILE" << EOF
# Azure OpenAI Configuration
AZURE_OPENAI_ENDPOINT=$AZURE_OPENAI_ENDPOINT
AZURE_OPENAI_API_KEY=$AZURE_OPENAI_API_KEY
AZURE_OPENAI_CHAT_DEPLOYMENT=$AZURE_OPENAI_CHAT_DEPLOYMENT
AZURE_OPENAI_EMBEDDING_DEPLOYMENT=$AZURE_OPENAI_EMBEDDING_DEPLOYMENT

# Qdrant Configuration (defaults for local deployment)
QDRANT_HOST=localhost
QDRANT_PORT=6334
QDRANT_COLLECTION=product_knowledge
EOF
    
    print_success "Created .env file with your credentials"
fi

# Validate credentials are set
if [ -z "$AZURE_OPENAI_ENDPOINT" ] || [ -z "$AZURE_OPENAI_API_KEY" ]; then
    print_error "Azure OpenAI credentials are not properly configured"
    echo "Please check your .env file at: $ENV_FILE"
    exit 1
fi
print_success "Azure OpenAI credentials configured"

echo ""
print_success "All prerequisites met!"

confirm "The next step will deploy databases (PostgreSQL, MySQL, Qdrant) with initial seed data."

# Step 2: Configure DNS and Deploy Infrastructure
print_info "Step 2: Configuring DNS and deploying infrastructure..."
echo ""

# Add Google DNS to CoreDNS for better external resolution
print_info "Configuring CoreDNS for reliable external DNS resolution..."
kubectl get configmap coredns -n kube-system -o yaml | \
  sed 's/forward . \/etc\/resolv.conf/forward . \/etc\/resolv.conf 8.8.8.8 8.8.4.4/' | \
  kubectl apply -f - 2>/dev/null || \
  kubectl get configmap coredns -n kube-system -o yaml | \
  grep -q "8.8.8.8" || \
  (kubectl patch configmap coredns -n kube-system --type='json' \
    -p='[{"op": "replace", "path": "/data/Corefile", "value": ".:53 {\n    errors\n    health {\n       lameduck 5s\n    }\n    ready\n    kubernetes cluster.local in-addr.arpa ip6.arpa {\n       pods insecure\n       fallthrough in-addr.arpa ip6.arpa\n       ttl 30\n    }\n    prometheus :9153\n    forward . /etc/resolv.conf 8.8.8.8 8.8.4.4 {\n       max_concurrent 1000\n    }\n    cache 30\n    loop\n    reload\n    loadbalance\n}\n"}]' 2>/dev/null) || true

# Restart CoreDNS to apply changes
kubectl rollout restart deployment/coredns -n kube-system 2>/dev/null || true
kubectl wait --for=condition=ready pod -l k8s-app=kube-dns -n kube-system --timeout=60s 2>/dev/null || true
print_success "DNS configuration updated"

echo ""

# Deploy Qdrant
print_info "Deploying Qdrant vector database..."
kubectl apply -f "$DB_DIR/qdrant.yaml"
print_success "Qdrant deployment created"

# Deploy PostgreSQL
print_info "Deploying PostgreSQL with product catalog data..."
kubectl apply -f "$DB_DIR/postgres-products.yaml"
print_success "PostgreSQL deployment created"

# Deploy MySQL
print_info "Deploying MySQL with customer reviews data..."
kubectl apply -f "$DB_DIR/mysql-reviews.yaml"
print_success "MySQL deployment created"

echo ""
print_info "Waiting for databases to be ready (this may take a minute)..."
kubectl wait --for=condition=ready pod -l app=qdrant --timeout=120s
print_success "Qdrant is ready"
kubectl wait --for=condition=ready pod -l app=postgres-products --timeout=120s
print_success "PostgreSQL is ready"
kubectl wait --for=condition=ready pod -l app=mysql-reviews --timeout=120s
print_success "MySQL is ready"

echo ""
print_success "All databases are running with initial seed data!"
echo "  • PostgreSQL has 12 products across 4 categories"
echo "  • MySQL has customer reviews for 9 products"
echo "  • Qdrant is ready to receive vectors"

confirm "The next step will create Azure OpenAI credentials secret."

# Step 3: Azure OpenAI Secret
print_info "Step 3: Creating Azure OpenAI credentials secret..."
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: azure-openai-credentials
  namespace: drasi-system
type: Opaque
stringData:
  AZURE_OPENAI_ENDPOINT: "$AZURE_OPENAI_ENDPOINT"
  AZURE_OPENAI_API_KEY: "$AZURE_OPENAI_API_KEY"
EOF
print_success "Azure OpenAI credentials secret created"


confirm "The next step will deploy Drasi components (reaction provider, sources, query, reaction)."

# Step 4: Deploy Drasi Components
print_info "Step 4: Deploying Drasi components..."
echo ""

# Deploy reaction provider
print_info "Registering Semantic Kernel reaction provider..."
drasi apply -f "$DEVOPS_DIR/reaction-provider.yaml"
print_success "Reaction provider registered and ready"

# Deploy sources
echo ""
print_info "Creating data sources..."
print_info "  • product-catalog (PostgreSQL)"
print_info "  • customer-feedback (MySQL)"
drasi apply -f "$DEVOPS_DIR/sources.yaml"
print_info "Waiting for sources to be ready..."
drasi wait -f "$DEVOPS_DIR/sources.yaml"
print_success "Data sources created and ready"

# Deploy query
echo ""
print_info "Creating continuous query 'enriched-products'..."
print_info "  This query joins products with their reviews"
drasi apply -f "$DEVOPS_DIR/query.yaml"
print_info "Waiting for query to be ready..."
drasi wait -f "$DEVOPS_DIR/query.yaml"
print_success "Continuous query created and ready"

# Deploy reaction
echo ""
print_info "Creating vector store reaction..."
print_info "  This will sync query results to Qdrant"

# Create temporary reaction file with credentials
TEMP_REACTION="/tmp/qdrant-reaction-configured.yaml"
sed "s|\${AZURE_OPENAI_ENDPOINT}|$AZURE_OPENAI_ENDPOINT|g; s|\${AZURE_OPENAI_API_KEY}|$AZURE_OPENAI_API_KEY|g" \
    "$DEVOPS_DIR/reaction.yaml" > "$TEMP_REACTION"

drasi apply -f "$TEMP_REACTION"
print_info "Waiting for reaction to be ready..."
drasi wait -f "$TEMP_REACTION"
rm "$TEMP_REACTION"
print_success "Vector store reaction created and ready"

echo ""
print_success "All Drasi components deployed!"
echo "  • 2 data sources connected"
echo "  • 1 continuous query running"
echo "  • 1 reaction syncing to Qdrant"

confirm "The next step will set up port forwarding for local access."

# Step 6: Port Forwarding
print_info "Step 6: Setting up port forwarding..."
echo ""

# Kill existing port forwards
pkill -f "kubectl port-forward.*qdrant" 2>/dev/null || true
pkill -f "kubectl port-forward.*postgres-products" 2>/dev/null || true
pkill -f "kubectl port-forward.*mysql-reviews" 2>/dev/null || true

# Start port forwards
kubectl port-forward svc/qdrant 6333:6333 6334:6334 > /dev/null 2>&1 &
print_success "Qdrant: localhost:6333 (HTTP), localhost:6334 (gRPC)"

kubectl port-forward svc/postgres-products 5432:5432 > /dev/null 2>&1 &
print_success "PostgreSQL: localhost:5432"

kubectl port-forward svc/mysql-reviews 3306:3306 > /dev/null 2>&1 &
print_success "MySQL: localhost:3306"

echo ""
print_info "Waiting for initial data sync to vector store (5 seconds)..."
for i in {5..1}; do
    echo -ne "\r  ${i} seconds remaining..."
    sleep 1
done
echo -ne "\r                                    \r"

# Verify sync
POINTS=$(curl -s http://localhost:6333/collections/product_knowledge 2>/dev/null | grep -o '"points_count":[0-9]*' | cut -d: -f2)
if [ -n "$POINTS" ] && [ "$POINTS" -gt 0 ]; then
    print_success "Initial sync complete! $POINTS products in vector store"
else
    print_warning "Vector store sync may still be in progress"
fi

# Final Summary
echo ""
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                    Deployment Complete!                      ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
print_success "Your RAG demo environment is ready!"
echo ""
echo "Services running:"
echo "  • Qdrant at localhost:6334"
echo "  • PostgreSQL at localhost:5432 (user: postgres, pass: postgres123)"
echo "  • MySQL at localhost:3306 (user: root, pass: mysql123)"
echo ""
echo "Drasi components:"
echo "  • Sources: products-source, reviews-source"
echo "  • Query: enriched-products (joining products with reviews)"
echo "  • Reaction: qdrant-product-sync (syncing to vector store)"
echo ""
echo "To run the RAG demo application:"
echo "  cd $APP_DIR"
echo "  dotnet run"
echo ""
echo "  Your Azure OpenAI credentials are already configured in:"
echo "  $ENV_FILE"
echo ""
echo "To run the demo scenarios:"
echo "  cd $PROJECT_ROOT/demo-scripts"
echo "  ./run-demo.sh"
echo ""
echo "To monitor the system:"
echo "  • drasi list source"
echo "  • drasi list query"
echo "  • drasi list reaction"
echo "  • kubectl logs -n drasi-system -l drasi/reaction=qdrant-product-sync -f"
echo ""
echo "To clean up everything:"
echo "  $PROJECT_ROOT/scripts/cleanup.sh"
echo ""
print_info "Port forwarding is running in the background."
print_info "To stop port forwarding: pkill -f 'kubectl port-forward'"