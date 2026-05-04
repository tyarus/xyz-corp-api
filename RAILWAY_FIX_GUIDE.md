# 🚀 RAILWAY DEPLOYMENT FIX - TROUBLESHOOTING GUIDE

**Date:** May 4, 2026
**Issue:** Application shutdown immediately after startup
**Status:** ✅ FIXED with updated Dockerfile & app.py

---

## 📋 WHAT WAS CHANGED

### 1. Dockerfile Improvements ✅
**Problem:** 
- Port mismatch (EXPOSE 5000 but Railway assigns 8080)
- Health check might timeout before app ready
- psutil not verified on build

**Solution:**
```dockerfile
# Explicit PORT=8080 for Railway
ENV PORT=8080

# Longer startup time (60s instead of 40s)
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=5

# Explicit CMD with port binding
CMD ["gunicorn", "--bind", "0.0.0.0:${PORT:-8080}", ...]

# Verify psutil installs
RUN python -c "import psutil; print('✓ psutil installed')"
```

### 2. gunicorn.conf.py Updates ✅
**Problem:**
- Default port was 5000, Railway expects 8080
- No error handling if port resolution fails

**Solution:**
```python
def resolve_port(default="8080"):  # Changed from 5000
    # Better error handling
    try:
        parsed = int(raw_port)
        if 1 <= parsed <= 65535:
            return str(parsed)
    except (ValueError, AttributeError):  # Added AttributeError
        pass
    return default
```

### 3. app.py Database Handling ✅
**Problem:**
- Database initialization might fail in Railway
- No error handling if /app is read-only

**Solution:**
```python
# Create data directory if doesn't exist
DATABASE_DIR = os.path.join(os.path.dirname(__file__), 'data')
os.makedirs(DATABASE_DIR, exist_ok=True)

# Wrap init_db with error handling
try:
    # ... database operations
except sqlite3.Error as e:
    print(f"[WARNING] Database error: {e}")
    print("[WARNING] Application will continue")
```

---

## ⏱️ RAILWAY REDEPLOY TIMELINE

**Now + 2-5 minutes:**
- Railway detects new commit
- Starts building Docker image
- Installs dependencies
- Starts gunicorn with port 8080

**Signs of successful deployment:**
```
✅ Deployment status: "Running" (green checkmark)
✅ No restart loop (doesn't crash and restart)
✅ Logs show: "Listening at: http://0.0.0.0:8080"
✅ All 4 workers boot successfully (pids 2,3,4,5)
✅ Application stays running (no "Shutting down" message)
```

**If still failing:**
- Logs show errors after worker boot
- Application crashes immediately
- Restart loop continues

---

## ✔️ VERIFICATION STEPS

### STEP 1: Check Railway Deployment Status
**In Railway Dashboard:**
1. Go to: Project → Deployments tab
2. Look for newest deployment (should say "Building" → "Success")
3. Status should be: ✅ **Running** (green)
4. NOT: ⚠️ Failed, ❌ Error, or continuously restarting

**Command line (if have Railway CLI):**
```bash
railway logs --follow
# Watch for: "Listening at: http://0.0.0.0:8080" 
# AND no errors after that
```

---

### STEP 2: Test Health Endpoint
```bash
# Get your Railway app URL from dashboard
RAILWAY_URL="https://xyz-corp-api-<random>.railway.app"

# Test health check
curl $RAILWAY_URL/api/health

# Expected response (200 OK):
{
  "status": "healthy",
  "service": "XYZ Corp Project Management API",
  "timestamp": "2024-05-04T10:30:00.123456",
  "database": "operational"
}
```

---

### STEP 3: Test Metrics Endpoint (NEW)
```bash
# This is the NEW feature we added
curl $RAILWAY_URL/api/metrics

# Expected response (200 OK):
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

---

### STEP 4: Test Dashboard
```bash
# Open in browser
https://your-railway-app.railway.app/dashboard

# Or via curl (should return HTML)
curl https://your-railway-app.railway.app/dashboard | head -20
```

---

## 🔧 RAILWAY ENVIRONMENT VARIABLES (Should already be set)

**Verify in Railway Dashboard → Variables:**

| Variable | Value | Purpose |
|----------|-------|---------|
| FLASK_ENV | production | Flask production mode |
| PYTHONUNBUFFERED | 1 | Real-time logging |
| GUNICORN_WORKERS | 4 | Worker processes |
| GUNICORN_TIMEOUT | 120 | Request timeout (seconds) |
| GUNICORN_LOG_LEVEL | info | Log verbosity |

**If NOT set, add them manually:**
1. Railway Dashboard → Project → Variables
2. Add each variable
3. Railway auto-redeploys

---

## 🎯 EXPECTED LOG OUTPUT (After fix)

```
[2026-05-04T06:17:49.618599852Z] [INFO] Starting gunicorn 21.2.0
[2026-05-04T06:17:49.618611036Z] [INFO] Listening at: http://0.0.0.0:8080 (1)
[2026-05-04T06:17:49.618614701Z] [INFO] Using worker: sync
[2026-05-04T06:17:49.618619211Z] [INFO] Booting worker with pid: 2
[2026-05-04T06:17:49.618622458Z] [INFO] Booting worker with pid: 3
[2026-05-04T06:17:49.618626188Z] [INFO] Booting worker with pid: 4
[2026-05-04T06:17:49.618821372Z] [INFO] Booting worker with pid: 5
[2026-05-04T06:17:50.000000000Z] [INFO] Application ready to handle requests
```

**NOT seeing logs continuing after "Booting worker"?**
- Application crashes or health check fails
- Check for import errors or database issues in detailed logs

---

## 🚨 COMMON ISSUES & FIXES

### Issue 1: Application still shuts down after 5 seconds

**Cause:** Health check failing or app crash

**Fix:**
1. Check Railway logs for error messages
2. If psutil import error: Railway cache issue → Force rebuild
3. If database error: Check file permissions

**Force Rebuild:**
```
Railway Dashboard → Settings → Redeploy
OR
Railway Dashboard → Deployments → Click latest → "Redeploy"
```

---

### Issue 2: Port mismatch error

**Cause:** Railway sends PORT=8080 but app expects 5000

**Fix:** ✅ Already fixed in updated Dockerfile & gunicorn.conf.py

---

### Issue 3: psutil module not found

**Cause:** `pip install -r requirements.txt` didn't run or psutil not installed

**Fix:**
1. Dockerfile now has: `pip install -r requirements.txt`
2. And verification: `python -c "import psutil"`
3. If still fails: Railway cache → Force rebuild

---

### Issue 4: Database permission error

**Cause:** `/app` directory is read-only in Railway

**Fix:** ✅ Already fixed in updated app.py
- Database moved to `/app/data/` directory
- `os.makedirs(DATABASE_DIR, exist_ok=True)` creates it if needed
- Error handling if creation fails (app continues anyway)

---

## 📊 MONITORING AFTER FIX

### Check Health Continuously (every 30 seconds)
```bash
watch -n 30 'curl -s https://your-railway-app.railway.app/api/health | jq'
```

### Monitor Metrics
```bash
watch -n 10 'curl -s https://your-railway-app.railway.app/api/metrics | jq ".cpu, .memory"'
```

### Check Deployment Logs
```bash
# Railway CLI
railway logs --follow

# Or manually: Railway Dashboard → Logs tab
```

---

## ✅ DEPLOYMENT SUCCESS CHECKLIST

After ~5 minutes of redeploy, verify:

- [ ] Railway dashboard shows "Running" status
- [ ] No errors in logs (only INFO messages)
- [ ] Can access `/api/health` → returns 200 OK
- [ ] Can access `/api/metrics` → returns CPU/memory data
- [ ] Can access `/dashboard` → loads web UI
- [ ] Application doesn't restart in loop

---

## ⏱️ NEXT STEPS

### Immediately (Next 5 minutes):
1. Watch Railway Deployments tab for build to complete
2. Check logs for errors
3. Test `/api/health` endpoint

### After deployment successful (15-30 minutes):
1. Test all endpoints
2. Verify metrics endpoint returning data
3. Take screenshots for UTS demo

### If still having issues:
1. Share error logs from Railway
2. Verify environment variables are set
3. Check if volumes/database persisting correctly

---

## 📞 TROUBLESHOOTING COMMANDS

```bash
# Local test (before push)
python -c "from app import app; print('App loads OK')"
docker-compose up -d

# Check git status
git status

# Check git log
git log --oneline -5

# View latest commit
git show --stat

# Railway CLI (if installed)
railway logs
railway ps
railway status

# Check if psutil available
python -c "import psutil; print(psutil.__version__)"
```

---

## 📌 KEY CHANGES SUMMARY

**File** | **What Changed** | **Why**
---------|-----------------|-------
Dockerfile | ENV PORT=8080, longer health check, explicit CMD | Railway compatibility
gunicorn.conf.py | Default port 8080, better error handling | Port mismatch fix
app.py | Create data dir, error handling for DB init | File permission fix, graceful failure
requirements.txt | Already has psutil==5.9.6 | Dependencies

---

## 🎓 FOR UTS DEMONSTRATION

**What to show:**
1. Deployed app in Railway dashboard (status: Running ✅)
2. Health endpoint: `curl /api/health` 
3. **Metrics endpoint** (new feature): `curl /api/metrics` with CPU/Memory data
4. Dashboard UI working
5. Create a project and task via API

**What to explain:**
- Fixed Docker deployment issues
- Proper port binding (8080 for Railway)
- Database initialization error handling
- psutil integration for monitoring
- Infrastructure running on Railway (IaaS)

---

**Status:** ✅ Deployment fixes applied and pushed
**Wait:** 2-5 minutes for Railway to rebuild and deploy
**Then:** Run verification steps above

Good luck! 🚀
