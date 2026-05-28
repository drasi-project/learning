# Dapr + Drasi Tutorial

This tutorial demonstrates how Drasi supercharges Dapr applications with real-time data change processing capabilities across multiple microservices. Originally presented at the Dapr Community Call, this scenario showcases three powerful Drasi reactions that solve common challenges in distributed microservice architectures.

You'll see Drasi in action where:
- **Two Dapr microservices** (Products, Orders) manage their own state stores
- **Drasi monitors** all state stores via logical replication with zero impact on services
- **Three Drasi-powered services** demonstrate real-time capabilities:
  - **Notifications**: Intelligent business events via pub/sub
  - **Workflow**: Manages agent-based workflows and long-running processes
  - **Workflow Dashboard**: Comprehensive monitoring dashboard for Dapr workflow service

Follow along the tutorial instructions on [our website here](https://drasi.io/tutorials/dapr/).

![Architecture of the Dapr + Drasi setup showing four core services, Drasi monitoring, and three Drasi-powered services](images/01-architectire-overview.png "Dapr + Drasi Tutorial Setup")

## What You'll Learn

- How Drasi monitors Dapr state stores without impacting service performance
- Building real-time dashboards with SignalR reaction
- Generating intelligent business events with Post Dapr Pub/Sub reaction
- Running complex queries across distributed data in real-time

## Setup in GitHub Codespaces

1. Open this repository in GitHub Codespaces
2. Wait for automatic setup to complete (~5 minutes)
3. When port 80 notification appears, click "Open in Browser"
4. Deploy Drasi components:
   ```bash
   kubectl apply -f drasi/sources/
   kubectl apply -f drasi/queries/
   kubectl apply -f drasi/reactions/
   ```
5. Access the applications via the forwarded URL:
   - Notifications: `https://<your-codespace>.app.github.dev/notifications-service`
   - Workflow: `https://<your-codespace>.app.github.dev/workflow-service`
   - Workflow Dashboard: `https://<your-codespace>.app.github.dev/workflow-dashboard`
   - Products API: `https://<your-codespace>.app.github.dev/products-service/products`
   - Orders API: `https://<your-codespace>.app.github.dev/orders-service/orders`

### Pre-configured for you:
- k3d cluster with Traefik ingress
- Drasi platform installed (includes Dapr)
- PostgreSQL databases deployed for each service
- Redis deployed for workflow service
- Redis deployed for notifications service
- Diagrid Dashboard for service monitoring
- All services running with initial data loaded

### Troubleshooting:
- Check the **PORTS** tab in VS Code to see forwarded ports
- Ensure port 80 shows as forwarded
- The URL format is: `https://<codespace-name>.app.github.dev`
- If using HTTPS URLs doesn't work, try the HTTP version
- Make sure the port visibility is set to "Public" if sharing the URL

## Setup in VS Code Dev Container

1. Prerequisites:
   - Docker Desktop
   - VS Code with Dev Containers extension

2. Steps:
   - Open VS Code
   - Open this folder: `tutorial/dapr`
   - Click "Reopen in Container" when prompted
   - Wait for setup to complete (~5 minutes)
   - Deploy Drasi components:
     ```bash
     kubectl apply -f drasi/sources/
     kubectl apply -f drasi/queries/
     kubectl apply -f drasi/reactions/
     ```
   - Access applications at:
     - Notifications: http://localhost:8123/notifications-service
     - Workflow: http://localhost:8123/workflow-service
     - Workflow Dashboard: http://localhost:8123/workflow-dashboard
     - Products API: http://localhost:8123/products-service/products
     - Orders API: http://localhost:8123/orders-service/orders

### Pre-configured for you:
- k3d cluster with Traefik ingress on port 8123
- Drasi platform installed (includes Dapr)
- PostgreSQL databases deployed for each service
- Redis deployed for workflow service
- Redis deployed for notifications service
- Diagrid Dashboard for service monitoring
- All services running with initial data loaded

### Troubleshooting:
- Check the **PORTS** tab in VS Code to verify port 8123 is forwarded
- If not accessible, manually forward port 8123 in the PORTS tab
- Applications are already running - no need to start them manually
- Logs can be viewed with `kubectl logs deployment/<app-name>`

## Setup your own Local k3d Cluster

### Prerequisites:
- Docker
- kubectl
- k3d
- Drasi CLI

### Installation Instructions:
- **kubectl**: https://kubernetes.io/docs/tasks/tools/
- **k3d**: https://k3d.io/#installation
- **Drasi CLI**: https://drasi.io/reference/command-line-interface/#get-the-drasi-cli

### Setup Steps:

1. **Set your OpenAI configuration** (required for workflow service)
   ```bash
   # Required environment variables:
   export OPENAI_API_KEY=your-api-key
   export OPENAI_ENDPOINT=https://your-api-base-url/
   
   # Optional environment variables (with defaults):
   export OPENAI_MODEL=your-model                    # Default: gpt-4-mini
   export OPENAI_API_TYPE=your-api-type              # Default: azure
   export OPENAI_API_VERSION=your-api-version        # Default: 2025-01-01-preview
   ```

   **For Windows PowerShell:**
   ```powershell
   # Required environment variables:
   $env:OPENAI_API_KEY = "your-api-key"
   $env:OPENAI_ENDPOINT = "https://your-api-base-url/"
   
   # Optional environment variables (with defaults):
   $env:OPENAI_MODEL = "your-model"                    # Default: gpt-4-mini
   $env:OPENAI_API_TYPE = "your-api-type"              # Default: azure
   $env:OPENAI_API_VERSION = "your-api-version"        # Default: 2025-01-01-preview
   ```

2. **Navigate to the tutorial directory**
   ```bash
   cd tutorial/dapr
   ```

3. **Run the setup script**
   ```bash
   # For Linux/Mac:
   ./scripts/setup-tutorial.sh
   
   # For Windows PowerShell:
   ./scripts/setup-tutorial.ps1
   ```

4. **Deploy Drasi components**
   ```bash
   kubectl apply -f drasi/sources/
   kubectl apply -f drasi/queries/
   kubectl apply -f drasi/reactions/
   ```

5. **Access the applications**
   - Notifications: http://localhost:8123/notifications-service
   - Workflow: http://localhost:8123/workflow-service
   - Workflow Dashboard: `http://localhost:8123/workflow-dashboard`
   - Products API: http://localhost:8123/products-service/products
   - Orders API: http://localhost:8123/orders-service/orders

## Running the Demos

After setup is complete and Drasi components are deployed, explore the two demo scenarios:

### Demo 1: Agent Workflows
```bash
cd demo
./demo-workflow-service.sh
```

This demo shows:
- Workflow orchestration with Dapr
- State management and persistence
- Event-driven workflow execution

### Demo 2: Pub/Sub Notifications
```bash
cd demo
./demo-notifications-service.sh
```

This demo shows:
- Event-driven pub/sub messaging
- Real-time notification delivery
- Dapr pub/sub integration

## Architecture Overview

### Core Dapr Services
Each service runs with a Dapr sidecar and uses PostgreSQL as its state store:

- **Products Service** (`/products-service`): Manages product inventory
- **Orders Service** (`/orders-service`): Processes customer orders

### Drasi Components

#### Sources
Drasi sources monitor the PostgreSQL databases backing the Dapr state stores via logical replication:
- `products-source`: Monitors products database
- `orders-source`: Monitors orders database

#### Continuous Queries
Written in Cypher, these queries detect patterns across services:
- `at-risk-orders`: Finds orders that can't be fulfilled
- `low-stock-event`: Products below 20 units
- `critical-stock-event`: Products below 5 units

#### Reactions
- **SignalR**: Powers real-time dashboard updates
- **Post Dapr Pub/Sub**: Publishes intelligent business events

### Drasi-Powered Services

- **Notifications** (`/notifications-service`): Subscribes to Dapr pub/sub events
- **Workflow** (`/workflow-service`): Manages agent-based workflows and long-running processes
- **Workflow Dashboard** (`/workflow-dashboard`): Monitoring dashboard powered by Diagrid for Dapr workflow service

## Utility Scripts

### Reload Services (Pull Latest Images)
```bash
# Linux/Mac:
./scripts/dev-reload.sh

# Windows PowerShell:
./scripts/dev-reload.ps1
```

### Reset Images (Force Fresh Pull)
```bash
# Linux/Mac:
./scripts/reset-images.sh

# Windows PowerShell:
./scripts/reset-images.ps1
```

### Complete Cleanup
```bash
# Linux/Mac:
./scripts/cleanup-tutorial.sh

# Windows PowerShell:
./scripts/cleanup-tutorial.ps1
```

## Troubleshooting

### Check Service Status
```bash
kubectl get pods
kubectl get deployments
```

### View Drasi Components
```bash
drasi list sources
drasi list queries
drasi list reactions
```

### Common Issues

**Services not accessible:**
- Check if k3d cluster is running: `k3d cluster list`
- Verify services are healthy: `kubectl get pods`
- For local setup, ensure you're using http://localhost:8123 (not https)
- For Codespaces, check the PORTS tab for the correct URL

**Workflow Dashboard not loading:**
- Check if the deployment is running: `kubectl get pods -l app=workflow-dashboard`
- Check logs: `kubectl logs deployment/workflow-dashboard`
- Verify service account permissions: `kubectl get clusterrole workflow-dashboard`
- For API token errors, the dashboard works in read-only mode without authentication

## Learn More

- **Drasi Documentation**: https://drasi.io
- **Dapr Documentation**: https://docs.dapr.io
- **Tutorial Walkthrough**: https://drasi.io/tutorials/dapr/
- **Dapr Community Call Recording**: [Watch on YouTube](https://www.youtube.com/watch?v=S-ImhYfLplM&t=90s)