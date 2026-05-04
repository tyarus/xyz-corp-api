#!/bin/bash
# Simple Docker entrypoint for Railway deployment

# Set PORT if not already set (Railway sets this automatically)
PORT="${PORT:-8080}"

# Log startup info
echo "[ENTRYPOINT] PORT is set to: $PORT"
echo "[ENTRYPOINT] PYTHONUNBUFFERED: ${PYTHONUNBUFFERED:-not set}"
echo "[ENTRYPOINT] Starting gunicorn..."

# Run gunicorn with the config file
# The config file will read PORT from the environment
exec gunicorn -c gunicorn.conf.py app:app
