# Build stage with Node
FROM node:20-alpine AS builder
WORKDIR /app

# Copy package files
COPY package*.json ./
RUN npm ci --only=production && \
    npm ci --only=development

# Copy source code
COPY . .

# Build with base path for deployment behind ingress
ENV VITE_BASE_URL=/dashboard
RUN npm run build

# Production stage with nginx
FROM nginx:alpine

# Copy custom nginx config
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy built assets from builder
COPY --from=builder /app/dist /usr/share/nginx/html

# Add non-root user and ensure nginx can run properly
RUN adduser -D -g '' appuser && \
    chown -R appuser:appuser /var/cache/nginx && \
    chown -R appuser:appuser /var/log/nginx && \
    chown -R appuser:appuser /etc/nginx/conf.d && \
    touch /var/run/nginx.pid && \
    chown -R appuser:appuser /var/run/nginx.pid && \
    chown -R appuser:appuser /usr/share/nginx/html && \
    chmod -R 755 /usr/share/nginx/html

USER appuser

EXPOSE 8080

# Start nginx
CMD ["nginx", "-g", "daemon off;"]