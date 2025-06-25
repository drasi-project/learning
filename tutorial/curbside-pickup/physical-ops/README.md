# Physical Operations Service

A unified container deployment of the Physical Operations service that includes both the React frontend and FastAPI backend, designed to work with Traefik ingress in k3d.

## Architecture

- **Frontend**: React application for vehicle management UI
- **Backend**: FastAPI service providing RESTful APIs
- **Database**: MySQL with CDC enabled for Drasi integration
- **Routing**: Traefik ingress with path-based routing

## Quick Start

### Prerequisites

- Docker
- k3d cluster with Traefik enabled
- kubectl

### Building the Image

```bash
chmod +x build.sh
./build.sh
```

This script will:
1. Build the Docker image with both frontend and backend
2. Tag it as `physical-ops:latest`
3. Import it to your k3d cluster (if k3d is available)

### Deployment

Deploy MySQL and Physical Ops together:

```bash
kubectl apply -f k8s/
```

This will deploy:
- MySQL database with CDC configuration
- Physical Operations application (frontend + backend)
- Traefik ingress configuration
- All necessary services

### Accessing the Application

Once deployed, the application will be available at:

- **Frontend UI**: http://localhost/physical-ops/
- **API Documentation**: http://localhost/physical-ops/docs
- **API Endpoints**: http://localhost/physical-ops/vehicles

No port forwarding needed - Traefik handles the routing!

## How It Works

1. **Traefik Ingress** receives requests at `/physical-ops/*`
2. **Middleware** strips the `/physical-ops` prefix before forwarding to the service
3. **FastAPI** serves:
   - The React frontend at `/`
   - API endpoints at `/vehicles`
   - Swagger docs at `/docs`
4. **React Frontend** is built with base path `/physical-ops` so all assets load correctly

## Features

### Frontend
- Visual representation of Parking Lot and Curbside zones
- Add new vehicles with details (plate, driver, customer, make, model, color)
- Move vehicles between zones by clicking on them
- Real-time updates when vehicles change location

### Backend API
- **GET /vehicles** - List all vehicles
- **POST /vehicles** - Create a new vehicle
- **PUT /vehicles/{plate}** - Update vehicle location
- **DELETE /vehicles/{plate}** - Remove a vehicle
- **GET /docs** - Interactive API documentation (Swagger UI)

## Environment Variables

The application uses the following environment variables:

- `DATABASE_URL`: MySQL connection string (default: `mysql+pymysql://test:test@mysql:3306/PhysicalOperations`)
- `VITE_BASE_URL`: Frontend base path (set to `/physical-ops` during build)

## Database Schema

The MySQL database includes a single `vehicles` table:

```sql
CREATE TABLE vehicles (
    plate VARCHAR(10) PRIMARY KEY,
    driver_name VARCHAR(50) NOT NULL,
    customer_name VARCHAR(50) NOT NULL,
    make VARCHAR(50) NOT NULL,
    model VARCHAR(50) NOT NULL,
    color VARCHAR(30) NOT NULL,
    location ENUM('Parking', 'Curbside') NOT NULL DEFAULT 'Parking'
);
```

## Development

### Local Development

For local development without Docker:

1. Start MySQL locally or port-forward to the k8s MySQL:
   ```bash
   kubectl port-forward svc/mysql 3306:3306
   ```

2. Start the backend:
   ```bash
   cd backend
   pip install -r requirements.txt
   uvicorn main:app --reload --port 8000
   ```

3. Start the frontend:
   ```bash
   cd frontend
   npm install
   npm run dev
   ```

### Modifying the Application

1. Make changes to frontend or backend code
2. Run `./build.sh` to rebuild the image
3. Delete the existing pod to force a redeploy:
   ```bash
   kubectl delete pod -l app=physical-ops
   ```

## Troubleshooting

### Check Application Logs

```bash
# All logs from the pod
kubectl logs -l app=physical-ops

# Follow logs
kubectl logs -l app=physical-ops -f
```

### Check MySQL Connection

```bash
# Connect to MySQL
kubectl exec -it $(kubectl get pod -l app=mysql -o name) -- mysql -u test -ptest PhysicalOperations

# Check vehicles table
SELECT * FROM vehicles;
```

### Test the Ingress

```bash
# Test frontend
curl http://localhost/physical-ops/

# Test API
curl http://localhost/physical-ops/vehicles

# Test docs
curl http://localhost/physical-ops/docs
```

### Common Issues

1. **404 errors**: Check that Traefik middleware is stripping the prefix correctly
2. **Backend can't connect to MySQL**: Verify the `mysql` service is running and accessible
3. **Static files not loading**: Ensure the frontend was built with the correct base path

## Integration with Drasi

This service is designed to work with Drasi for change detection. The MySQL database is configured with:
- Binary logging enabled
- GTID mode for replication
- Proper permissions for CDC

Drasi can monitor the `vehicles` table for changes and trigger reactions when vehicles move between Parking and Curbside locations.