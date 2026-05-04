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
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Copy requirements
COPY requirements.txt .

# Install Python dependencies with verbose output
RUN pip install --upgrade pip setuptools && \
    pip install -r requirements.txt && \
    python -c "import psutil; print('✓ psutil installed')" || echo "Warning: psutil not found"

# Copy application files
COPY app.py gunicorn.conf.py ./
COPY entrypoint.sh ./
COPY templates ./templates
COPY configs ./configs

# Make entrypoint executable
RUN chmod +x /app/entrypoint.sh

# Create data directory for database
RUN mkdir -p /app/data /app/logs && \
    chmod 755 /app/data /app/logs

# Expose port (Railway will map to external port)
EXPOSE 8080

# Health check with longer startup time for Railway
HEALTHCHECK --interval=30s --timeout=10s --start-period=90s --retries=5 \
    CMD curl -f http://localhost:${PORT:-8080}/api/health || exit 1

# Run entrypoint script
ENTRYPOINT ["/app/entrypoint.sh"]
