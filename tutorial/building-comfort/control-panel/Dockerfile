# Build frontend with Vite
FROM node:20-alpine AS frontend-builder
WORKDIR /app
COPY frontend/package*.json ./
RUN npm ci --only=production && \
    npm ci --only=development
COPY frontend/ ./
RUN npm run build

# Build backend with distroless Python
FROM python:3.12-slim AS backend-builder
WORKDIR /app

# Install dependencies in a virtual environment
RUN python -m venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

COPY backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Final stage with distroless
FROM python:3.12-slim
WORKDIR /app

# Copy Python virtual environment from builder
COPY --from=backend-builder /opt/venv /opt/venv
ENV PATH="/opt/venv/bin:$PATH"

# Copy backend code
COPY backend/ .

# Copy built frontend to static folder
COPY --from=frontend-builder /app/dist ./static

# Create non-root user
RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app
USER appuser

# Environment variables
ENV PORT=5000
ENV DATABASE_URL=postgresql://test:test@postgres.default.svc.cluster.local:5432/building-comfort-db

EXPOSE 5000

# Use uvicorn to run FastAPI
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "5000"]