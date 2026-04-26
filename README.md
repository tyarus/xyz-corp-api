# XYZ Corp Project Management API - Complete Deployment Guide

## Project Overview

- **Project Name**: XYZ Corp Project Management API
- **Platform**: Railway.app (Simple Cloud Platform) or AWS EC2 (Advanced)
- **Stack**: Python Flask + Gunicorn + SQLite
- **Purpose**: REST API for project and task management

## 🚀 Quick Start with Railway.app

**Railway.app is recommended for simple, fast deployment!**

```bash
# 1. Push to GitHub
git add .
git commit -m "Initial commit"
git push

# 2. Go to Railway.app → New Project → Deploy from GitHub
# 3. Done! Your API is live! 🎉
```

**Time to deploy: 5 minutes ⚡**

## 📚 Documentation

### 🌟 Choose Your Deployment Platform

**RECOMMENDED: Railway.app** (Simplest & Fastest)
- ✅ [RAILWAY_SETUP_GUIDE.md](RAILWAY_SETUP_GUIDE.md) - 5 minutes to deploy!
- Auto deploy from GitHub
- Free for 7 days
- $5-10/month after

**ALTERNATIVE: AWS EC2** (Advanced Control)
- [AWS_SETUP_GUIDE.md](AWS_SETUP_GUIDE.md) - Full manual control
- Free tier available
- More complex setup
- Better for production at scale

### 📖 Other Documentation
- [README.md](README.md) - Main documentation (this file)
- [PROJECT_SUMMARY.md](PROJECT_SUMMARY.md) - Project overview
- [DEPLOYMENT_CHECKLIST.md](DEPLOYMENT_CHECKLIST.md) - Pre & post deployment
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Common issues & solutions
- [QUICK_REFERENCE.md](QUICK_REFERENCE.md) - Command reference

## Architecture

### Railway.app (Recommended)
```
┌─────────────────────────────────────────────┐
│  Your GitHub Repository                     │
│  git push → Railway Auto Deploys ✨        │
└──────────────────┬──────────────────────────┘
                   │
                   ▼
┌─────────────────────────────────────────────┐
│      Railway.app (Cloud Platform)           │
│  ┌──────────────────────────────────┐      │
│  │  Python Flask Application         │      │
│  │  (Gunicorn, Auto-scaled)          │      │
│  └──────────────────────────────────┘      │
│  ┌──────────────────────────────────┐      │
│  │  SQLite Database                  │      │
│  │  (Persistent Volume)              │      │
│  └──────────────────────────────────┘      │
│  ┌──────────────────────────────────┐      │
│  │  Auto SSL + CDN + Monitoring      │      │
│  └──────────────────────────────────┘      │
└─────────────────────────────────────────────┘
```

### AWS EC2 (Alternative - Advanced)
```
┌─────────────────────────────────────────────────────────────┐
│                    AWS EC2 (t2.micro)                       │
│                   Ubuntu 22.04 LTS                          │
├─────────────────────────────────────────────────────────────┤
│  Port 80 ◄── Nginx (Reverse Proxy)                          │
│              ↓                                              │
│        Gunicorn (Port 5000)                                 │
│              ↓                                              │
│        Flask Application                                    │
│              ↓                                              │
│        SQLite Database + CloudWatch Monitoring              │
└─────────────────────────────────────────────────────────────┘
```

## 🚀 DEPLOYMENT OPTION 1: Railway.app (RECOMMENDED)

**Fastest way to deploy your API!** ⚡

Follow [RAILWAY_SETUP_GUIDE.md](RAILWAY_SETUP_GUIDE.md) for complete step-by-step instructions.

### Quick Steps:
1. Create GitHub repository
2. Push project files
3. Create Railway.app account
4. Deploy from GitHub (Railway auto-detects Python)
5. Done! API is live 🎉

**Time: 5 minutes | Cost: Free for 7 days, then ~$5-10/month**

---

## 🔧 DEPLOYMENT OPTION 2: AWS EC2 (ADVANCED)

For full control and advanced configuration, follow [AWS_SETUP_GUIDE.md](AWS_SETUP_GUIDE.md)

### Quick Steps (Automated):

Once connected to your EC2 instance via SSH:

#### Step 1: Prepare Application Files

```bash
# Create application directory
mkdir -p /home/ubuntu/xyzapp
cd /home/ubuntu/xyzapp

# Copy your application files here:
# - app.py
# - requirements.txt
```

#### Step 2: Run Master Setup Script

```bash
# Make setup script executable
chmod +x setup.sh

# Run the automated setup script
bash setup.sh
```

**What this script does:**
- ✅ Updates system packages
- ✅ Installs Python, Nginx, SQLite
- ✅ Creates Python virtual environment
- ✅ Installs Flask and Gunicorn
- ✅ Configures systemd service
- ✅ Sets up Nginx reverse proxy
- ✅ Configures UFW firewall
- ✅ Installs CloudWatch Agent

### TASK 7: CloudWatch Monitoring Setup

```bash
# Make script executable
chmod +x cloudwatch_setup.sh

# Run CloudWatch setup
bash cloudwatch_setup.sh
```

**Before running, configure:**
1. AWS IAM role with CloudWatch permissions attached to EC2
2. SNS topic for alarm notifications (optional but recommended)

### TASK 8: Testing and Verification

#### Test Locally (on EC2)

```bash
# Make test script executable
chmod +x test_endpoints.sh

# Run comprehensive tests
bash test_endpoints.sh
```

#### Test from Local Machine

```bash
# Health check
curl http://YOUR_ELASTIC_IP/api/health

# Create project
curl -X POST http://YOUR_ELASTIC_IP/api/projects \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Website Redesign",
    "description": "XYZ Corp website modernization"
  }'

# Get all projects
curl http://YOUR_ELASTIC_IP/api/projects
```

## API Endpoints

### Health Check
```
GET /api/health
```
Returns API health status.

### Projects

#### Get All Projects
```
GET /api/projects
```

#### Create Project
```
POST /api/projects
Content-Type: application/json

{
  "name": "Project Name",
  "description": "Project Description"
}
```

### Tasks

#### Get Project Tasks
```
GET /api/projects/{id}/tasks
```

#### Create Task
```
POST /api/tasks
Content-Type: application/json

{
  "project_id": 1,
  "title": "Task Title",
  "status": "todo",           // or "in-progress", "done"
  "assigned_to": "Name"
}
```

#### Update Task
```
PUT /api/tasks/{id}
Content-Type: application/json

{
  "title": "Updated Title",
  "status": "in-progress",
  "assigned_to": "New Name"
}
```

#### Delete Task
```
DELETE /api/tasks/{id}
```

## Service Management

### Flask/Gunicorn Service

```bash
# Start service
sudo systemctl start xyzapp

# Stop service
sudo systemctl stop xyzapp

# Restart service
sudo systemctl restart xyzapp

# View status
sudo systemctl status xyzapp

# View logs
journalctl -u xyzapp -f

# Enable on startup
sudo systemctl enable xyzapp
```

### Nginx

```bash
# Start service
sudo systemctl start nginx

# Stop service
sudo systemctl stop nginx

# Restart service
sudo systemctl restart nginx

# Test configuration
sudo nginx -t

# View logs
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/log/nginx/xyzapp_access.log
```

### UFW Firewall

```bash
# Check status
sudo ufw status

# Enable/Disable
sudo ufw enable
sudo ufw disable

# Allow rule
sudo ufw allow 22/tcp
sudo ufw allow 80/tcp

# View rules
sudo ufw show added
```

## Logging

### Application Logs
```bash
# Access logs
tail -f /home/ubuntu/xyzapp/logs/access.log

# Error logs
tail -f /home/ubuntu/xyzapp/logs/error.log
```

### Nginx Logs
```bash
# Access logs
sudo tail -f /var/log/nginx/xyzapp_access.log

# Error logs
sudo tail -f /var/log/nginx/xyzapp_error.log
```

### System Logs
```bash
# Systemd logs
journalctl -u xyzapp -f

# UFW logs
sudo journalctl -u ufw -f
```

## Database

### Location
```
/home/ubuntu/xyzapp/projects.db
```

### Access Database
```bash
# Connect to SQLite
sqlite3 /home/ubuntu/xyzapp/projects.db

# View tables
.tables

# Query projects
SELECT * FROM projects;

# Query tasks
SELECT * FROM tasks;

# Exit
.exit
```

## Monitoring with CloudWatch

### Available Metrics
- `CPU_Usage_Active` - CPU usage percentage
- `Memory_Used_Percent` - Memory usage percentage
- `Disk_Used_Percent` - Disk usage percentage

### CloudWatch Alarms
- **High CPU**: Alert when CPU > 80%
- **High Memory**: Alert when Memory > 80%
- **High Disk**: Alert when Disk > 80%

### View Metrics
1. Go to **AWS CloudWatch Console**
2. Click **"Metrics"** → **"Custom Namespaces"** → **"XYZCorp/ProjectManagementAPI"**
3. Select metrics to view

### Configure Notifications
1. Create or select **SNS Topic**
2. Subscribe with your email
3. Update alarm actions to send to SNS topic

## Troubleshooting

### Application Not Starting

```bash
# Check service status
sudo systemctl status xyzapp

# View detailed logs
journalctl -u xyzapp -n 50

# Restart service
sudo systemctl restart xyzapp
```

### Port 80 Already in Use

```bash
# Find process using port 80
sudo lsof -i :80

# Kill the process if needed
sudo kill -9 <PID>

# Restart Nginx
sudo systemctl restart nginx
```

### Database Locked Error

```bash
# The database is being used by multiple processes
# Usually resolves on restart
sudo systemctl restart xyzapp
```

### Permission Denied Errors

```bash
# Ensure ubuntu user owns the application directory
sudo chown -R ubuntu:ubuntu /home/ubuntu/xyzapp

# Set proper permissions
chmod 755 /home/ubuntu/xyzapp
chmod 644 /home/ubuntu/xyzapp/projects.db
```

## Security Best Practices

1. **SSH Access**: Restrict to admin IP only
2. **HTTP/HTTPS**: Keep port 80 and 443 open for web traffic
3. **Firewall**: Use UFW to restrict unnecessary ports
4. **Updates**: Regularly update system packages
5. **Backups**: Backup database regularly to S3
6. **Monitoring**: Set up CloudWatch alarms for critical metrics

## Cost Optimization

This setup uses AWS Free Tier:
- **EC2**: t2.micro (750 hours/month)
- **Storage**: 20 GB EBS (30 GB/month)
- **CloudWatch**: 10 free custom metrics
- **Data Transfer**: 1 GB/month free

## Performance Tips

1. **Gunicorn Workers**: Adjust based on CPU cores
   ```bash
   # Check CPU cores
   nproc
   
   # Update workers in xyzapp.service
   --workers 4  # Set to CPU cores or slightly higher
   ```

2. **Database Optimization**:
   ```bash
   # Create indexes for better query performance
   sqlite3 /home/ubuntu/xyzapp/projects.db
   CREATE INDEX idx_tasks_project ON tasks(project_id);
   .exit
   ```

3. **Nginx Caching**: Enable caching for frequently accessed endpoints

## Maintenance

### Daily
- Monitor CloudWatch alarms
- Check application logs for errors

### Weekly
- Review CloudWatch metrics
- Check disk space usage
- Monitor database size

### Monthly
- Update system packages
- Review security group rules
- Backup database

## Additional Resources

- [Flask Documentation](https://flask.palletsprojects.com/)
- [Gunicorn Documentation](https://gunicorn.org/)
- [Nginx Documentation](https://nginx.org/en/docs/)
- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)
- [CloudWatch Documentation](https://docs.aws.amazon.com/cloudwatch/)

## Contact & Support

For issues or questions about this API:
1. Check logs: `journalctl -u xyzapp -f`
2. Test endpoints: `bash scripts/test_endpoints.sh`
3. Review CloudWatch metrics in AWS Console
4. Contact XYZ Corp DevOps Team

---

**Last Updated**: April 26, 2026
**Version**: 1.0.0
