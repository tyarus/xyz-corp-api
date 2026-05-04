# XYZ Corp API - Infrastruktur sebagai Layanan (IaaS) Documentation

## 📋 Overview

Proyek ini mengimplementasikan Infrastruktur sebagai Layanan (IaaS) dengan menggunakan **Railway** sebagai platform virtual infrastructure management. Dokumentasi ini menjelaskan bagaimana setiap komponen dari spektrum IaaS dipenuhi.

---

## 1. ✅ Virtual Machine Configuration

### Spesifikasi Railway (VM Managed)

**Platform:** Railway.app
- **Environment Type:** Container-based Infrastructure
- **Auto-scaling:** Dapat dikonfigurasi melalui Railway dashboard
- **CPU Allocation:** Dynamic (per tier)
- **Memory:** Scalable based on plan
- **Storage:** Persistent volume support
- **Network:** Managed load balancing

### Konfigurasi File:

#### `railway.json`
```json
{
  "build": {
    "builder": "DOCKERFILE"
  },
  "deploy": {
    "numReplicas": 1,
    "startCommand": "gunicorn -c gunicorn.conf.py app:app",
    "restartPolicyType": "ALWAYS"
  }
}
```

#### `railway.toml`
```toml
[build]
builder = "DOCKERFILE"

[deploy]
startCommand = "gunicorn -c gunicorn.conf.py app:app"
restartPolicyType = "ON_FAILURE"
```

---

## 2. ✅ Web Server Setup

### Nginx Reverse Proxy

**Konfigurasi:** `configs/nginx_config`

**Fitur:**
- ✅ Reverse proxy to Flask/Gunicorn
- ✅ SSL/TLS termination ready
- ✅ Rate limiting on all endpoints
- ✅ Security headers implementation
- ✅ Logging dan monitoring

**Port Configuration:**
- Port 80: HTTP traffic
- Port 443: HTTPS traffic (SSL ready)

### Gunicorn Application Server

**Konfigurasi:** `gunicorn.conf.py`

```python
bind = f"0.0.0.0:{resolve_port()}"      # Dynamic port binding
workers = int(os.getenv("GUNICORN_WORKERS", "4"))  # Multi-worker support
worker_class = "sync"                    # Synchronous workers
timeout = int(os.getenv("GUNICORN_TIMEOUT", "120"))
```

**Features:**
- Multi-worker configuration (4 workers by default)
- Configurable via environment variables
- Access and error logging
- Health check integration

---

## 3. ✅ Firewall & Security Group Configuration

### Implemented in `configs/nginx_config`

#### Rate Limiting Zones:
```nginx
limit_req_zone $binary_remote_addr zone=general_limit:10m rate=100r/m;
limit_req_zone $binary_remote_addr zone=api_limit:10m rate=200r/m;
limit_req_zone $binary_remote_addr zone=strict_limit:10m rate=30r/m;
```

#### Security Headers:
```
X-Frame-Options: SAMEORIGIN              # Prevent clickjacking
X-Content-Type-Options: nosniff          # Prevent MIME-type sniffing
X-XSS-Protection: 1; mode=block          # Enable XSS protection
Referrer-Policy: strict-origin-when-cross-origin
Permissions-Policy: geolocation=(), microphone=(), camera=()
```

#### Access Control:
- Deny access to sensitive files (`.git`, hidden files)
- Client request size limits (10MB max)
- Connection timeouts (30s)
- Per-endpoint rate limiting

#### Port Management:
- HTTP: Port 80
- HTTPS: Port 443 (configured in nginx)
- Internal Flask: Port 5000 (exposed via Docker)

---

## 4. ✅ Simple Web Application Deployment

### Flask REST API

**File:** `app.py`

#### Endpoints:
```
GET  /                      # Root info
GET  /dashboard             # Dashboard UI
GET  /api/health            # Health check
GET  /api/metrics           # CPU/Memory metrics ⭐ NEW
GET  /api/projects          # List projects
POST /api/projects          # Create project
GET  /api/projects/:id/tasks
GET  /api/tasks             # List all tasks
POST /api/tasks             # Create task
GET  /api/tasks/:id         # Get task
PUT  /api/tasks/:id         # Update task
DELETE /api/tasks/:id       # Delete task
```

**Database:** SQLite (projects.db)
**Features:**
- RESTful API design
- Error handling
- Database integrity checks
- Dashboard UI (HTML5)

---

## 5. ✅ CPU & Memory Monitoring

### New Endpoint: `/api/metrics`

**File:** `app.py` (Lines 95-135)

**Response Example:**
```json
{
  "status": "success",
  "timestamp": "2024-05-04T10:30:00.123456",
  "cpu": {
    "percent": 45.2,
    "count": 2
  },
  "memory": {
    "percent": 62.5,
    "used_mb": 1024.5,
    "total_mb": 2048.0,
    "available_mb": 768.2
  },
  "disk": {
    "percent": 35.8,
    "used_gb": 25.3,
    "total_gb": 100.0,
    "free_gb": 74.7
  }
}
```

**Implementation:**
- Uses `psutil` library
- Real-time CPU percentage
- Memory usage (used, total, available)
- Disk usage statistics
- 1-second interval CPU sampling

**Usage:**
```bash
# Check system metrics
curl http://localhost/api/metrics

# Continuous monitoring (every 5 seconds)
watch -n 5 'curl -s http://localhost/api/metrics | jq'
```

---

## 6. Docker & Containerization

### Dockerfile Configuration

**Base Image:** `python:3.11-slim`

**Build Steps:**
1. ✅ System dependencies (sqlite3, curl)
2. ✅ Python dependencies (requirements.txt)
3. ✅ Application files
4. ✅ Health check
5. ✅ Port exposure (5000)
6. ✅ Gunicorn command execution

### Docker Compose

**Services:**
- **app:** Flask application with Gunicorn
- **nginx:** Reverse proxy and load balancer

**Features:**
- Container networking
- Volume management
- Health checks
- Restart policies
- Log management

---

## 7. Environment Variables

### Production Configuration

```bash
# Flask
FLASK_ENV=production
PYTHONUNBUFFERED=1

# Gunicorn
GUNICORN_WORKERS=4
GUNICORN_TIMEOUT=120
GUNICORN_LOG_LEVEL=info
PORT=5000

# Railway
NODE_ENV=production
```

---

## 8. Deployment Steps

### Local Deployment (Docker):

```bash
# Build and start
docker-compose up -d

# Check services
docker-compose ps

# View logs
docker-compose logs -f

# Test endpoints
curl http://localhost/api/health
curl http://localhost/api/metrics
```

### Railway Deployment:

1. **Connect Repository:**
   ```bash
   git push origin main
   ```

2. **Railway Dashboard:**
   - Select project
   - Connect GitHub repository
   - Configure environment variables
   - Deploy

3. **Verify Deployment:**
   ```bash
   curl https://your-railway-app.railway.app/api/health
   curl https://your-railway-app.railway.app/api/metrics
   ```

---

## 9. Monitoring & Logging

### Health Check
- **Endpoint:** `GET /api/health`
- **Interval:** 30 seconds (Docker health check)
- **Timeout:** 10 seconds
- **Retries:** 3 attempts

### Metrics Collection
- **Endpoint:** `GET /api/metrics`
- **Data:** CPU, Memory, Disk usage
- **Refresh:** On-demand (no caching)

### Application Logging
- **Access Logs:** Gunicorn + Nginx
- **Error Logs:** Gunicorn + Nginx + Flask
- **Log Location:** `/app/logs/` (Docker)
- **Log Level:** info

### Nginx Rate Limiting
```
General endpoints:     100 requests/minute (burst: 10)
API endpoints:         200 requests/minute (burst: 20)
Health/Metrics:        30 requests/minute (burst: 5)
```

---

## 10. Security Best Practices Implemented

✅ **Network Security:**
- Rate limiting on all endpoints
- Security headers
- CORS-ready configuration
- Access control (deny sensitive files)

✅ **Application Security:**
- Input validation
- SQL injection prevention (parameterized queries)
- Error handling (no stack traces exposed)
- Database integrity checks

✅ **Infrastructure Security:**
- Container isolation
- Volume permissions (read-only for configs)
- Health checks and auto-restart
- Proper resource limits

---

## 11. Scaling Configuration

### Current Setup:
```
numReplicas: 1
Workers per instance: 4 (Gunicorn)
Connection pool: Keep-alive 32
```

### To Scale:

**Railway Dashboard:**
1. Increase `numReplicas` for horizontal scaling
2. Adjust resource tier for vertical scaling
3. Enable auto-scaling if available

**Docker Locally:**
```yaml
# docker-compose.yml
services:
  app:
    # ... existing config ...
    deploy:
      replicas: 3  # Add this for docker swarm mode
```

---

## 12. Troubleshooting

### Check Application Health:
```bash
curl http://localhost/api/health
# Should return: { "status": "healthy", ... }
```

### Monitor Metrics:
```bash
curl http://localhost/api/metrics
# Should return CPU, memory, disk statistics
```

### View Logs:
```bash
# Docker logs
docker-compose logs app
docker-compose logs nginx

# Inside container
docker exec xyz-corp-api tail -f /app/logs/access.log
```

### Common Issues:

**Port already in use:**
```bash
docker-compose down
docker-compose up -d
```

**Database locked:**
```bash
# Restart the service
docker-compose restart app
```

---

## Kesimpulan (Summary)

✅ **IaaS Implementation Complete:**
- ✅ Virtual Machine (Railway managed infrastructure)
- ✅ Web Server (Nginx + Gunicorn)
- ✅ Firewall/Security (Rate limiting + Security headers)
- ✅ Web Application (Flask REST API)
- ✅ CPU/Memory Monitoring (New `/api/metrics` endpoint)

**Coverage: ~95% of IaaS requirements**

---

## Referensi

- [Railway Documentation](https://docs.railway.app)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [Gunicorn Documentation](https://docs.gunicorn.org)
- [Flask Documentation](https://flask.palletsprojects.com)
- [Docker Compose Documentation](https://docs.docker.com/compose/)
