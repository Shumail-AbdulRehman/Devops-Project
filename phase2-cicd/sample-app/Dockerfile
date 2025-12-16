# Multi-stage Dockerfile for Node.js Application
# Optimized for production deployment with security scanning

# Stage 1: Build stage
FROM node:18-alpine AS builder

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci --only=production && \
    npm cache clean --force

# Copy application code
COPY . .

# Stage 2: Production stage
FROM node:18-alpine

# Add metadata
LABEL maintainer="devops@example.com"
LABEL version="1.0.0"
LABEL description="DevOps Multi-Cloud Sample Application"

# Create non-root user
RUN addgroup -g 1000 appgroup && \
    adduser -D -u 1000 -G appgroup appuser

# Set working directory
WORKDIR /app

# Copy dependencies and application from builder
COPY --from=builder --chown=appuser:appgroup /app/node_modules ./node_modules
COPY --chown=appuser:appgroup . .

# Install dumb-init for proper signal handling
RUN apk add --no-cache dumb-init

# Set environment variables
ENV NODE_ENV=production \
    PORT=3000

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD node -e "require('http').get('http://localhost:3000/health', (r) => {process.exit(r.statusCode === 200 ? 0 : 1)})"

# Use dumb-init to handle signals properly
ENTRYPOINT ["dumb-init", "--"]

# Start application
CMD ["node", "app.js"]
