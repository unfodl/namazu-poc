#!/bin/bash

# Namazu Next.js Docker Deployment Script
# This script builds and runs the Namazu Next.js application in Docker

set -e

echo "🚀 Namazu Next.js Docker Deployment"
echo "=================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Docker is running
if ! docker info > /dev/null 2>&1; then
    print_error "Docker is not running. Please start Docker and try again."
    exit 1
fi

# Check if we're in the right directory
if [ ! -f "Dockerfile" ] || [ ! -f "package.json" ]; then
    print_error "Please run this script from the project root directory (where Dockerfile and package.json are located)."
    exit 1
fi

# Stop existing containers
print_status "Stopping existing containers..."
docker-compose down --remove-orphans 2>/dev/null || true

# Remove old images
print_status "Cleaning up old images..."
docker image prune -f > /dev/null 2>&1 || true

# Build the Docker image
print_status "Building Docker image..."
if docker-compose build --no-cache; then
    print_success "Docker image built successfully!"
else
    print_error "Failed to build Docker image."
    exit 1
fi

# Start the application
print_status "Starting Namazu application..."
if docker-compose up -d; then
    print_success "Application started successfully!"
else
    print_error "Failed to start application."
    exit 1
fi

# Wait for the application to be ready
print_status "Waiting for application to be ready..."
sleep 10

# Check if the application is running
if curl -f http://localhost:3000 > /dev/null 2>&1; then
    print_success "Namazu is running at http://localhost:3000"
else
    print_warning "Application might still be starting up. Please wait a moment and check http://localhost:3000"
fi

# Show container status
print_status "Container status:"
docker-compose ps

echo ""
echo "🎉 Deployment complete!"
echo ""
echo "📱 Access your app:"
echo "   - Local: http://localhost:3000"
echo "   - Docker: http://localhost:3000"
echo ""
echo "🔧 Useful commands:"
echo "   - View logs: docker-compose logs -f"
echo "   - Stop app: docker-compose down"
echo "   - Restart: docker-compose restart"
echo "   - Rebuild: docker-compose build --no-cache"
echo ""
echo "📊 Health check: http://localhost:3000/api/health"
