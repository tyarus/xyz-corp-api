FROM python:3.11-slim

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    sqlite3 \
    nginx \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application
COPY app.py gunicorn.conf.py ./
COPY templates ./templates
COPY configs ./configs
COPY docker-entrypoint.sh ./

# Create required directories and remove default nginx site
RUN mkdir -p /app/data /app/logs \
    && rm -f /etc/nginx/sites-enabled/default \
    && rm -f /etc/nginx/conf.d/default.conf

# Make entrypoint executable
RUN chmod +x /app/docker-entrypoint.sh

# EXPOSE port
EXPOSE 8080

# Set PORT to default (Railway will override)
ENV PORT=8080

# Use entrypoint script to ensure PORT is set
ENTRYPOINT ["/app/docker-entrypoint.sh"]
