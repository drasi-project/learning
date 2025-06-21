# Drasi Learning Repository Maintainer Scripts

This directory contains scripts for Drasi maintainers to build and publish Docker images for the tutorial applications.

## Prerequisites

- Docker with buildx support
- Write access to ghcr.io/drasi-project/learning repository
- Docker logged in to ghcr.io

## Scripts

### build-and-push-tutorial.sh
Unified script to build and push all Docker images for a specific tutorial.

**Usage:**
```bash
./build-and-push-tutorial.sh <tutorial-name> [tag]
```

**Examples:**
```bash
# Build with latest tag (default)
./build-and-push-tutorial.sh curbside-pickup

# Build with specific tag
./build-and-push-tutorial.sh building-comfort v1.0.0
```

**Available tutorials:**
- `curbside-pickup` - Builds 5 images: demo, physical-ops, retail-ops, delivery-dashboard, delay-dashboard
- `building-comfort` - Builds 3 images: control-panel, dashboard, demo

**Features:**
- Automatically handles missing package-lock.json files
- Builds for both linux/amd64 and linux/arm64 platforms
- Configurable image tags (defaults to `latest`)
- Validates tutorial names and paths
- Exits on first error

## Automated Builds

These scripts are also used by GitHub Actions workflows for automated builds. See `.github/workflows/build-tutorial-images.yml` for details.

## Shared Functions

### setup-functions.sh
A library of shared functions used by tutorial setup scripts. This includes:
- User interaction functions (colored output, prompts)
- Dependency checking (kubectl, Traefik, Drasi CLI)
- Kubernetes operations (resource checks, deployment waiting)
- Common setup operations (cluster connectivity, Drasi initialization)

This file is sourced by the `setup-tutorial.sh` scripts in each tutorial directory.

## For Developers

If you're looking for development scripts, see:
- **Setup on your own cluster**: `/tutorial/*/setup-tutorial.sh`
- **Local development reload**: `/tutorial/*/dev-reload.sh`
- **Reset to official images**: `/tutorial/*/reset-images.sh`