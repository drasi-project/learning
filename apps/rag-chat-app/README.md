# Drasi RAG Demo - Real-time Product Knowledge Base

A demonstration of how Drasi's continuous queries maintain a real-time vector store by joining data from multiple databases, enabling powerful RAG (Retrieval-Augmented Generation) applications.

## Overview

This demo showcases:
- **Multi-Source Integration**: Drasi joins product data from PostgreSQL with customer reviews from MySQL
- **Real-Time Synchronization**: Vector store (Qdrant) stays current without manual intervention
- **Semantic Search**: RAG application finds relevant information using natural language queries
- **Live Updates**: Changes in either database immediately reflect in the AI's knowledge

## Architecture

```
PostgreSQL          MySQL
(Products)       (Reviews)
     │                │
     └────────┬───────┘
              │
         Drasi Query
    (JOIN on product_id)
              │
    Sync Vector Reaction
              │
         Qdrant DB
              │
        RAG Assistant
```

## Prerequisites

1. **Kind cluster with Drasi installed**
   ```bash
   # Create Kind cluster
   kind create cluster --name drasi-demo
   
   # Install Drasi
   drasi init
   ```

2. **Azure OpenAI resources**
   - An Azure OpenAI service instance
   - Deployed models:
     - `gpt-4` (or similar) for chat completion
     - `text-embedding-3-large` for embeddings

3. **Tools installed**
   - kubectl
   - drasi CLI
   - .NET 9.0 SDK (for running the demo app)
   - Docker (for building images)

## Quick Start

### 1. Deploy the Demo

```bash
cd scripts
./deploy.sh
```

The deployment script will:
- Check for an existing `.env` file in the `app/` directory
- If not found, prompt you for Azure OpenAI credentials and create it
- Use the credentials from `.env` for all deployments

### 2. Run the RAG Application

```bash
cd app
dotnet run

# Your credentials are already configured in .env from the deployment
```

## Sample Data

### Products (PostgreSQL)
- **TechPro Laptop X1** - High-performance laptop
- **SmartPhone Pro** - Latest smartphone with AI features
- **AudioMax Pro** - Premium noise-cancelling headphones
- **WorkPad Pro** - Professional tablet
- **FitTrack Ultra** - Fitness smartwatch

### Reviews (MySQL)
Each product has customer reviews with:
- Ratings (1-5 stars)
- Detailed feedback
- Common questions and answers

## Demo Scenarios

### 1. Initial Knowledge Base
Ask the assistant about existing products:
- "What laptop options do you have?"
- "Tell me about customer reviews for the headphones"
- "Which products have the best ratings?"

### 2. Real-Time Updates
Add new data and see immediate updates:

**Add a review (MySQL):**
```sql
mysql -h localhost -P 3306 -u root -pmysql123 feedback_db

INSERT INTO reviews (product_id, customer_name, rating, review_text, common_questions) 
VALUES ('LAPTOP-001', 'New User', 5, 
        'Amazing battery life! Getting 14+ hours easily.',
        'Q: Good for travel? A: Yes, very lightweight');
```

**Update a product (PostgreSQL):**
```sql
psql -h localhost -U postgres -d postgres_db

UPDATE products 
SET price = 1199.99, 
    description = 'High-performance laptop - NOW ON SALE!' 
WHERE id = 'LAPTOP-001';
```

### 3. Complex Queries
The assistant can answer sophisticated questions:
- "Compare the laptop and tablet for creative work"
- "What do customers say about battery life across all products?"
- "Which products under $500 have 5-star reviews?"

## Monitoring

### Check Drasi Components
```bash
# List sources
drasi list source

# List queries
drasi list query

# List reactions
drasi list reaction

# View reaction logs
kubectl logs -n drasi-system -l drasi/reaction=qdrant-product-sync
```

### Check Vector Store
The application includes a "Check vector store status" option to verify:
- Connection to Qdrant
- Collection existence
- Document count

## Architecture Details

### Drasi Query
The continuous query uses Cypher to join products with reviews:
```cypher
MATCH (p:Product)
OPTIONAL MATCH (p)-[:HAS_REVIEW]->(r:Review)
WITH p, 
     COLLECT(DISTINCT r.review_text) as reviews,
     AVG(r.rating) as avg_rating,
     COUNT(r) as review_count
RETURN p.*, reviews, avg_rating, review_count
```

### Vector Store Reaction
The Sync-VectorStore reaction:
- Generates embeddings using Azure OpenAI
- Maintains Qdrant collection with 3072-dimensional vectors
- Handles INSERT, UPDATE, and DELETE operations
- Uses Handlebars templates for document formatting

### RAG Application
The Chat Application:
- Searches Qdrant for relevant documents
- Uses Azure OpenAI for natural language understanding
- Provides context-aware responses with source citations

## Resources

- [Drasi Documentation](https://drasi.io/docs)
- [Semantic Kernel Documentation](https://learn.microsoft.com/semantic-kernel)
- [Qdrant Documentation](https://qdrant.tech/documentation)

## License

This demo is part of the Drasi project and follows the same licensing terms.