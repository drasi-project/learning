# Curbside Pickup Tutorial

This tutorial demonstrates a real-time curbside pickup management system using Drasi for change detection and event processing.

## Quick Start with GitHub Codespaces / DevContainers

1. Open in GitHub Codespaces or VS Code with DevContainers
2. Wait for the environment to set up (takes ~2-3 minutes)
3. Access the applications at:
   - **Demo (All Apps)**: http://localhost/
   - **Physical Operations**: http://localhost/physical-ops
   - **Retail Operations**: http://localhost/retail-ops
   - **Delivery Dashboard**: http://localhost/delivery-dashboard
   - **Delay Dashboard**: http://localhost/delay-dashboard

## Architecture

The system consists of:
- **Physical Operations**: Tracks vehicles entering/leaving the curbside area (Python/FastAPI + MySQL)
- **Retail Operations**: Manages customer orders (Python/FastAPI + PostgreSQL)
- **Delivery Dashboard**: Shows orders ready for handover (React)
- **Delay Dashboard**: Shows orders with significant wait times (Vue.js)
- **Demo**: Combined view of all applications in a 2x2 grid

## Local Development

### Modifying Applications

If you want to modify and test changes to any application:

```bash
# Use the dev-reload script
./dev-reload.sh <app-name>

# Example:
./dev-reload.sh physical-ops
```

Available app names: `physical-ops`, `retail-ops`, `delivery-dashboard`, `delay-dashboard`, `demo`

The script will:
1. Build a local Docker image with your changes
2. Import it to the K3d cluster
3. Update the deployment to use your local image
4. Restart the application

### Manual Deployment

All applications use images from GitHub Container Registry:
- `ghcr.io/drasi-project/learning/curbside-pickup/physical-ops:latest`
- `ghcr.io/drasi-project/learning/curbside-pickup/retail-ops:latest`
- `ghcr.io/drasi-project/learning/curbside-pickup/delivery-dashboard:latest`
- `ghcr.io/drasi-project/learning/curbside-pickup/delay-dashboard:latest`
- `ghcr.io/drasi-project/learning/curbside-pickup/demo:latest`

## Drasi Integration

The system uses Drasi to:
1. Monitor database changes using CDC (Change Data Capture)
2. Execute continuous queries across both databases
3. React to events via SignalR notifications to dashboards

Drasi components:
- Sources: MySQL (Physical Ops) and PostgreSQL (Retail Ops)
- Queries: Delivery readiness and delay detection
- Reactions: SignalR hub for real-time updates