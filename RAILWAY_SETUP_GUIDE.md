# Railway.app Deployment Guide - XYZ Corp API

## Apa itu Railway.app?

Railway.app adalah platform cloud yang simple, modern, dan gratis untuk deploy aplikasi. Keuntungan:
- ✅ Gratis untuk 7 hari percobaan
- ✅ Hanya bayar yang terpakai (mulai dari $5/bulan)
- ✅ Auto deploy dari Git (GitHub/GitLab)
- ✅ Auto SSL certificate
- ✅ Built-in environment variables
- ✅ Database terintegrasi
- ✅ Simple dan user-friendly

---

## Prerequisites

Sebelum memulai, siapkan:
- [ ] Account GitHub atau GitLab (untuk connect repo)
- [ ] Account Railway.app (gratis)
- [ ] Project files siap di Git repository

---

## STEP 1: Persiapan Git Repository

### Step 1.1: Buat Repository di GitHub

1. Go to [GitHub.com](https://github.com)
2. Click **"New repository"**
3. **Repository name**: `xyz-corp-api`
4. **Description**: `XYZ Corp Project Management API`
5. **Visibility**: Public or Private
6. Click **"Create repository"**

### Step 1.2: Push Project Files ke GitHub

Di local machine Anda:

```bash
# Navigate ke project folder
cd "d:\semester 6\komputasi awann\uts\XYZ-Corp-API"

# Initialize git repository
git init

# Add all files
git add .

# Commit
git commit -m "Initial commit: XYZ Corp API project"

# Add remote (replace dengan URL repo Anda)
git remote add origin https://github.com/YOUR_USERNAME/xyz-corp-api.git

# Push ke GitHub
git branch -M main
git push -u origin main
```

**Expected output:**
```
Enumerating objects: XX, done.
Counting objects: 100% (XX/XX), done.
Writing objects: 100% (XX/XX), done.
...
✓ Push successful!
```

---

## STEP 2: Setup Railway.app

### Step 2.1: Create Railway.app Account

1. Go to [Railway.app](https://railway.app)
2. Click **"Create Account"** atau **"Sign in with GitHub"** (recommended)
3. Complete sign up
4. Verify email

### Step 2.2: Create New Project

1. In Railway dashboard, click **"New Project"**
2. Select **"Deploy from GitHub repo"**
3. Connect GitHub account jika belum
4. Select your repository: `xyz-corp-api`
5. Click **"Deploy"**

Railway akan secara otomatis:
- ✅ Detect Python project
- ✅ Build container
- ✅ Deploy aplikasi
- ✅ Assign domain publik

---

## STEP 3: Configure Environment Variables

### Step 3.1: Set Environment Variables di Railway

1. In Railway project dashboard
2. Go to **Settings** → **Variables**
3. Add the following variables:

```
FLASK_ENV=production
PYTHONUNBUFFERED=1
PORT=5000
```

### Step 3.2: Verify Deployment

1. Go back to **Deployments**
2. Check latest deployment status
3. Should show "Success" with green checkmark

---

## STEP 4: Access Your API

### Option A: Using Railway Domain

Railway akan memberikan domain publik otomatis:

```bash
# Format: https://xyz-corp-api-production.up.railway.app/
# Cek di Railway dashboard untuk exact URL

# Test health endpoint
curl https://YOUR_RAILWAY_DOMAIN/api/health

# Expected response:
# {"status":"healthy","service":"XYZ Corp Project Management API",...}
```

### Option B: Add Custom Domain (Optional)

1. Railway dashboard → Settings → Domains
2. Click **"Add domain"**
3. Enter your custom domain: `api.yourdomain.com`
4. Follow DNS configuration instructions

---

## STEP 5: Test Endpoints

### Test dari Local Machine

```bash
# Replace dengan Railway domain Anda
DOMAIN="https://your-railway-domain.up.railway.app"

# 1. Health check
curl $DOMAIN/api/health

# 2. Create project
curl -X POST $DOMAIN/api/projects \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Website Redesign",
    "description": "XYZ Corp website modernization"
  }'

# 3. Get all projects
curl $DOMAIN/api/projects

# 4. Create task
curl -X POST $DOMAIN/api/tasks \
  -H "Content-Type: application/json" \
  -d '{
    "project_id": 1,
    "title": "Design homepage",
    "status": "todo",
    "assigned_to": "John Doe"
  }'

# 5. Get project tasks
curl $DOMAIN/api/projects/1/tasks

# 6. Update task
curl -X PUT $DOMAIN/api/tasks/1 \
  -H "Content-Type: application/json" \
  -d '{"status":"in-progress"}'

# 7. Delete task
curl -X DELETE $DOMAIN/api/tasks/1
```

---

## STEP 6: View Logs

### Real-time Logs di Railway

1. Railway dashboard → Your project
2. Click **"Logs"** tab
3. Real-time application logs akan ditampilkan

### View Errors

```bash
# Jika deployment gagal, cek logs untuk error
# Railway akan menampilkan output build & runtime
```

---

## STEP 7: Setup Database (Optional - Advanced)

Railway menyediakan PostgreSQL terintegrasi (berbayar). Untuk development, SQLite default sudah cukup.

Jika ingin gunakan PostgreSQL:

1. Railway dashboard → **"Add Service"**
2. Select **"PostgreSQL"**
3. Railway akan setup database otomatis
4. Ambil connection string dari Variables
5. Update app.py untuk gunakan PostgreSQL

Tapi untuk sekarang, **SQLite sudah fine!**

---

## STEP 8: Auto Redeploy

### Automatic Deployment

Railway secara otomatis akan redeploy ketika:
- ✅ Push ke branch `main` di GitHub
- ✅ Detecta perubahan di codebase

Jadi workflow Anda:

```bash
# 1. Edit file di local
# 2. Commit & push
git add .
git commit -m "Add new feature"
git push

# 3. Railway akan otomatis redeploy! 🚀
# 4. Check logs di Railway dashboard
```

---

## Quick Comparison: AWS EC2 vs Railway

| Aspek | AWS EC2 | Railway.app |
|-------|---------|-----------|
| Setup time | 30+ minutes | 5 minutes |
| Cost | Free tier | Free trial + $5/mo |
| Complexity | High | Very Low |
| Auto deploy | Manual | Automatic |
| Scaling | Manual | Automatic |
| SSL | Manual | Automatic |
| Maintenance | Manual | Automatic |

---

## Troubleshooting

### Build Failed

1. Check logs di Railway dashboard
2. Common issues:
   - `requirements.txt` missing
   - Procfile missing atau salah
   - Python version incompatible

### Application Crashes

1. View logs: Railway → Logs
2. Check environment variables set
3. Verify `PORT` environment variable

### Cannot Connect

1. Verify API domain di Railway dashboard
2. Check if service is running (green status)
3. Verify CORS settings jika perlu

---

## Important Files untuk Railway

File-file ini WAJIB ada di root directory:

✅ **Procfile** - Tells Railway how to run app
```
web: gunicorn --workers 4 --bind 0.0.0.0:$PORT app:app
```

✅ **requirements.txt** - Python dependencies
```
Flask==2.3.3
Gunicorn==21.2.0
```

✅ **app.py** - Your Flask application

---

## Useful Railway Commands (CLI)

Railway juga punya CLI untuk advanced usage:

```bash
# Install Railway CLI
npm install -g @railway/cli

# Login ke Railway
railway login

# View project
railway projects list

# View logs
railway logs

# Deploy manual
railway deploy
```

---

## Monitoring & Metrics

Railway dashboard menampilkan:
- ✅ CPU usage
- ✅ Memory usage
- ✅ Disk usage
- ✅ Network traffic
- ✅ Build/deploy history
- ✅ Real-time logs

---

## Cost Estimate

| Resource | Usage | Cost |
|----------|-------|------|
| Compute | ~100 hours/month | $5.00 |
| Outbound Data | ~10GB/month | $1.00 |
| **Total** | | **~$6.00/month** |

First 7 days: **FREE!** 🎉

---

## Next Steps

1. ✅ Create GitHub repository
2. ✅ Push project files
3. ✅ Create Railway.app account
4. ✅ Deploy from GitHub
5. ✅ Test endpoints
6. ✅ Share API domain dengan tim

---

## Support Resources

- [Railway.app Docs](https://docs.railway.app/)
- [Railway Support](https://railway.app/support)
- [Flask Documentation](https://flask.palletsprojects.com/)

---

**Railway.app setup complete! 🚀**

Jauh lebih simple dari AWS, bukan? 😊
