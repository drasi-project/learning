# Drasi Learning Scripts - Quick Reference

## User Types and Their Scripts

### 1. Tutorial Users (Own Kubernetes Cluster)
**Goal**: Set up tutorials on their existing Kubernetes cluster

| Script | Location | Purpose |
|--------|----------|---------|
| `setup-tutorial.sh` | `/tutorial/curbside-pickup/` | Interactive setup for Curbside Pickup tutorial |
| `setup-tutorial.sh` | `/tutorial/building-comfort/` | Interactive setup for Building Comfort tutorial |

**Usage**: 
```bash
cd tutorial/curbside-pickup
./setup-tutorial.sh
```

### 2. Developers (DevContainer/Codespace)
**Goal**: Develop and test changes locally

| Script | Location | Purpose |
|--------|----------|---------|
| `dev-reload.sh` | `/tutorial/*/` | Build and deploy local changes |
| `reset-images.sh` | `/tutorial/*/` | Reset to official images |

**Usage**:
```bash
# Test your changes
./dev-reload.sh retail-ops

# Reset when done
./reset-images.sh retail-ops
```

### 3. Maintainers
**Goal**: Build and publish official images

| Script | Location | Purpose |
|--------|----------|---------|
| `build-and-push-tutorial.sh` | `/scripts/` | Build and push images to GHCR |

**Usage**:
```bash
cd scripts
./build-and-push-tutorial.sh curbside-pickup v1.0.0
```

## Script Dependencies

```
setup-tutorial.sh (in each tutorial)
    └── setup-functions.sh (shared library)
        ├── kubectl installation
        ├── Traefik installation
        ├── Drasi CLI installation
        └── Drasi initialization
```

## Environment Support

| Environment | Pre-configured | Scripts Available |
|-------------|----------------|-------------------|
| DevContainer | ✅ k3d cluster, Drasi | dev-reload.sh, reset-images.sh |
| Codespace | ✅ k3d cluster, Drasi | dev-reload.sh, reset-images.sh |
| Own Cluster | ❌ User configures | setup-tutorial.sh |

## Common Workflows

### First-time Tutorial User
1. `git clone` the repository
2. `cd tutorial/<tutorial-name>`
3. `./setup-tutorial.sh`
4. Follow prompts to install dependencies
5. Deploy Drasi resources manually

### Developer Making Changes
1. Open in DevContainer/Codespace
2. Edit code
3. `./dev-reload.sh <app-name>`
4. Test changes
5. `./reset-images.sh <app-name>` when done

### Maintainer Publishing Release
1. `cd scripts`
2. `./build-and-push-tutorial.sh <tutorial> <tag>`
3. Images automatically pushed to GHCR