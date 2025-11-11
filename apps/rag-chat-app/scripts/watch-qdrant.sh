watch -n 2 'echo "🔄 QDRANT VECTOR STORE STATUS" && \
echo "================================" && \
if curl -s http://localhost:6333/collections/product_knowledge | grep -q "\"status\":\"ok\""; then \
  echo "✅ Collection: product_knowledge" && \
  curl -s http://localhost:6333/collections/product_knowledge | \
  jq -r "\"📊 Total Points: \(.result.points_count)\"" && \
  echo "" && \
  echo "📝 Latest Updates:" && \
  POINTS=$(curl -s http://localhost:6333/collections/product_knowledge/points/scroll \
    -d "{\"limit\": 10, \"with_payload\": true}" 2>/dev/null | \
  jq -r ".result.points| sort_by(.payload.timestamp) | reverse | .[] | \"  • \(.payload.title)\"" 2>/dev/null) && \
  if [ -z "$POINTS" ]; then \
    echo "  No points yet - waiting for data sync..."; \
  else \
    echo "$POINTS"; \
  fi; \
else \
  echo "❌ Collection: product_knowledge (not found)" && \
  echo "" && \
  echo "Available collections:" && \
  curl -s http://localhost:6333/collections | jq -r ".result.collections[].name" | sed "s/^/  • /" || echo "  None"; \
fi'