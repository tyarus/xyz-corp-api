import os


def resolve_port(default="5000"):
    raw_port = os.getenv("PORT", default).strip()
    try:
        parsed = int(raw_port)
        if 1 <= parsed <= 65535:
            return str(parsed)
    except ValueError:
        pass
    return default


bind = f"0.0.0.0:{resolve_port()}"
workers = int(os.getenv("GUNICORN_WORKERS", "4"))
worker_class = "sync"
timeout = int(os.getenv("GUNICORN_TIMEOUT", "120"))
accesslog = "-"
errorlog = "-"
loglevel = os.getenv("GUNICORN_LOG_LEVEL", "info")
capture_output = True
