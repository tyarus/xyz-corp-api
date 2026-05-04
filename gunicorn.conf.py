import os
import logging


def resolve_port(default="8080"):
    """Resolve port from environment variable (Railway sets PORT=8080)"""
    raw_port = os.getenv("PORT", default).strip()
    try:
        parsed = int(raw_port)
        if 1 <= parsed <= 65535:
            return str(parsed)
    except (ValueError, AttributeError):
        pass
    return default


# Logging setup
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

# Gunicorn Configuration
bind = f"0.0.0.0:{resolve_port()}"
workers = int(os.getenv("GUNICORN_WORKERS", "4"))
worker_class = os.getenv("GUNICORN_WORKER_CLASS", "sync")
timeout = int(os.getenv("GUNICORN_TIMEOUT", "120"))
keepalive = int(os.getenv("GUNICORN_KEEPALIVE", "5"))

# Logging
accesslog = os.getenv("GUNICORN_ACCESS_LOG", "-")
errorlog = os.getenv("GUNICORN_ERROR_LOG", "-")
loglevel = os.getenv("GUNICORN_LOG_LEVEL", "info")
capture_output = True

# Application settings
max_requests = int(os.getenv("GUNICORN_MAX_REQUESTS", "1000"))
max_requests_jitter = int(os.getenv("GUNICORN_MAX_REQUESTS_JITTER", "100"))

# Connection settings
backlog = 2048
