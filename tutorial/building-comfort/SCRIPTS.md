# Building Comfort Tutorial Scripts

This directory contains several helper scripts for different use cases:

## setup-tutorial.sh
**For: Users setting up on their own Kubernetes cluster**

An interactive setup script that helps you deploy all tutorial components on your existing Kubernetes cluster.

```bash
./setup-tutorial.sh
```

Features:
- Checks and optionally installs dependencies (kubectl, Traefik, Drasi CLI)
- Initializes Drasi on your cluster
- Deploys PostgreSQL database with seed data
- Deploys all tutorial applications
- Interactive prompts at each step (Yes/Skip/Quit)

## dev-reload.sh
**For: Developers in DevContainers/Codespaces**

Rebuilds and deploys your local code changes to the k3d cluster.

```bash
./dev-reload.sh <app-name>
```

Available apps:
- control-panel
- dashboard
- demo

Example:
```bash
# Make changes to control-panel code
./dev-reload.sh control-panel
```

## reset-images.sh
**For: Developers in DevContainers/Codespaces**

Resets deployments back to official GHCR images after using dev-reload.

```bash
# Reset a single app
./reset-images.sh control-panel

# Reset all apps
./reset-images.sh all
```

## Workflow Summary

### For Tutorial Users (Own Cluster)
1. Clone the repository
2. Run `./setup-tutorial.sh`
3. Follow the interactive prompts
4. Deploy Drasi resources from drasi-sources directory

### For Developers (DevContainer/Codespace)
1. Open in DevContainer/Codespace (cluster auto-configured)
2. Make code changes
3. Use `./dev-reload.sh <app>` to test changes
4. Use `./reset-images.sh <app>` to revert

### For Maintainers
See `/scripts/build-and-push-tutorial.sh` for building and publishing official images.