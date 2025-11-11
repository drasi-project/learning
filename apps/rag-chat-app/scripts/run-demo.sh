#!/bin/bash

# Drasi RAG Demo - Interactive Demo Script
# Demonstrates real-time vector store synchronization

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

print_info() {
    echo -e "${BLUE}$1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_demo() {
    echo -e "${MAGENTA}► $1${NC}"
}

print_query() {
    echo -e "${CYAN}SQL> $1${NC}"
}

print_action() {
    echo ""
    echo -e "${GREEN}╔══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  ACTION: $1${NC}"
    echo -e "${GREEN}╚══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
}

# Function to wait with countdown
wait_with_countdown() {
    local seconds=$1
    local message=$2
    echo -n "$message"
    for i in $(seq $seconds -1 1); do
        echo -ne "\r$message ($i seconds)..."
        sleep 1
    done
    echo -ne "\r$message Done!                    \n"
}

# Function to check vector count
check_vector_count() {
    local count=$(curl -s http://localhost:6333/collections/product_knowledge 2>/dev/null | grep -o '"points_count":[0-9]*' | cut -d: -f2)
    echo "$count"
}

# Function to pause for RAG demo
pause_for_rag_demo() {
    local prompt="$1"
    echo ""
    print_action "$prompt"
    echo -e "${YELLOW}Switch to the RAG app terminal now and try the suggested queries.${NC}"
    echo -e "${YELLOW}When done demonstrating, come back here and press Enter to continue...${NC}"
    read -r
}

# Clear screen and show banner
clear
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║           Drasi RAG Demo - Live Demonstration               ║"
echo "║                                                              ║"
echo "║  Watch how changes in databases automatically update        ║"
echo "║  the vector store and RAG responses in real-time!           ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""

# Check prerequisites
print_info "Checking prerequisites..."
if ! curl -s http://localhost:6333/collections &>/dev/null; then
    print_error "Qdrant is not accessible at localhost:6333"
    echo "Please run the deployment script first: ../scripts/deploy.sh"
    exit 1
fi

if ! kubectl exec postgres-products-0 -- psql -U postgres -d postgres_db -c "SELECT 1" &>/dev/null; then
    print_error "PostgreSQL is not accessible"
    echo "Please run the deployment script first: ../scripts/deploy.sh"
    exit 1
fi

print_success "All services are running!"
echo ""

# Get initial state
INITIAL_COUNT=$(check_vector_count)
print_info "Initial state: $INITIAL_COUNT products in vector store"
echo ""

print_warning "IMPORTANT: Make sure the RAG app is running in another terminal!"
echo "If not running yet, open a new terminal and run:"
echo "  cd app"
echo "  dotnet run"
echo ""
echo -e "${YELLOW}Press Enter when the RAG app is ready...${NC}"
read -r

# Initial RAG demo
pause_for_rag_demo "Show current laptop inventory in RAG app"
echo "Suggested queries to try:"
echo "  • 'What laptops do you have?'"
echo "  • 'Which laptop has the best rating?'"
echo "  • 'Tell me about the TechPro X1'"
echo ""

# Demo Scenario 1: Add new laptop with reviews
echo "═══════════════════════════════════════════════════════════════"
echo "  Demo 1: Adding New Product with Reviews"
echo "═══════════════════════════════════════════════════════════════"
echo ""
print_demo "Currently, the RAG system knows about existing laptops."
print_demo "Let's add a brand new gaming laptop to the catalog!"
echo ""
echo -e "${YELLOW}Press Enter to add the new laptop...${NC}"
read -r

# Add the laptop
print_query "INSERT INTO products (id, name, category, description, specifications, price)"
print_query "VALUES ('LAPTOP-005', 'GamerX Elite', 'Laptops', "
print_query "        'Ultimate gaming laptop with RTX 4080', "
print_query "        '{\"cpu\": \"Intel i9-14900HX\", \"gpu\": \"RTX 4080\", \"ram\": \"32GB DDR5\", \"display\": \"17.3-inch QHD 240Hz\"}', "
print_query "        2499.99);"
echo ""

kubectl exec -it postgres-products-0 -- psql -U postgres -d postgres_db -c "
INSERT INTO products (id, name, category, description, specifications, price) 
VALUES ('LAPTOP-005', 'GamerX Elite', 'Laptops', 
        'Ultimate gaming laptop with RTX 4080', 
        '{\"cpu\": \"Intel i9-14900HX\", \"gpu\": \"RTX 4080\", \"ram\": \"32GB DDR5\", \"display\": \"17.3-inch QHD 240Hz\"}', 
        2499.99);" 2>/dev/null

print_success "New laptop added to PostgreSQL!"
echo ""

print_demo "Now let's also add a couple of customer reviews for this new laptop..."
echo -e "${YELLOW}Press Enter to add reviews...${NC}"
read -r

# Add reviews
print_query "INSERT INTO reviews (product_id, customer_name, rating, review_text)"
print_query "VALUES ('LAPTOP-005', 'ProGamer', 5, 'Best gaming laptop ever! Runs everything at max settings.'),"
print_query "       ('LAPTOP-005', 'TechEnthusiast', 5, 'Worth every penny. The 240Hz display is incredible!');"
echo ""

kubectl exec -it mysql-reviews-0 -- mysql -u root -pmysql123 feedback_db -e "
INSERT INTO reviews (product_id, customer_name, rating, review_text) 
VALUES ('LAPTOP-005', 'ProGamer', 5, 'Best gaming laptop ever! Runs everything at max settings.'),
       ('LAPTOP-005', 'TechEnthusiast', 5, 'Worth every penny. The 240Hz display is incredible!');" 2>/dev/null

print_success "Reviews added to MySQL!"
echo ""

wait_with_countdown 3 "Waiting for Drasi to sync"

NEW_COUNT=$(check_vector_count)
if [ "$NEW_COUNT" -gt "$INITIAL_COUNT" ]; then
    print_success "Vector store updated! Now has $NEW_COUNT products (was $INITIAL_COUNT)"
else
    print_warning "Sync may still be in progress..."
fi

pause_for_rag_demo "Now search for 'GamerX Elite' - it WILL appear!"
echo "Suggested queries:"
echo "  • 'Tell me about the GamerX Elite'"
echo "  • 'What gaming laptops do you have?'"
echo "  • 'Which laptop is best for gaming?'"
echo ""

# Demo Scenario 2: Update reviews
echo "═══════════════════════════════════════════════════════════════"
echo "  Demo 2: Adding More Reviews (Rating Changes)"
echo "═══════════════════════════════════════════════════════════════"
echo ""
print_demo "The GamerX Elite currently has a perfect 5-star rating (2 reviews)."
print_demo "Let's add some mixed reviews to see the rating update in real-time!"
echo ""
echo -e "${YELLOW}Press Enter to add mixed reviews...${NC}"
read -r

print_query "INSERT INTO reviews (product_id, customer_name, rating, review_text)"
print_query "VALUES ('LAPTOP-005', 'BudgetBuyer', 3, 'Great performance but too expensive.'),"
print_query "       ('LAPTOP-005', 'CasualUser', 4, 'Excellent but overkill for my needs.');"
echo ""

kubectl exec -it mysql-reviews-0 -- mysql -u root -pmysql123 feedback_db -e "
INSERT INTO reviews (product_id, customer_name, rating, review_text) 
VALUES ('LAPTOP-005', 'BudgetBuyer', 3, 'Great performance but too expensive.'),
       ('LAPTOP-005', 'CasualUser', 4, 'Excellent but overkill for my needs.');" 2>/dev/null

print_success "Mixed reviews added!"
print_info "New average: (5+5+3+4)/4 = 4.25 stars"
echo ""

wait_with_countdown 3 "Waiting for rating update to sync"

pause_for_rag_demo "Check the GamerX Elite rating - it's now 4.25 stars!"
echo "Suggested queries:"
echo "  • 'What's the rating for GamerX Elite?'"
echo "  • 'What do customers say about the GamerX Elite?'"
echo "  • 'Is the GamerX Elite worth the price?'"
echo ""

# Demo Scenario 3: Show tablets
echo "═══════════════════════════════════════════════════════════════"
echo "  Demo 3: Exploring Existing Products (Tablets)"
echo "═══════════════════════════════════════════════════════════════"
echo ""
print_demo "Let's explore what tablets are in the system..."
echo ""

print_query "SELECT p.id, p.name, p.price FROM products p WHERE category = 'Tablets';"
echo ""

kubectl exec -it postgres-products-0 -- psql -U postgres -d postgres_db -c "
SELECT p.id, p.name, p.price
FROM products p 
WHERE category = 'Tablets'
ORDER BY p.id;" 2>/dev/null

echo ""

pause_for_rag_demo "Query about tablets in the RAG app"
echo "Suggested queries:"
echo "  • 'What tablets do you have?'"
echo "  • 'Tell me about the WorkPad Pro'"
echo "  • 'Which tablet is best for students?'"
echo "  • 'Compare the available tablets'"
echo ""

# Summary
echo "╔══════════════════════════════════════════════════════════════╗"
echo "║                     Demo Complete!                          ║"
echo "╚══════════════════════════════════════════════════════════════╝"
echo ""
print_success "You've demonstrated Drasi's real-time synchronization:"
echo "  1. ✓ Added new product (GamerX Elite) - appeared after reviews"
echo "  2. ✓ Updated ratings with mixed reviews - 5.0 → 4.25 stars"
echo "  3. ✓ Explored existing tablets in the system"
echo ""
echo "All changes were automatically synced to the vector store!"
echo "The RAG app always has the latest information without any manual intervention."
echo ""
echo "Thank you for watching the Drasi RAG demo!"