#!/bin/bash

# Docker Quick Start Guide for XYZ Corp API

echo "=========================================="
echo "XYZ Corp API - Docker Deployment"
echo "=========================================="

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "Docker is not installed. Installing Docker..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo usermod -aG docker ubuntu
fi

# Check if Docker Compose is installed
if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose is not installed. Installing..."
    sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
fi

# Create logs directory
mkdir -p logs/nginx
chmod 777 logs

echo ""
echo "=========================================="
echo "Building Docker Image"
echo "=========================================="

docker build -t xyz-corp-api:latest .

echo ""
echo "=========================================="
echo "Starting Docker Compose"
echo "=========================================="

docker-compose up -d

echo ""
echo "=========================================="
echo "Checking Services"
echo "=========================================="

sleep 3

echo "Container Status:"
docker-compose ps

echo ""
echo "Testing API:"
curl http://localhost/api/health

echo ""
echo "=========================================="
echo "Docker Setup Complete!"
echo "=========================================="
echo ""
echo "Useful Commands:"
echo "  View logs:        docker-compose logs -f app"
echo "  Restart services: docker-compose restart"
echo "  Stop services:    docker-compose down"
echo "  Shell access:     docker-compose exec app sh"
echo "  Database access:  docker-compose exec app sqlite3 projects.db"
echo ""
echo "Access API at: http://localhost/"
echo ""
