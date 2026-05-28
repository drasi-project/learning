# Diagrid Dashboard Service

A dedicated monitoring dashboard for observing Dapr applications and the workflow service in real-time.

## Features

- **Real-time Monitoring**: View live state of all Dapr services
- **Actor Management**: Inspect and manage actor state
- **Component Overview**: Monitor deployed Dapr components
- **Subscription Tracking**: View pub/sub subscriptions and message flow
- **Service Health**: Check health status of all services

## Accessing the Dashboard

### Local Development
- **URL**: http://localhost:8123/workflow-dashboard
- **Port**: 8123 (via Traefik ingress)

### GitHub Codespaces
- **URL**: https://<your-codespace>.app.github.dev/workflow-dashboard

## Features Available

### Workflow Service Monitoring
- View workflow actor states
- Track workflow execution history
- Monitor state store interactions
- Inspect pub/sub messages

### Service Overview
- Products service state
- Orders service state
- Dashboard connectivity
- Notifications service pub/sub topics

### Component Management
- View deployed Dapr components (state stores, pub/sub, etc.)
- Monitor component health
- Track configuration changes

## Integration

The Diagrid dashboard automatically discovers and connects to all Dapr services in the cluster. It uses the Dapr API to gather telemetry and state information.

### Required Permissions

The deployment includes a ServiceAccount and ClusterRole that provides:
- Read access to Kubernetes pods, services, and endpoints
- Read access to Dapr components and subscriptions
- Watch access for real-time updates

## Documentation

For more information about the Diagrid dashboard, visit:
- https://docs.diagrid.io/develop/local-development/dev-dashboard/
- https://docs.diagrid.io/reference/monitoring/

## Troubleshooting

### Dashboard Not Loading

1. Check if the deployment is running:
   ```bash
   kubectl get pods -l app=workflow-dashboard
   ```

2. Check logs:
   ```bash
   kubectl logs deployment/workflow-dashboard
   ```

3. Verify service is accessible:
   ```bash
   kubectl get svc workflow-dashboard
   ```

### Cannot Connect to Services

Ensure all Dapr services are running and have Dapr sidecars enabled:
```bash
kubectl get pods -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.metadata.annotations.dapr\.io\/enabled}{"\n"}{end}'
```

### Port Forwarding Issues

If accessing via port forwarding, ensure:
1. Port 8123 is forwarded in VS Code PORTS tab
2. Traefik ingress is running: `kubectl get deployment traefik -n kube-system`
3. The ingress route is created: `kubectl get ingress workflow-dashboard`
