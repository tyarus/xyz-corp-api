#!/bin/bash
# Railway entrypoint:
# - Gunicorn runs on an internal local port
# - Nginx exposes public PORT and applies security/rate limits

set -euo pipefail

PORT="${PORT:-8080}"
GUNICORN_INTERNAL_PORT="${GUNICORN_INTERNAL_PORT:-5000}"
NGINX_TEMPLATE_PATH="/app/configs/nginx_railway.conf.template"
NGINX_TARGET_PATH="/etc/nginx/conf.d/default.conf"

echo "[ENTRYPOINT] PORT(public): $PORT"
echo "[ENTRYPOINT] GUNICORN_INTERNAL_PORT: $GUNICORN_INTERNAL_PORT"
echo "[ENTRYPOINT] Rendering Nginx config from template..."

if [ ! -f "$NGINX_TEMPLATE_PATH" ]; then
  echo "[ENTRYPOINT] Missing template: $NGINX_TEMPLATE_PATH"
  exit 1
fi

sed \
  -e "s/__PORT__/${PORT}/g" \
  -e "s/__UPSTREAM_PORT__/${GUNICORN_INTERNAL_PORT}/g" \
  "$NGINX_TEMPLATE_PATH" > "$NGINX_TARGET_PATH"

echo "[ENTRYPOINT] Validating Nginx config..."
nginx -t

echo "[ENTRYPOINT] Starting Gunicorn..."
gunicorn -c gunicorn.conf.py --bind "127.0.0.1:${GUNICORN_INTERNAL_PORT}" app:app &
GUNICORN_PID=$!

echo "[ENTRYPOINT] Starting Nginx..."
nginx -g "daemon off;" &
NGINX_PID=$!

# If one process exits, stop the other and exit.
wait -n "$GUNICORN_PID" "$NGINX_PID"
EXIT_CODE=$?

echo "[ENTRYPOINT] One service exited. Stopping the other..."
kill -TERM "$GUNICORN_PID" "$NGINX_PID" 2>/dev/null || true
wait "$GUNICORN_PID" "$NGINX_PID" 2>/dev/null || true

exit "$EXIT_CODE"
