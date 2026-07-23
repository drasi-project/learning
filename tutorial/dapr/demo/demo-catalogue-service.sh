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
if [ -z "$BASE_URL" ]; then
    if [ -n "$CODESPACES" ]; then
        BASE_URL="http://localhost"
    elif command -v docker >/dev/null 2>&1 && docker inspect k3d-drasi-tutorial-serverlb >/dev/null 2>&1; then
        PORT=$(docker port k3d-drasi-tutorial-serverlb 80 2>/dev/null | head -n1 | cut -d: -f2)
        if [ -n "$PORT" ]; then
            BASE_URL="http://localhost:${PORT}"
        else
            BASE_URL="http://localhost:8123"
        fi
    else
        BASE_URL="http://localhost:8123"
    fi
fi

echo "Using BASE_URL: ${BASE_URL}"

# Track created entities for cleanup
CREATED_PRODUCT=""
CREATED_REVIEWS=()

# Helper function to print headers
print_header() {
    echo
    echo -e "${CYAN}${BOLD}===================================================${NC}"
    echo -e "${CYAN}${BOLD}$1${NC}"
    echo -e "${CYAN}${BOLD}===================================================${NC}"
    echo
}

# Helper function to wait for user to continue
wait_for_continue() {
    local prompt="${1:-Press Enter to continue...}"
    echo -e "${YELLOW}${prompt}${NC}"
    read -p "> " response
}

# Start of demo
clear
print_header "Catalogue Service Demo - Real-time Data Synchronization with Drasi"

echo -e "${GREEN}This demo showcases Drasi's real-time data synchronization capabilities:${NC}"
echo
echo -e "${CYAN}${BOLD}Query Demonstrated:${NC} product-catalogue-query"
echo -e "${GREEN}• Joins products with reviews${NC}"
echo -e "${GREEN}• Calculates average ratings in real-time${NC}"
echo -e "${GREEN}• Aggregates review counts${NC}"
echo
echo -e "${CYAN}${BOLD}Reaction Used:${NC} Sync Dapr State Store"
echo -e "${GREEN}• Maintains materialized view in state store${NC}"
echo -e "${GREEN}• Updates automatically on data changes${NC}"
echo -e "${GREEN}• No polling - pure event-driven${NC}"
echo

wait_for_continue "Press Enter to begin the demo..."

# Generate random product ID
PRODUCT_ID=$((RANDOM % 9000 + 1000))  # Random ID between 1000-9999
echo
echo -e "${BLUE}Generated Product ID: ${PRODUCT_ID}${NC}"
echo

# Generate product details
PRODUCT_NAMES=("Ultra HD Smart TV" "Wireless Gaming Mouse" "Mechanical Keyboard Pro" "Noise Cancelling Headphones" "4K Action Camera" "Smart Home Hub" "Portable SSD Drive" "Gaming Monitor 144Hz" "Wireless Charging Pad" "Smart Fitness Tracker")
PRODUCT_DESCRIPTIONS=("Latest technology with stunning visuals" "High precision gaming mouse with RGB lighting" "Premium mechanical switches for typing enthusiasts" "Premium audio with active noise cancellation" "Capture your adventures in stunning 4K" "Control your entire smart home ecosystem" "Lightning fast storage for professionals" "Smooth gaming experience with low latency" "Fast wireless charging for all devices" "Track your health and fitness goals")

# Pick random product details
RANDOM_INDEX=$((RANDOM % ${#PRODUCT_NAMES[@]}))
PRODUCT_NAME="${PRODUCT_NAMES[$RANDOM_INDEX]}"
PRODUCT_DESC="${PRODUCT_DESCRIPTIONS[$RANDOM_INDEX]}"
STOCK=$((RANDOM % 100 + 50))  # Random stock between 50-150
THRESHOLD=$((RANDOM % 20 + 10))  # Random threshold between 10-30

print_header "Step 1: Create Product"

echo -e "${CYAN}Creating product with the following details:${NC}"
echo -e "${CYAN}• Product ID: ${PRODUCT_ID}${NC}"
echo -e "${CYAN}• Name: ${PRODUCT_NAME}${NC}"
echo -e "${CYAN}• Description: ${PRODUCT_DESC}${NC}"
echo -e "${CYAN}• Stock: ${STOCK} units${NC}"
echo

wait_for_continue "Press Enter to create the product..."

echo
echo -e "${GREEN}Creating product ${PRODUCT_ID}...${NC}"

PRODUCT_JSON=$(cat <<EOF
{
  "productId": ${PRODUCT_ID},
  "productName": "${PRODUCT_NAME}",
  "productDescription": "${PRODUCT_DESC}",
  "stockOnHand": ${STOCK},
  "lowStockThreshold": ${THRESHOLD}
}
EOF
)

# Create product
TEMP_FILE=$(mktemp)
echo "$PRODUCT_JSON" > "$TEMP_FILE"
response=$(curl -s -X POST ${BASE_URL}/products-service/products \
    -H "Content-Type: application/json" \
    -d @${TEMP_FILE} \
    -w "\n%{http_code}" 2>/dev/null)
rm -f "$TEMP_FILE"

http_code=$(echo "$response" | tail -1)
body=$(echo "$response" | sed '$d')

if [ "$http_code" = "201" ] || [ "$http_code" = "200" ]; then
    echo "$body"
    CREATED_PRODUCT=$PRODUCT_ID
    echo
    echo -e "${GREEN}✓ Product created successfully!${NC}"
    echo
    echo -e "${YELLOW}${BOLD}📊 CHECKPOINT #1: Check Catalogue${NC}"
    echo -e "${GREEN}Run this command to check the catalogue:${NC}"
    echo
    echo -e "${BOLD}curl ${BASE_URL}/catalogue-service/api/catalogue/${PRODUCT_ID} | jq .${NC}"
    echo
    echo -e "${CYAN}Expected: Product will NOT appear yet${NC}"
    echo -e "${CYAN}The catalogue only shows products that have reviews.${NC}"
    echo
    
    wait_for_continue "Press Enter after confirming the product is NOT in the catalogue yet..."
    
    echo -e "${GREEN}✓ Correct! The product needs reviews to appear. Let's add some!${NC}"
else
    echo -e "${RED}Failed to create product (HTTP ${http_code})${NC}"
    echo "$body"
    exit 1
fi

echo
print_header "Step 2: Add Initial Reviews (Part 1)"

echo -e "${CYAN}Let's add 2 initial reviews to see the rating calculation:${NC}"
echo -e "${CYAN}• First review: Rating 5⭐${NC}"
echo -e "${CYAN}• Second review: Rating 4⭐${NC}"
echo -e "${CYAN}• Expected average: 4.5⭐${NC}"
echo

wait_for_continue "Press Enter to create the first batch of reviews..."

# Create first batch of reviews (2 reviews)
REVIEW_TEXTS=(
    "Excellent product! Highly recommended."
    "Good value for money. Works as expected."
)

RATINGS=(5 4)  # First batch ratings

for i in 0 1; do
    REVIEW_ID=$((${PRODUCT_ID}000 + i + 1))
    CUSTOMER_ID=$((RANDOM % 10 + 1))
    RATING=${RATINGS[$i]}
    REVIEW_TEXT="${REVIEW_TEXTS[$i]}"
    
    echo
    echo -e "${GREEN}Creating review $(($i + 1))/2 (Rating: ${RATING}⭐)...${NC}"
    
    REVIEW_JSON=$(cat <<EOF
{
  "reviewId": ${REVIEW_ID},
  "productId": ${PRODUCT_ID},
  "customerId": ${CUSTOMER_ID},
  "rating": ${RATING},
  "reviewText": "${REVIEW_TEXT}"
}
EOF
)
    
    TEMP_FILE=$(mktemp)
    echo "$REVIEW_JSON" > "$TEMP_FILE"
    response=$(curl -s -X POST ${BASE_URL}/reviews-service/reviews \
        -H "Content-Type: application/json" \
        -d @${TEMP_FILE} \
        -w "\n%{http_code}" 2>/dev/null)
    rm -f "$TEMP_FILE"
    
    http_code=$(echo "$response" | tail -1)
    body=$(echo "$response" | sed '$d')
    
    if [ "$http_code" = "201" ] || [ "$http_code" = "200" ]; then
        echo "$body"
        CREATED_REVIEWS+=($REVIEW_ID)
        echo -e "${GREEN}✓ Review created${NC}"
    else
        echo -e "${RED}Failed to create review (HTTP ${http_code})${NC}"
        echo "$body"
    fi
done

echo
echo -e "${YELLOW}${BOLD}📊 CHECKPOINT #2: Product Now Appears with Reviews${NC}"
echo -e "${GREEN}Run this command to see the product with aggregated review data:${NC}"
echo
echo -e "${BOLD}curl ${BASE_URL}/catalogue-service/api/catalogue/${PRODUCT_ID} | jq .${NC}"
echo
echo -e "${CYAN}Expected values:${NC}"
echo -e "${CYAN}• avgRating: 4.5 (average of 5 and 4)${NC}"
echo -e "${CYAN}• reviewCount: 2${NC}"
echo -e "${CYAN}The product now appears because it has reviews!${NC}"
echo

wait_for_continue "Press Enter after verifying avgRating=4.5 and reviewCount=2..."

echo -e "${GREEN}✓ Excellent! Drasi calculated the aggregations in real-time!${NC}"

echo
print_header "Step 3: Add More Reviews (Part 2)"

echo -e "${CYAN}Now let's add 3 more reviews to see the rating update:${NC}"
echo -e "${CYAN}• Third review: Rating 3⭐${NC}"
echo -e "${CYAN}• Fourth review: Rating 5⭐${NC}"
echo -e "${CYAN}• Fifth review: Rating 4⭐${NC}"
echo -e "${CYAN}• New expected average: 4.2⭐ (21/5)${NC}"
echo

wait_for_continue "Press Enter to create the second batch of reviews..."

# Create second batch of reviews (3 more reviews)
MORE_REVIEW_TEXTS=(
    "Decent product with room for improvement."
    "Outstanding! Exceeded my expectations."
    "Solid choice. No complaints."
)

MORE_RATINGS=(3 5 4)  # Second batch ratings

for i in 0 1 2; do
    REVIEW_ID=$((${PRODUCT_ID}000 + i + 3))  # Continue from review 3
    CUSTOMER_ID=$((RANDOM % 10 + 11))  # Different customer IDs
    RATING=${MORE_RATINGS[$i]}
    REVIEW_TEXT="${MORE_REVIEW_TEXTS[$i]}"
    
    echo
    echo -e "${GREEN}Creating review $(($i + 3))/5 (Rating: ${RATING}⭐)...${NC}"
    
    REVIEW_JSON=$(cat <<EOF
{
  "reviewId": ${REVIEW_ID},
  "productId": ${PRODUCT_ID},
  "customerId": ${CUSTOMER_ID},
  "rating": ${RATING},
  "reviewText": "${REVIEW_TEXT}"
}
EOF
)
    
    TEMP_FILE=$(mktemp)
    echo "$REVIEW_JSON" > "$TEMP_FILE"
    response=$(curl -s -X POST ${BASE_URL}/reviews-service/reviews \
        -H "Content-Type: application/json" \
        -d @${TEMP_FILE} \
        -w "\n%{http_code}" 2>/dev/null)
    rm -f "$TEMP_FILE"
    
    http_code=$(echo "$response" | tail -1)
    body=$(echo "$response" | sed '$d')
    
    if [ "$http_code" = "201" ] || [ "$http_code" = "200" ]; then
        echo "$body"
        CREATED_REVIEWS+=($REVIEW_ID)
        echo -e "${GREEN}✓ Review created${NC}"
    else
        echo -e "${RED}Failed to create review (HTTP ${http_code})${NC}"
        echo "$body"
    fi
done

echo
echo -e "${YELLOW}${BOLD}📊 CHECKPOINT #3: Check Updated Aggregations${NC}"
echo -e "${GREEN}Run this command to see the updated aggregations:${NC}"
echo
echo -e "${BOLD}curl ${BASE_URL}/catalogue-service/api/catalogue/${PRODUCT_ID} | jq .${NC}"
echo
echo -e "${CYAN}Expected values:${NC}"
echo -e "${CYAN}• avgRating: 4.2 (average of 5, 4, 3, 5, 4 = 21/5)${NC}"
echo -e "${CYAN}• reviewCount: 5${NC}"
echo -e "${CYAN}Notice how both values updated automatically!${NC}"
echo

wait_for_continue "Press Enter after verifying avgRating=4.2 and reviewCount=5..."

echo -e "${GREEN}✓ Perfect! Drasi recalculated both aggregations with all 5 reviews!${NC}"

# Summary
print_header "Demo Complete!"

echo -e "${GREEN}${BOLD}What You Demonstrated:${NC}"
echo
echo -e "${CYAN}${BOLD}Drasi Query: product-catalogue-query${NC}"
echo -e "${GREEN}✓ Joined products with reviews in real-time${NC}"
echo -e "${GREEN}✓ Calculated average ratings automatically${NC}"
echo -e "${GREEN}✓ Updated aggregations as new reviews arrived${NC}"
echo -e "${GREEN}✓ Maintained accurate review counts${NC}"
echo
echo -e "${CYAN}${BOLD}Drasi Reaction: Sync Dapr State Store${NC}"
echo -e "${GREEN}✓ Synchronized query results to catalogue state store${NC}"
echo -e "${GREEN}✓ Updated materialized view without polling${NC}"
echo -e "${GREEN}✓ Provided instant access to aggregated data${NC}"
echo
echo -e "${YELLOW}${BOLD}Key Observations:${NC}"
echo -e "${CYAN}• Product alone did NOT appear in catalogue${NC}"
echo -e "${CYAN}• After first 2 reviews: Product appeared with avgRating=4.5, reviewCount=2${NC}"
echo -e "${CYAN}• After 3 more reviews: Updated to avgRating=4.2, reviewCount=5${NC}"
echo -e "${CYAN}• Both aggregations (avg and count) updated automatically${NC}"
echo -e "${CYAN}• All updates happened in real-time via CDC${NC}"
echo -e "${CYAN}• No polling or manual refresh required${NC}"
echo
echo -e "${GREEN}${BOLD}This demonstrates how Drasi enables:${NC}"
echo -e "${GREEN}• Real-time data synchronization${NC}"
echo -e "${GREEN}• Automatic aggregation calculations${NC}"
echo -e "${GREEN}• Materialized views with live updates${NC}"
echo -e "${GREEN}• Event-driven architecture${NC}"
echo

# Cleanup section
print_header "Optional: Clean Up Demo Data"

echo -e "${CYAN}Would you like to clean up all the demo data created?${NC}"
echo -e "${CYAN}This will delete:${NC}"
if [ ${#CREATED_REVIEWS[@]} -gt 0 ]; then
    echo -e "${CYAN}• ${#CREATED_REVIEWS[@]} reviews (IDs: ${CREATED_REVIEWS[@]})${NC}"
fi
if [ ! -z "$CREATED_PRODUCT" ]; then
    echo -e "${CYAN}• 1 product (ID: ${CREATED_PRODUCT})${NC}"
fi
echo

echo -e "${YELLOW}Note: Cleanup allows you to run this demo again with a clean environment.${NC}"
echo

# Ask if user wants to cleanup
echo -e "${YELLOW}Do you want to clean up the demo data? (yes/no):${NC}"
read -p "> " cleanup_response

if [[ "$cleanup_response" =~ ^[Yy][Ee]?[Ss]?$ ]]; then
    echo
    echo -e "${GREEN}Starting cleanup...${NC}"
    echo
    
    # Track cleanup success
    cleanup_failed=false
    
    # Delete reviews first (they reference products)
    if [ ${#CREATED_REVIEWS[@]} -gt 0 ]; then
        echo -e "${YELLOW}Deleting reviews...${NC}"
        for review_id in "${CREATED_REVIEWS[@]}"; do
            if [ ! -z "$review_id" ]; then
                echo -n "  Deleting review ${review_id}... "
                response=$(curl -s -X DELETE "${BASE_URL}/reviews-service/reviews/${review_id}" -w "\n%{http_code}" 2>/dev/null)
                http_code=$(echo "$response" | tail -1)
                
                if [ "$http_code" = "204" ] || [ "$http_code" = "404" ]; then
                    echo -e "${GREEN}✓${NC}"
                else
                    echo -e "${RED}✗ (HTTP ${http_code})${NC}"
                    cleanup_failed=true
                fi
            fi
        done
    fi
    
    # Delete product
    if [ ! -z "$CREATED_PRODUCT" ]; then
        echo
        echo -e "${YELLOW}Deleting product...${NC}"
        echo -n "  Deleting product ${CREATED_PRODUCT}... "
        response=$(curl -s -X DELETE "${BASE_URL}/products-service/products/${CREATED_PRODUCT}" -w "\n%{http_code}" 2>/dev/null)
        http_code=$(echo "$response" | tail -1)
        
        if [ "$http_code" = "204" ] || [ "$http_code" = "404" ]; then
            echo -e "${GREEN}✓${NC}"
        else
            echo -e "${RED}✗ (HTTP ${http_code})${NC}"
            cleanup_failed=true
        fi
    fi
    
    echo
    if [ "$cleanup_failed" = true ]; then
        echo -e "${YELLOW}⚠️  Some items could not be deleted (they may have been already deleted).${NC}"
        echo -e "${YELLOW}This is normal if you've run cleanup before or items were manually deleted.${NC}"
    else
        echo -e "${GREEN}${BOLD}✓ Cleanup complete!${NC}"
        echo -e "${GREEN}All demo data has been removed. You can run this demo again.${NC}"
    fi
    
    # Also check if product was removed from catalogue
    echo
    echo -e "${CYAN}Verifying catalogue cleanup...${NC}"
    echo -e "${GREEN}Run this command to confirm the product is gone:${NC}"
    echo
    echo -e "${BOLD}curl ${BASE_URL}/catalogue-service/api/catalogue/${PRODUCT_ID} | jq .${NC}"
    echo
    echo -e "${CYAN}Expected: Product should no longer exist in the catalogue${NC}"
else
    echo
    echo -e "${YELLOW}Skipping cleanup. Demo data will remain in the system.${NC}"
    echo -e "${YELLOW}You can manually delete the entities later if needed.${NC}"
fi

echo
echo -e "${CYAN}${BOLD}Demo script finished. Thank you for exploring Drasi!${NC}"
echo