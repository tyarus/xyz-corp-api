# Testing Guide - XYZ Corp API

## Quick Reference for Testing IaaS Implementation

---

## 1. Health Check Endpoint

### Purpose
Verify application is running and database is operational.

### Test
```bash
curl http://localhost/api/health
```

### Expected Response (200 OK)
```json
{
  "status": "healthy",
  "service": "XYZ Corp Project Management API",
  "timestamp": "2024-05-04T10:30:00.123456",
  "database": "operational"
}
```

---

## 2. Metrics Endpoint ⭐ (NEW - FOR IaaS MONITORING)

### Purpose
Monitor CPU, memory, and disk usage - **KEY COMPONENT FOR IaaS**

### Test
```bash
curl http://localhost/api/metrics
```

### Expected Response (200 OK)
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

### Continuous Monitoring
```bash
# Update setiap 5 detik
watch -n 5 'curl -s http://localhost/api/metrics | jq'

# Atau dengan node/npm tools
watch -n 5 'curl -s http://localhost/api/metrics | jq ".memory, .cpu"'
```

---

## 3. Dashboard

### Purpose
Web UI untuk manage projects dan tasks

### Test
```bash
# Open in browser
http://localhost/dashboard

# Or via curl
curl http://localhost/dashboard
```

### Expected
HTML page loaded with project management interface

---

## 4. Projects API

### Get All Projects
```bash
curl http://localhost/api/projects
```

### Create Project
```bash
curl -X POST http://localhost/api/projects \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test Project",
    "description": "Test Description"
  }'
```

### Response
```json
{
  "status": "success",
  "message": "Project created successfully",
  "data": {
    "id": 1,
    "name": "Test Project",
    "description": "Test Description",
    "created_at": "2024-05-04T10:30:00.123456"
  }
}
```

---

## 5. Tasks API

### Create Task
```bash
curl -X POST http://localhost/api/tasks \
  -H "Content-Type: application/json" \
  -d '{
    "project_id": 1,
    "title": "Setup Nginx",
    "status": "todo",
    "assigned_to": "DevOps Team"
  }'
```

### Get All Tasks
```bash
curl http://localhost/api/tasks
```

### Get Project Tasks
```bash
curl http://localhost/api/projects/1/tasks
```

### Update Task
```bash
curl -X PUT http://localhost/api/tasks/1 \
  -H "Content-Type: application/json" \
  -d '{
    "status": "in-progress",
    "assigned_to": "DevOps Lead"
  }'
```

### Delete Task
```bash
curl -X DELETE http://localhost/api/tasks/1
```

---

## Local Testing Setup

### Start Services

#### Using Docker Compose:
```bash
# Build and start
docker-compose up -d

# Verify containers running
docker-compose ps

# Check logs
docker-compose logs -f
```

#### Manual Docker:
```bash
# Build image
docker build -t xyz-corp-api .

# Run Flask app
docker run -d -p 5000:5000 --name app xyz-corp-api

# Run Nginx (separate)
docker run -d -p 80:80 \
  -v $(pwd)/configs/nginx_config:/etc/nginx/conf.d/default.conf:ro \
  nginx:latest
```

---

## Testing Sequence (Complete IaaS Validation)

### 1. Infrastructure Check
```bash
# Check app is running
curl http://localhost/api/health

# Check metrics (CPU/Memory monitoring)
curl http://localhost/api/metrics

# Verify response times < 1 second
time curl http://localhost/api/health
```

### 2. Rate Limiting Test
```bash
# Test rate limiting (should get 429 after limit exceeded)
for i in {1..150}; do
  curl -s http://localhost/api/health >/dev/null && echo "Request $i: OK" || echo "Request $i: RATE LIMITED"
done
```

### 3. Security Headers Test
```bash
# Check security headers
curl -I http://localhost/dashboard

# Expected headers:
# X-Frame-Options: SAMEORIGIN
# X-Content-Type-Options: nosniff
# X-XSS-Protection: 1; mode=block
```

### 4. Application Functionality
```bash
# Create project
PROJECT_ID=$(curl -s -X POST http://localhost/api/projects \
  -H "Content-Type: application/json" \
  -d '{"name":"IaaS Test"}' | jq '.data.id')

echo "Created project: $PROJECT_ID"

# Create task
curl -X POST http://localhost/api/tasks \
  -H "Content-Type: application/json" \
  -d "{
    \"project_id\": $PROJECT_ID,
    \"title\": \"Test IaaS Setup\",
    \"status\": \"todo\"
  }"

# Get tasks
curl http://localhost/api/projects/$PROJECT_ID/tasks
```

### 5. Performance Test
```bash
# Use Apache Bench to load test
ab -n 100 -c 10 http://localhost/api/health

# Or use wrk if installed
wrk -t4 -c100 -d30s http://localhost/api/metrics
```

---

## Production Testing (Railway)

### Replace localhost with your Railway URL:
```bash
RAILWAY_URL="https://your-app.railway.app"

# Health check
curl $RAILWAY_URL/api/health

# Metrics
curl $RAILWAY_URL/api/metrics

# Full test sequence
curl $RAILWAY_URL/api/projects
curl -X POST $RAILWAY_URL/api/projects \
  -H "Content-Type: application/json" \
  -d '{"name":"Production Test"}'
```

---

## Monitoring Dashboard

### Metrics Interpretation

**CPU Percent:**
- 0-25%: Low load ✅
- 25-50%: Normal load ✅
- 50-75%: Moderate load ⚠️
- 75%+: High load - consider scaling 🔴

**Memory Percent:**
- 0-40%: Healthy ✅
- 40-70%: Acceptable ✅
- 70-85%: Monitor closely ⚠️
- 85%+: Risk of OOM - scale up 🔴

**Disk Percent:**
- 0-50%: Plenty of space ✅
- 50-80%: Monitor ⚠️
- 80-90%: Clean up needed ⚠️
- 90%+: Critical - clean up ASAP 🔴

---

## Automated Monitoring Script

### Create `monitor.sh`:
```bash
#!/bin/bash

API_URL="${1:-http://localhost}"
INTERVAL="${2:-5}"

while true; do
  echo "=== $(date) ==="
  curl -s $API_URL/api/metrics | jq '.cpu, .memory, .disk'
  sleep $INTERVAL
done
```

### Usage:
```bash
chmod +x monitor.sh

# Local monitoring
./monitor.sh http://localhost 5

# Production monitoring
./monitor.sh https://your-app.railway.app 10
```

---

## Error Handling Test

### Test 404 Not Found
```bash
curl http://localhost/api/nonexistent
```

### Test 400 Bad Request
```bash
curl -X POST http://localhost/api/projects \
  -H "Content-Type: application/json" \
  -d '{"description":"Missing name field"}'
```

### Test Invalid Data
```bash
curl -X POST http://localhost/api/tasks \
  -H "Content-Type: application/json" \
  -d '{
    "project_id": 999,
    "title": "Bad Project",
    "status": "invalid_status"
  }'
```

---

## Performance Metrics

### Expected Response Times:
- Health check: < 10ms
- Metrics endpoint: < 50ms
- API endpoints: < 100ms
- Dashboard: < 500ms

### Test with verbose timing:
```bash
curl -w "\nTime: %{time_total}s\n" http://localhost/api/health
curl -w "\nTime: %{time_total}s\n" http://localhost/api/metrics
```

---

## Nginx Verification

### Check Nginx is running:
```bash
curl -I http://localhost/
```

### Verify reverse proxy:
```bash
# Should go through Nginx to Flask
curl -v http://localhost/api/health | grep -i "X-Real-IP"
```

### Check Nginx logs:
```bash
docker exec xyz-corp-nginx tail -f /var/log/nginx/access.log
```

---

## Database Verification

### Check SQLite database:
```bash
# Connect to container
docker exec -it xyz-corp-api sqlite3 /app/projects.db

# Inside SQLite:
sqlite> .tables
sqlite> SELECT * FROM projects;
sqlite> SELECT * FROM tasks;
sqlite> .exit
```

---

## Complete Checklist

- [ ] Health check responds (200 OK)
- [ ] Metrics endpoint responds with CPU/Memory/Disk
- [ ] Dashboard loads in browser
- [ ] Can create projects via API
- [ ] Can create tasks via API
- [ ] Can update tasks via API
- [ ] Can delete tasks via API
- [ ] Rate limiting works (429 when exceeded)
- [ ] Security headers present
- [ ] Nginx reverse proxy working
- [ ] Gunicorn workers active (4)
- [ ] Database operations working
- [ ] Error handling returns proper status codes
- [ ] Response times acceptable
- [ ] Monitoring endpoint accurate

---

## Troubleshooting Tests

### If metrics endpoint not working:
```bash
# Check psutil is installed
docker exec xyz-corp-api pip list | grep psutil

# Should show: psutil 5.9.6

# If not installed, rebuild
docker-compose down
docker-compose up --build
```

### If rate limiting not working:
```bash
# Check Nginx configuration
docker exec xyz-corp-nginx cat /etc/nginx/conf.d/default.conf | grep -A 5 "limit_req"

# Restart Nginx
docker-compose restart nginx
```

### If database not persisting:
```bash
# Check volume mounted
docker inspect xyz-corp-api | grep -A 10 "Mounts"

# Should show /app/projects.db mapped
```

---

## Test Automation

### Using curl + jq for CI/CD:
```bash
#!/bin/bash

# Health check
health=$(curl -s http://localhost/api/health | jq '.status')
[ "$health" = '"healthy"' ] && echo "✅ Health: OK" || echo "❌ Health: FAILED"

# Metrics
metrics=$(curl -s http://localhost/api/metrics | jq '.status')
[ "$metrics" = '"success"' ] && echo "✅ Metrics: OK" || echo "❌ Metrics: FAILED"

# API
projects=$(curl -s http://localhost/api/projects | jq '.status')
[ "$projects" = '"success"' ] && echo "✅ API: OK" || echo "❌ API: FAILED"
```

---

Ready to test? Start with:
```bash
docker-compose up -d
curl http://localhost/api/health
curl http://localhost/api/metrics
```

Good luck! 🚀
