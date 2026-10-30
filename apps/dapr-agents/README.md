# Dapr Agents + Drasi Tutorial

This tutorial demonstrates how Drasi's change-processing capabilities can be used to trigger long-running AI agent workflows built with the Dapr Agents framework.

## What You'll Learn

- How Drasi monitors databases and other sources without impacting service performance
- Generating intelligent business events with the Post Dapr Pub/Sub reaction
- Running complex queries across distributed data in real-time
- How to build resilient AI agents that can consume business events with minimal code

## Setup in GitHub Codespaces

1. Open this repository in GitHub Codespaces
2. Wait for automatic setup to complete (~5 minutes)
3. When port 80 notification appears, click "Open in Browser"
4. Deploy Drasi components:
   ```bash
   drasi apply -f drasi/sources/*
   drasi apply -f drasi/queries/*
   drasi apply -f drasi/reactions/*
   ```
5. Access the applications via the forwarded URL:
   - Workflow Dashboard: `https://<your-codespace>.app.github.dev/`
   - Products API: `https://<your-codespace>.app.github.dev/products-service/products`

### Pre-configured for you:
- k3d cluster with Traefik ingress
- Dapr control plane installed
- Drasi platform installed
- PostgreSQL databases deployed for each service
- Redis deployed for workflow service
- Redis deployed for notifications service
- Workflow service hosting agent workflows
- Diagrid Dashboard for workflow service monitoring
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
   - Open this folder: `apps/dapr-agents`
   - Click "Reopen in Container" when prompted
   - Wait for setup to complete (~5 minutes)
   - Deploy Drasi components:
     ```bash
     drasi apply -f drasi/sources/*
     drasi apply -f drasi/queries/*
     drasi apply -f drasi/reactions/*
     ```
   - Access applications at:
     - Workflow Dashboard: http://localhost:8123/
     - Products API: http://localhost:8123/products-service/products

### Pre-configured for you:
- k3d cluster with Traefik ingress on port 8123
- Dapr control plane installed
- Drasi platform installed
- PostgreSQL databases deployed for each service
- Redis deployed for workflow service
- Redis deployed for notifications service
- Workflow service hosting agent workflows
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
- Dapr CLI >=1.15.0
- Drasi CLI

### Installation Instructions:
- **kubectl**: https://kubernetes.io/docs/tasks/tools/
- **k3d**: https://k3d.io/#installation
- **Dapr CLI**: https://docs.dapr.io/getting-started/install-dapr-cli/
- **Drasi CLI**: https://drasi.io/drasi-kubernetes/reference/command-line-interface/#get-the-drasi-cli

### Setup Steps:

1. **Set your OpenAI configuration** (required for workflow service)
   ```bash
   # Required environment variables:
   export OPENAI_API_KEY=your-api-key
   
   # Optional environment variables (with defaults):
   export OPENAI_ENDPOINT=https://your-api-base-url/ # Default: "https://api.openai.com/v1"
   export OPENAI_MODEL=your-model                    # Default: "gpt-4.1-nano" for Azure, otherwise "gpt-4-turbo"
   export OPENAI_API_TYPE=your-api-type              # Default: "azure" if endpoint contains "azure", otherwise "openai"
   export OPENAI_API_VERSION=your-api-version        # Default: "2025-01-01-preview" for Azure, otherwise "2025-02-15"
   ```

   **For Windows PowerShell:**
   ```powershell
   # Required environment variables:
   $env:OPENAI_API_KEY = "your-api-key" 
   
   # Optional environment variables (with defaults):
   $env:OPENAI_ENDPOINT = "https://your-api-base-url/" # Default: "https://api.openai.com/v1"
   $env:OPENAI_MODEL = "your-model"                    # Default: "gpt-4.1-nano" for Azure, otherwise "gpt-4-turbo"
   $env:OPENAI_API_TYPE = "your-api-type"              # Default: "azure" if endpoint contains "azure", otherwise "openai"
   $env:OPENAI_API_VERSION = "your-api-version"        # Default: "2025-01-01-preview" for Azure, otherwise "2025-02-15"
   ```

2. **Navigate to the apps directory**
   ```bash
   cd apps/dapr-agents
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
   drasi apply -f drasi/sources/*
   drasi apply -f drasi/queries/*
   drasi apply -f drasi/reactions/*
   ```

5. **Access the applications**
   - Workflow Dashboard: http://localhost:8123/
   - Products API: http://localhost:8123/products-service/products

## Running the Demos

After setup is complete and Drasi components are deployed, explore the demo scenarios:

### Demo 1: Pub/Sub-Triggered Agent Workflows
```bash
cd demo
./demo-workflow-service.sh
```

This demo shows:
- Workflow orchestration with Dapr
- State management and persistence
- Event-driven workflow execution through pub/sub messages

## Architecture Overview

### Core Dapr Services
Each service runs with a Dapr sidecar and uses PostgreSQL as its state store:
- **Products Service** (`/products-service`): Manages product inventory

### Drasi Components

#### Sources
Drasi sources monitor the PostgreSQL databases backing the Dapr state stores via logical replication:
- `products-source`: Monitors products database

#### Continuous Queries
Written in Cypher, these queries detect patterns across services:
- `low-stock-event`: Products with stock below a given threshold
- `critical-stock-event`: Products with 0 stock

#### Reactions
- **Post Dapr Pub/Sub**: Publishes intelligent business events

### Drasi-Powered Services
- **Workflow**: Subscribes to Dapr pub/sub events and triggers agent workflows

### Dashboards
- **Workflow Dashboard** (`/`): Monitoring dashboard for the Dapr workflow service

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
- For local setup, ensure you're using http://localhost:8123/ (not https)
- For Codespaces, check the PORTS tab for the correct URL

## Learn More

- **Drasi Documentation**: https://drasi.io
- **Dapr Documentation**: https://docs.dapr.io
- **Tutorial Walkthrough**: https://drasi.io/drasi-kubernetes/tutorials/drasi-for-dapr-agents/