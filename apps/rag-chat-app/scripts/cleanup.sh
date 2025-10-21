#!/bin/bash

# Drasi RAG Demo Cleanup Script
# Removes all demo resources

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
DB_DIR="$PROJECT_ROOT/databases"
DEVOPS_DIR="$PROJECT_ROOT/devops"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

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

print_info() {
    echo -e "${BLUE}$1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
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

echo "╔══════════════════════════════════════════════════════════════╗"
echo "║            Drasi RAG Demo - Cleanup Script                   ║"
echo "║                                                              ║"
echo "║  Usage: ./cleanup.sh [-y|--yes|--auto]                       ║"
echo "║  Use -y flag for automated cleanup without prompts           ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

if [ "$AUTO_MODE" = true ]; then
    print_info "Running in automated mode (no confirmations)"
    echo ""
fi

# Show what will be deleted
print_warning "This will delete the following resources:"
echo "  • Drasi reaction: qdrant-product-sync"
echo "  • Drasi query: enriched-products"
echo "  • Drasi sources: products-source, reviews-source"
echo "  • Drasi reaction provider: sync-semantickernel-vectorstore"
echo "  • Kubernetes deployments: PostgreSQL, MySQL, Qdrant"
echo "  • Azure OpenAI credentials secret"
echo "  • All associated persistent volume claims"

confirm "Are you sure you want to proceed with cleanup?"

# Stop port forwarding
print_info "Stopping port forwarding..."
pkill -f "kubectl port-forward.*qdrant" 2>/dev/null || true
pkill -f "kubectl port-forward.*postgres-products" 2>/dev/null || true
pkill -f "kubectl port-forward.*mysql-reviews" 2>/dev/null || true
print_success "Port forwarding stopped"

# Delete Drasi resources
print_info "Deleting Drasi resources..."

# Delete reaction
if drasi list reaction 2>/dev/null | grep -q "qdrant-product-sync"; then
    drasi delete reaction qdrant-product-sync
    print_success "Reaction deleted"
else
    print_warning "Reaction not found"
fi

# Delete query
if drasi list query 2>/dev/null | grep -q "enriched-products"; then
    drasi delete query enriched-products
    print_success "Query deleted"
else
    print_warning "Query not found"
fi

# Delete sources
if drasi list source 2>/dev/null | grep -q "products-source"; then
    drasi delete source products-source
    print_success "Source 'products-source' deleted"
else
    print_warning "Source 'products-source' not found"
fi

if drasi list source 2>/dev/null | grep -q "reviews-source"; then
    drasi delete source reviews-source
    print_success "Source 'reviews-source' deleted"
else
    print_warning "Source 'reviews-source' not found"
fi

# Delete reaction provider
if drasi list reactionprovider 2>/dev/null | grep -q "sync-semantickernel-vectorstore"; then
    drasi delete reactionprovider sync-semantickernel-vectorstore
    print_success "Reaction provider deleted"
else
    print_warning "Reaction provider not found"
fi

# Delete Kubernetes resources
print_info "Deleting Kubernetes resources..."

kubectl delete -f "$DB_DIR/mysql-reviews.yaml" 2>/dev/null || print_warning "MySQL already deleted"
kubectl delete -f "$DB_DIR/postgres-products.yaml" 2>/dev/null || print_warning "PostgreSQL already deleted"
kubectl delete -f "$DB_DIR/qdrant.yaml" 2>/dev/null || print_warning "Qdrant already deleted"

# Delete Azure OpenAI secret
kubectl delete secret azure-openai-credentials -n drasi-system 2>/dev/null || print_warning "Azure OpenAI secret already deleted"

# Delete PVCs
print_info "Deleting persistent volume claims..."
kubectl delete pvc postgres-products-pvc 2>/dev/null || true
kubectl delete pvc mysql-feedback-pvc 2>/dev/null || true
kubectl delete pvc qdrant-storage 2>/dev/null || true

echo ""
print_success "Cleanup complete!"
echo ""
echo "All demo resources have been removed."
echo "The Drasi platform itself remains installed."
echo ""
echo "To reinstall the demo, run:"
echo "  $PROJECT_ROOT/scripts/deploy.sh"