#!/bin/bash
# Entrypoint script for Railway deployment
# Handles startup, logging, and error handling

set -e

echo "================================================"
echo "🚀 Starting XYZ Corp API Application"
echo "================================================"
echo ""

# Show environment
echo "[INFO] Environment Configuration:"
echo "  PORT: ${PORT:-8080}"
echo "  FLASK_ENV: ${FLASK_ENV:-production}"
echo "  PYTHONUNBUFFERED: ${PYTHONUNBUFFERED:-1}"
echo "  GUNICORN_WORKERS: ${GUNICORN_WORKERS:-4}"
echo "  GUNICORN_TIMEOUT: ${GUNICORN_TIMEOUT:-120}"
echo ""

# Create data directory
echo "[INFO] Creating data directories..."
mkdir -p /app/data /app/logs
chmod 755 /app/data /app/logs
echo "[INFO] ✓ Data directories ready"
echo ""

# Test imports
echo "[INFO] Testing Python imports..."
python3 << 'EOF'
try:
    import flask
    print(f"  ✓ Flask {flask.__version__}")
except ImportError as e:
    print(f"  ✗ Flask import failed: {e}")
    exit(1)

try:
    import gunicorn
    print(f"  ✓ Gunicorn")
except ImportError as e:
    print(f"  ✗ Gunicorn import failed: {e}")
    exit(1)

try:
    import psutil
    print(f"  ✓ psutil {psutil.__version__}")
except ImportError as e:
    print(f"  ✗ psutil import failed: {e}")
    exit(1)

try:
    from app import app
    print(f"  ✓ Flask app loaded successfully")
except Exception as e:
    print(f"  ✗ App import failed: {e}")
    exit(1)
EOF

if [ $? -ne 0 ]; then
    echo "[ERROR] Import test failed!"
    exit 1
fi

echo ""
echo "[INFO] ✓ All imports successful"
echo ""

# Show database status
echo "[INFO] Database Status:"
if [ -f "/app/data/projects.db" ]; then
    echo "  ✓ Database file exists"
else
    echo "  ⚠ Database file will be created on first run"
fi
echo ""

# Show gunicorn config
echo "[INFO] Gunicorn Configuration:"
echo "  Config file: gunicorn.conf.py"
echo "  Workers: ${GUNICORN_WORKERS:-4}"
echo "  Timeout: ${GUNICORN_TIMEOUT:-120}s"
echo ""

# Start gunicorn
echo "================================================"
echo "[INFO] Starting Gunicorn..."
echo "================================================"
echo ""

exec gunicorn -c gunicorn.conf.py app:app
