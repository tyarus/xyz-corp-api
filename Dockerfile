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
    && rm -rf /var/lib/apt/lists/*

# Copy requirements
COPY requirements.txt .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy application
COPY app.py gunicorn.conf.py ./
COPY templates ./templates
COPY configs ./configs

# Create data directory
RUN mkdir -p /app/data /app/logs

# EXPOSE port
EXPOSE 8080

# Start gunicorn with config file
# Health check removed temporarily for debugging
CMD ["gunicorn", "-c", "gunicorn.conf.py", "app:app"]
