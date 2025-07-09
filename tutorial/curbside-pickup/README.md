# Curbside Pickup Tutorial

This tutorial demonstrates Drasi's ability to correlate changes across multiple databases in a real-time curbside pickup scenario.

You'll see Drasi in action where:
- **Retail Operations** manages customer orders (PostgreSQL)
- **Physical Operations** tracks vehicle arrivals at curbside (MySQL)
- Changes from both systems are observed by **Drasi**
- **Dashboards** display order readiness and delays in real-time via SignalR

Follow along the tutorial instructions on [our website here](https://drasi.io/tutorials/curbside-pickup/).

![Architecture of the setup including a retail-ops app for managing orders in PostgreSQL and physical-ops app for managing vehicles in MySQL. Two realtime dashboards built using Drasi that can detect complex conditions across databases and different services.](images/curbside-pickup-architecture.png "Curbside Pickup Tutorial Setup")

The setup includes:
- PostgreSQL database for retail/order data
- MySQL database for vehicle/location data
- Retail Operations app (React + Python API)
- Physical Operations app (React + Python API)
- Delivery Dashboard (React + SignalR)
- Delay Dashboard (Vue.js + SignalR)
- Drasi platform with cross-database queries
- Demo page showing all apps in a grid

## Setup in GitHub Codespaces

1. Open this repository in GitHub Codespaces
2. Wait for automatic setup to complete (~5 minutes)
3. When port 80 notification appears, click "Open in Browser"
4. Access the applications via the forwarded URL:
   - Demo (All Apps): `https://<your-codespace-url>/`
   - Physical Operations: `https://<your-codespace-url>/physical-ops`
   - Retail Operations: `https://<your-codespace-url>/retail-ops`
   - Delivery Dashboard: `https://<your-codespace-url>/delivery-dashboard`
   - Delay Dashboard: `https://<your-codespace-url>/delay-dashboard`
   - Physical Operations API Docs: `https://<your-codespace-url>/physical-ops/docs`
   - Retail Operations API Docs: `https://<your-codespace-url>/retail-ops/docs`

### Pre-configured for you:
- k3d cluster with Traefik ingress
- Drasi platform installed
- PostgreSQL and MySQL databases deployed and populated
- All applications running

### Troubleshooting:
- Check the **PORTS** tab in VS Code to see forwarded ports
- Ensure port 80 shows as forwarded
- The URL format is: `https://<codespace-name>-80.app.github.dev`
- If using HTTPS URLs doesn't work, try the HTTP version
- Make sure the port visibility is set to "Public" if sharing the URL

## Setup in VS Code Dev Container

1. Prerequisites:
   - Docker Desktop
   - VS Code with Dev Containers extension

2. Steps:
   - Open VS Code
   - Open this folder: `tutorial/curbside-pickup`
   - Click "Reopen in Container" when prompted
   - Wait for setup to complete (~5 minutes)
   - Access applications at:
     - Demo (All Apps): http://localhost/
     - Physical Operations: http://localhost/physical-ops
     - Retail Operations: http://localhost/retail-ops
     - Delivery Dashboard: http://localhost/delivery-dashboard
     - Delay Dashboard: http://localhost/delay-dashboard
     - Physical Operations API Docs: http://localhost/physical-ops/docs
     - Retail Operations API Docs: http://localhost/retail-ops/docs

### Pre-configured for you:
- k3d cluster with Traefik ingress
- Drasi platform installed
- PostgreSQL and MySQL databases deployed and populated
- All applications running

### Troubleshooting:
- Check the **PORTS** tab in VS Code to verify port 80 is forwarded
- If not accessible, manually forward port 80 in the PORTS tab
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

1. **IMPORTANT: Create a k3d cluster FIRST**
   
   The setup script requires a running Kubernetes cluster:
   ```bash
   # Create k3d cluster with port mapping
   k3d cluster create drasi-tutorial -p 8123:80@loadbalancer
   
   # Verify kubectl can connect (should show cluster info)
   kubectl cluster-info
   ```
   
   **Note**: This creates a cluster with Traefik v2.x included.

2. Run the setup script:
   ```bash
   cd tutorial/curbside-pickup
   ./scripts/setup-tutorial.sh     # Mac/Linux
   ./scripts/setup-tutorial.ps1    # Windows (PowerShell)
   ```

3. Follow the prompts:
   - The script will check prerequisites
   - Initialize Drasi if not already installed (requires confirmation)
   - Deploy PostgreSQL and MySQL databases
   - Deploy all applications

4. Access applications:
   - Demo (All Apps): http://localhost:8123/
   - Physical Operations: http://localhost:8123/physical-ops
   - Retail Operations: http://localhost:8123/retail-ops
   - Delivery Dashboard: http://localhost:8123/delivery-dashboard
   - Delay Dashboard: http://localhost:8123/delay-dashboard
   - Physical Operations API Docs: http://localhost:8123/physical-ops/docs
   - Retail Operations API Docs: http://localhost:8123/retail-ops/docs

### Traefik Compatibility

This tutorial requires **Traefik v2.x** for ingress routing (included with k3d v5.6.0).
- The ingress configurations use `traefik.containo.us` API version
- If you have Traefik v3.x or a different ingress controller, you'll need to adapt the ingress configurations or use port-forwarding

### Cleanup

```bash
./scripts/cleanup-tutorial.sh
```

Follow prompts to remove:
1. Tutorial resources
2. Drasi installation (optional)
3. k3d cluster (optional)

## Development Scripts

For local development and testing changes:

**`./scripts/dev-reload.sh <app-name>`** - Build and deploy your local changes
- Rebuilds the Docker image from your local source code
- Imports it into the k3d cluster
- Updates the deployment to use your custom image
- Changes are visible immediately after rollout completes
- Example: `./scripts/dev-reload.sh retail-ops`
- Available apps: `physical-ops`, `retail-ops`, `delivery-dashboard`, `delay-dashboard`, `demo`

**`./scripts/reset-images.sh <app-name>`** - Revert to official images
- Restores the original pre-built images from GitHub Container Registry
- Use after testing to return to the stable version
- Example: `./scripts/reset-images.sh all`
- Supports resetting individual apps or all at once

**Making Changes:**
1. Edit source code in the app directory (e.g., `retail-ops/`)
2. Run `./scripts/dev-reload.sh retail-ops`
3. Refresh your browser to see changes
4. When done, run `./scripts/reset-images.sh retail-ops` to restore