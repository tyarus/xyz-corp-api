# Railway Deployment Guide

## Quick Start - Deploy ke Railway

### Prerequisites
- GitHub account dengan repository ini
- Railway.app account
- Git installed locally

---

## Step 1: Siapkan Repository

```bash
# Clone/navigate to project
cd d:\semester\ 6\komputasi\ awann\uts\XYZ-Corp-API

# Initialize git (if not already)
git init
git add .
git commit -m "Initial commit - IaaS implementation"
git branch -M main
git remote add origin https://github.com/YOUR-USERNAME/XYZ-Corp-API.git
git push -u origin main
```

---

## Step 2: Connect ke Railway

### Option A: Via Web Console

1. **Login ke Railway:** https://railway.app
2. **Create New Project:**
   - Click "New Project"
   - Select "Deploy from GitHub"
   - Authorize GitHub
   - Select repository: `XYZ-Corp-API`

3. **Configure Environment:**
   - Environment variables akan auto-detect dari `railway.json`
   - Tambahkan jika diperlukan:
     ```
     FLASK_ENV=production
     PYTHONUNBUFFERED=1
     GUNICORN_WORKERS=4
     ```

4. **Deploy:**
   - Railway akan auto-build dari Dockerfile
   - Deployment dimulai otomatis
   - Tunggu hingga status "SUCCESS"

### Option B: Via Railway CLI

```bash
# Install Railway CLI
# Windows: Download from https://docs.railway.app/cli/install

# Login
railway login

# Initiate project
railway init

# Deploy
railway up
```

---

## Step 3: Konfigurasi dan Testing

### Get Application URL

```bash
# Via Railway CLI
railway logs --service web

# Atau check di Railway dashboard
# URL format: https://xyz-corp-api-<unique-id>.railway.app
```

### Test Endpoints

```bash
# Replace with your actual Railway URL
RAILWAY_URL="https://your-app.railway.app"

# Health check
curl $RAILWAY_URL/api/health

# Get metrics
curl $RAILWAY_URL/api/metrics

# List projects
curl $RAILWAY_URL/api/projects

# View dashboard
open $RAILWAY_URL/dashboard
```

---

## Step 4: Environment Variables (Railway Dashboard)

Navigate to **Settings → Environment Variables:**

```
FLASK_ENV=production
PYTHONUNBUFFERED=1
GUNICORN_WORKERS=4
GUNICORN_TIMEOUT=120
GUNICORN_LOG_LEVEL=info
PORT=5000
```

---

## Step 5: Monitoring & Maintenance

### View Live Logs

```bash
# Railway CLI
railway logs --follow

# Atau di dashboard: Project → Logs tab
```

### Check Metrics Endpoint

```bash
# Real-time system metrics
curl https://your-app.railway.app/api/metrics | jq

# Continuous monitoring
watch -n 5 'curl -s https://your-app.railway.app/api/metrics | jq'
```

### Monitor Health

```bash
# Check if service is up
watch -n 10 'curl -s https://your-app.railway.app/api/health | jq'
```

---

## Step 6: Scaling Configuration

### Horizontal Scaling (Add Replicas)

1. Go to **Settings → Deploy**
2. Increase **Deploy Count** for multiple instances
3. Nginx akan auto load-balance

### Vertical Scaling (More Resources)

1. Go to **Settings → Instance**
2. Select tier: Free, Developer, Pro, etc.
3. More CPU/Memory akan dialokasikan

---

## Local Testing (Before Deploy)

```bash
# Build Docker image
docker build -t xyz-corp-api .

# Run locally
docker run -p 5000:5000 xyz-corp-api

# Test
curl http://localhost:5000/api/health
curl http://localhost:5000/api/metrics

# Or use docker-compose
docker-compose up -d
curl http://localhost/api/health
```

---

## Troubleshooting

### Application won't start

```bash
# Check logs
railway logs --follow

# Common issues:
# 1. Missing environment variables
# 2. Port conflict
# 3. Database permissions
```

### Metrics not available

```bash
# Ensure psutil is installed
# Check requirements.txt includes: psutil==5.9.6

# Restart service in Railway dashboard
```

### High CPU/Memory usage

```bash
# Check metrics endpoint
curl https://your-app.railway.app/api/metrics

# If persistent:
# 1. Increase instance tier
# 2. Increase GUNICORN_WORKERS
# 3. Review application code for leaks
```

### Database issues

```bash
# SQLite database is persisted in container
# If needed to reset:
# 1. Delete volume in Railway
# 2. Re-deploy (will create fresh database)
```

---

## Rollback Previous Deployment

```bash
# Via Railway CLI
railway rollback <deployment-id>

# Or via dashboard:
# Project → Deployments → Select previous → Redeploy
```

---

## Performance Optimization

### Current Configuration:
- **Workers:** 4 (Gunicorn)
- **Timeout:** 120 seconds
- **Rate Limit:** 100-200 req/min

### If slow:
1. Increase `GUNICORN_WORKERS` (2x CPU cores)
2. Use Railway Pro tier
3. Enable database indexing

### If getting rate limited:
1. Adjust rate limits in `configs/nginx_config`
2. Implement caching (Redis)
3. Scale horizontally

---

## Production Checklist

- [x] Docker build working locally
- [x] Environment variables set
- [x] Health check endpoint responds
- [x] Metrics endpoint responds
- [x] Database initialized
- [x] Nginx security headers configured
- [x] Rate limiting enabled
- [x] Logging configured
- [x] GitHub repository ready
- [x] Railway project created

---

## Useful Commands

```bash
# Railway CLI
railway login                    # Login to Railway
railway init                     # Initialize project
railway up                       # Deploy
railway logs --follow            # View logs
railway logs --service web       # Logs for specific service
railway ps                       # Process status
railway status                   # Project status

# Docker
docker build -t app .           # Build image
docker run -p 5000:5000 app     # Run container
docker-compose up -d            # Start services
docker-compose down             # Stop services
docker-compose logs -f          # View logs

# Curl
curl https://app.railway.app/api/health
curl https://app.railway.app/api/metrics
curl -X POST https://app.railway.app/api/projects \
  -H "Content-Type: application/json" \
  -d '{"name":"Test Project"}'
```

---

## Resources

- Railway Docs: https://docs.railway.app
- CLI Reference: https://docs.railway.app/cli/quick-start
- GitHub Integration: https://docs.railway.app/get-started
- Environment Variables: https://docs.railway.app/develop/environments

---

## Support

Jika ada masalah:
1. Check Railway logs: `railway logs --follow`
2. Verify environment variables
3. Test endpoints locally: `docker-compose up`
4. Review INFRASTRUCTURE.md for configuration details
