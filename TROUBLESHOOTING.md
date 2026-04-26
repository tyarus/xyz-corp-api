# Troubleshooting Guide - XYZ Corp API

## Common Issues and Solutions

### 1. Application Won't Start

#### Symptoms
- Service shows as failed in `systemctl status`
- API returns 502 Bad Gateway
- No response from `http://localhost/api/health`

#### Solution

**Step 1: Check service status**
```bash
sudo systemctl status xyzapp
```

**Step 2: View detailed logs**
```bash
journalctl -u xyzapp -n 50 --no-pager
```

**Step 3: Manual test run**
```bash
cd /home/ubuntu/xyzapp
source venv/bin/activate
python app.py
```

**Step 4: Check for missing dependencies**
```bash
source /home/ubuntu/xyzapp/venv/bin/activate
pip install -r /home/ubuntu/xyzapp/requirements.txt
```

**Step 5: Restart service**
```bash
sudo systemctl restart xyzapp
```

---

### 2. Port 80 Not Accessible (HTTP Connection Refused)

#### Symptoms
- Cannot reach API from browser or curl
- Nginx status shows active but not responding
- Connection refused on port 80

#### Solution

**Step 1: Check if Nginx is running**
```bash
sudo systemctl status nginx
ps aux | grep nginx
```

**Step 2: Check if port 80 is listening**
```bash
sudo netstat -tlnp | grep :80
# or
sudo lsof -i :80
```

**Step 3: Test Nginx configuration**
```bash
sudo nginx -t
```

**Step 4: View Nginx error logs**
```bash
sudo tail -f /var/log/nginx/error.log
```

**Step 5: Restart Nginx**
```bash
sudo systemctl restart nginx
```

**Step 6: Check Security Group in AWS**
- Go to AWS Console → EC2 → Security Groups
- Verify that port 80 (HTTP) is open to `0.0.0.0/0`

---

### 3. Port Already in Use

#### Symptoms
- "Address already in use" error when starting service
- Cannot bind to port 5000 or 80

#### Solution

**Step 1: Find what's using the port**
```bash
# For port 5000 (Gunicorn)
sudo lsof -i :5000

# For port 80 (Nginx)
sudo lsof -i :80
```

**Step 2: Kill the process (if it's not needed)**
```bash
# Replace PID with the number from lsof output
sudo kill -9 <PID>
```

**Step 3: Restart the service**
```bash
sudo systemctl restart xyzapp
sudo systemctl restart nginx
```

**Step 4: Check if service starts properly**
```bash
curl http://localhost/api/health
```

---

### 4. Database Error: "Database is locked"

#### Symptoms
- API returns 500 error
- Logs show "database is locked"
- Cannot write to database

#### Solution

**Step 1: Stop the service**
```bash
sudo systemctl stop xyzapp
```

**Step 2: Check for lock files**
```bash
ls -la /home/ubuntu/xyzapp/
# Look for projects.db-wal or projects.db-shm files
```

**Step 3: Remove lock files (if stuck)**
```bash
rm -f /home/ubuntu/xyzapp/projects.db-wal
rm -f /home/ubuntu/xyzapp/projects.db-shm
```

**Step 4: Restart service**
```bash
sudo systemctl start xyzapp
```

**Step 5: Verify database**
```bash
sqlite3 /home/ubuntu/xyzapp/projects.db "SELECT count(*) FROM projects;"
```

---

### 5. Permission Denied Errors

#### Symptoms
- Cannot read/write files in application directory
- Logs show permission errors
- Service fails with permission denied

#### Solution

**Step 1: Check current permissions**
```bash
ls -la /home/ubuntu/xyzapp/
```

**Step 2: Fix ownership**
```bash
sudo chown -R ubuntu:ubuntu /home/ubuntu/xyzapp
```

**Step 3: Fix directory permissions**
```bash
sudo chmod 755 /home/ubuntu/xyzapp
```

**Step 4: Fix file permissions**
```bash
sudo chmod 644 /home/ubuntu/xyzapp/*.py
sudo chmod 644 /home/ubuntu/xyzapp/*.txt
```

**Step 5: Fix script permissions**
```bash
sudo chmod +x /home/ubuntu/xyzapp/scripts/*.sh
```

**Step 6: Create logs directory if missing**
```bash
mkdir -p /home/ubuntu/xyzapp/logs
sudo chown ubuntu:ubuntu /home/ubuntu/xyzapp/logs
```

---

### 6. CloudWatch Agent Not Running

#### Symptoms
- No metrics showing in CloudWatch Console
- Agent shows as stopped

#### Solution

**Step 1: Check agent status**
```bash
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a query -m ec2 -s
```

**Step 2: Verify configuration file exists**
```bash
ls -la /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json
```

**Step 3: Check IAM role permissions**
- EC2 Instance must have IAM role with CloudWatch permissions
- Go to AWS Console → EC2 → Your Instance → Details → IAM role

**Step 4: Restart agent**
```bash
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a stop -m ec2 -s
    
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a start -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s
```

**Step 5: Check agent logs**
```bash
sudo tail -f /opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log
```

---

### 7. High Latency / Slow Response Times

#### Symptoms
- API responses take >5 seconds
- High CPU or Memory usage
- Database queries are slow

#### Solution

**Step 1: Check system resources**
```bash
top -b -n 1
free -h
df -h
```

**Step 2: Identify slow API calls**
```bash
tail -f /home/ubuntu/xyzapp/logs/access.log
```

**Step 3: Check Gunicorn worker count**
```bash
ps aux | grep gunicorn
```

**Step 4: Increase workers if CPU available**
```bash
# Edit systemd service
sudo nano /etc/systemd/system/xyzapp.service

# Change --workers 4 to higher number based on CPU cores
# nproc = number of CPU cores
nproc
```

**Step 5: Add database indexes**
```bash
sqlite3 /home/ubuntu/xyzapp/projects.db <<EOF
CREATE INDEX IF NOT EXISTS idx_tasks_project ON tasks(project_id);
CREATE INDEX IF NOT EXISTS idx_tasks_status ON tasks(status);
.exit
EOF
```

**Step 6: Restart service**
```bash
sudo systemctl restart xyzapp
```

---

### 8. Memory Leak / Service Crashing

#### Symptoms
- Service restarts randomly
- Memory usage increases over time
- Application crashes after running for hours

#### Solution

**Step 1: Monitor memory usage**
```bash
watch -n 1 free -h
journalctl -u xyzapp -f
```

**Step 2: Check for resource limits**
```bash
ulimit -a
```

**Step 3: Set resource limits in systemd**
```bash
sudo nano /etc/systemd/system/xyzapp.service

# Add under [Service] section:
# MemoryLimit=256M
# MemoryAccounting=yes
```

**Step 4: Restart service**
```bash
sudo systemctl daemon-reload
sudo systemctl restart xyzapp
```

**Step 5: Enable swap (if available)**
```bash
free -h  # Check if swap exists
```

---

### 9. SSH Connection Issues

#### Symptoms
- Cannot SSH into instance
- "Permission denied"
- "Connection refused"
- "Network is unreachable"

#### Solution

**Check 1: Verify Elastic IP**
```bash
# Check in AWS Console → EC2 → Instances
# Note the Public IP
```

**Check 2: Verify key file permissions (local machine)**
```bash
ls -la xyz-corp-key.pem
# Should show: -rw------- (600)

chmod 400 xyz-corp-key.pem
```

**Check 3: Verify security group allows SSH**
- AWS Console → EC2 → Security Groups
- Check inbound rule: Port 22 (SSH) from your IP

**Check 4: Test SSH connectivity**
```bash
# Try with more verbose output
ssh -vvv -i xyz-corp-key.pem ubuntu@YOUR_ELASTIC_IP
```

**Check 5: Verify instance is running**
- AWS Console → EC2 → Instances
- Instance state should be "Running"

---

### 10. Firewall Blocking Traffic

#### Symptoms
- Can SSH to server but cannot access API
- UFW shows rules but traffic still blocked

#### Solution

**Step 1: Check UFW status**
```bash
sudo ufw status verbose
```

**Step 2: Verify rules are correct**
```bash
# Should see:
# 22/tcp (SSH)
# 80/tcp (HTTP)
# 443/tcp (HTTPS) - if enabled
```

**Step 3: Add missing rules**
```bash
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
```

**Step 4: Check if UFW is enabled**
```bash
sudo ufw status
# If showing "inactive", enable it:
sudo ufw enable
```

**Step 5: Test connectivity**
```bash
curl http://localhost/api/health
curl -I http://YOUR_ELASTIC_IP/api/health
```

---

## Diagnostic Commands Reference

### Quick Diagnostics
```bash
# All-in-one diagnostic check
echo "=== Service Status ===" && \
sudo systemctl status xyzapp nginx -n 1 && \
echo "=== Port Listening ===" && \
sudo netstat -tlnp | grep -E ':5000|:80' && \
echo "=== Disk Usage ===" && \
df -h / && \
echo "=== Memory Usage ===" && \
free -h && \
echo "=== API Health ===" && \
curl http://localhost/api/health && \
echo ""
```

### Log Analysis
```bash
# Show recent errors
journalctl -u xyzapp --no-pager | tail -20

# Show errors only
journalctl -u xyzapp -p err

# Show for last hour
journalctl -u xyzapp --since "1 hour ago"
```

### Network Diagnostics
```bash
# Check if port is open
telnet localhost 80

# Check DNS resolution
nslookup $(ec2-metadata --public-ipv4 | cut -d " " -f 2)

# Check security group rules
curl -v http://localhost/api/health
```

---

## When to Scale/Upgrade

### Upgrade to Larger Instance
- CloudWatch CPU metric consistently > 80%
- Memory usage consistently > 80%
- Disk usage > 80%
- Response times > 2 seconds

### Actions
```bash
1. Create AMI from current instance
2. Launch new larger instance from AMI
3. Point Elastic IP to new instance
4. Test thoroughly
5. Keep old instance as backup
```

---

## Emergency Recovery

### Restore from Backup
```bash
# Restore database from backup
cp /home/ubuntu/xyzapp/projects.db.backup.YYYYMMDD \
   /home/ubuntu/xyzapp/projects.db

# Restart service
sudo systemctl restart xyzapp
```

### Rollback Application
```bash
# If app update broke things
git revert HEAD  # If using git
# or
cp /home/ubuntu/xyzapp/app.py.backup /home/ubuntu/xyzapp/app.py

# Restart service
sudo systemctl restart xyzapp
```

---

## Support Resources

- [Flask Documentation](https://flask.palletsprojects.com/)
- [Gunicorn Documentation](https://gunicorn.org/)
- [Nginx Documentation](https://nginx.org/)
- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)
- [SQLite Documentation](https://www.sqlite.org/docs.html)

---

**Need help?** Check logs first: `journalctl -u xyzapp -f`
