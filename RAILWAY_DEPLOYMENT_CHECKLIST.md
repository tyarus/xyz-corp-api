# Railway.app Deployment Checklist

## Pre-Deployment Checks

- [ ] GitHub account created
- [ ] XYZ Corp API project ready locally
- [ ] All files working correctly (tested locally)
- [ ] Project pushed to GitHub
- [ ] Railway.app account created
- [ ] Team members have access to documentation

---

## GitHub Repository Setup

- [ ] Repository created on GitHub
- [ ] Repository name: `xyz-corp-api`
- [ ] Repository is public (or private if needed)
- [ ] All project files pushed:
  - [ ] app.py
  - [ ] requirements.txt
  - [ ] Procfile
  - [ ] Dockerfile (optional)
  - [ ] configs/ folder (optional)
  - [ ] scripts/ folder (optional)
- [ ] README.md present
- [ ] .gitignore configured (if needed)

---

## Railway.app Deployment

- [ ] Railway.app account created
- [ ] GitHub account connected to Railway
- [ ] New project created in Railway
- [ ] Repository `xyz-corp-api` selected
- [ ] Deploy button clicked
- [ ] Build process started

---

## Deployment Verification

### Build Status
- [ ] Build started successfully
- [ ] Build completed without errors
- [ ] Deployment status shows "Success" (green)
- [ ] No failed build logs

### Service Running
- [ ] Application shows as running (green status)
- [ ] No restart errors in logs
- [ ] Port assignment verified

### Domain & Access
- [ ] Railway assigned domain: `https://xyz-corp-api-production.up.railway.app/`
- [ ] Domain is publicly accessible
- [ ] No DNS errors

---

## API Testing

### Test Health Endpoint
```bash
curl https://YOUR_RAILWAY_DOMAIN/api/health
```
- [ ] Returns 200 OK
- [ ] Response shows "healthy"
- [ ] Response time < 1 second

### Test Create Project
```bash
curl -X POST https://YOUR_RAILWAY_DOMAIN/api/projects \
  -H "Content-Type: application/json" \
  -d '{"name":"Website Redesign","description":"XYZ Corp website"}'
```
- [ ] Returns 201 Created
- [ ] Response shows project ID
- [ ] Project name matches input

### Test Get Projects
```bash
curl https://YOUR_RAILWAY_DOMAIN/api/projects
```
- [ ] Returns 200 OK
- [ ] Response shows list of projects
- [ ] Includes newly created project

### Test Create Task
```bash
curl -X POST https://YOUR_RAILWAY_DOMAIN/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"project_id":1,"title":"Design homepage","status":"todo","assigned_to":"John Doe"}'
```
- [ ] Returns 201 Created
- [ ] Response shows task ID
- [ ] Task details match input

### Test Get Tasks
```bash
curl https://YOUR_RAILWAY_DOMAIN/api/projects/1/tasks
```
- [ ] Returns 200 OK
- [ ] Response shows list of tasks
- [ ] Includes newly created task

### Test Update Task
```bash
curl -X PUT https://YOUR_RAILWAY_DOMAIN/api/tasks/1 \
  -H "Content-Type: application/json" \
  -d '{"status":"in-progress"}'
```
- [ ] Returns 200 OK
- [ ] Status updated to "in-progress"

### Test Delete Task
```bash
curl -X DELETE https://YOUR_RAILWAY_DOMAIN/api/tasks/1
```
- [ ] Returns 200 OK
- [ ] Response confirms deletion

### Test Error Handling
```bash
curl https://YOUR_RAILWAY_DOMAIN/api/projects/99999/tasks
```
- [ ] Returns 404 error
- [ ] Error message is clear

---

## Performance & Monitoring

### Response Times
- [ ] Health check: < 200ms
- [ ] Get projects: < 500ms
- [ ] Create project: < 1 second
- [ ] Get tasks: < 500ms

### Logs
- [ ] Application logs visible in Railway dashboard
- [ ] No error messages in logs
- [ ] Requests being logged

### Resource Usage
- [ ] CPU usage < 50%
- [ ] Memory usage < 300MB
- [ ] No memory leaks observed

---

## Database Verification

### Database Access
- [ ] Database file exists (SQLite)
- [ ] Database persists after deployment
- [ ] Data survives container restarts

### Data Integrity
- [ ] Projects table populated
- [ ] Tasks table populated
- [ ] Foreign key relationships intact
- [ ] No data corruption

---

## Security Checks

- [ ] API not exposed to unauthorized users
- [ ] HTTPS certificate auto-generated (green lock icon)
- [ ] No sensitive data in logs
- [ ] Error messages don't leak system info
- [ ] SQL injection protection working (parameterized queries)

---

## Documentation & Team Access

- [ ] README.md updated with Railway domain
- [ ] RAILWAY_SETUP_GUIDE.md complete
- [ ] Team members can access API
- [ ] Team has correct domain URL
- [ ] Support documentation available

---

## Post-Deployment (First 24 Hours)

- [ ] Monitor logs for errors
- [ ] Check response times
- [ ] Verify data persistence
- [ ] Test all endpoints once more
- [ ] Document any issues found

---

## Post-Deployment (Week 1)

- [ ] Performance metrics stable
- [ ] No memory leaks observed
- [ ] Error rate acceptable (< 1%)
- [ ] Database growing as expected
- [ ] Team feedback collected

---

## Auto-Deploy Verification

- [ ] Make a code change in GitHub
- [ ] Commit and push to main branch
- [ ] Railway automatically detects change
- [ ] Build triggered automatically
- [ ] Deployment completed successfully
- [ ] Changes live within 5 minutes

---

## Deployment Metadata

| Item | Value |
|------|-------|
| Deployment Date | ________________ |
| Time Started | ________________ |
| Time Completed | ________________ |
| Railway Domain | ________________ |
| Project ID | ________________ |
| Team Lead | ________________ |
| Status | [ ] SUCCESS [ ] FAILED |

---

## Notes & Issues Encountered

```
_________________________________________________________________

_________________________________________________________________

_________________________________________________________________

_________________________________________________________________
```

---

## Final Sign-Off

| Role | Name | Date | Sign-Off |
|------|------|------|----------|
| Developer | _______________ | ________ | ______ |
| QA/Tester | _______________ | ________ | ______ |
| Project Lead | _______________ | ________ | ______ |

---

## Rollback Plan (If Needed)

If something goes wrong:

1. Go to Railway dashboard
2. Click "Deployments"
3. Select previous successful deployment
4. Click "Rollback" button
5. Service reverts to previous version

**Rollback Time**: < 5 minutes

---

## Next Steps

- [ ] Share API domain with team
- [ ] Setup monitoring alerts (optional)
- [ ] Plan feature releases
- [ ] Schedule regular backups
- [ ] Document API usage for team

---

**Deployment Status**: [ ] ✅ SUCCESSFUL [ ] ❌ FAILED

**Deployment completed successfully!** 🎉

---

*Keep this checklist for future reference and deployments.*
