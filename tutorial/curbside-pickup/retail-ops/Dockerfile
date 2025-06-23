# Multi-stage Dockerfile for Retail Ops application

# Stage 1: Build frontend
FROM node:18-alpine AS frontend-builder
WORKDIR /app/frontend
COPY frontend/package*.json ./
RUN npm ci
COPY frontend/ ./
# Build with base path for routing
ENV VITE_BASE_URL=/retail-ops
RUN npm run build

# Stage 2: Python backend with static files
FROM python:3.12-slim

# Set working directory
WORKDIR /app

# Copy backend requirements and install
COPY backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy backend code
COPY backend/ ./

# Copy frontend build from previous stage
COPY --from=frontend-builder /app/frontend/dist ./static

# Expose port 8000
EXPOSE 8000

# Run FastAPI with uvicorn
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]