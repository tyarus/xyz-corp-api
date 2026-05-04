FROM python:3.11-slim

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PORT=8080

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
COPY templates ./templates
COPY configs ./configs

# Create necessary directories with proper permissions
RUN mkdir -p /app/logs /app/data && \
    chmod -R 755 /app/logs /app/data

# Expose dynamic port (Railway will override)
EXPOSE 8080

# Health check with longer startup time for Railway
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=5 \
    CMD curl -f http://localhost:${PORT:-8080}/api/health || exit 1

# Run application with explicit port binding
CMD ["gunicorn", \
     "--bind", "0.0.0.0:${PORT:-8080}", \
     "--workers", "${GUNICORN_WORKERS:-4}", \
     "--worker-class", "sync", \
     "--timeout", "${GUNICORN_TIMEOUT:-120}", \
     "--access-logfile", "-", \
     "--error-logfile", "-", \
     "--log-level", "${GUNICORN_LOG_LEVEL:-info}", \
     "app:app"]
