#!/bin/bash

# XYZ Corp API - Quick Reference Commands
# This file contains all commonly used commands

# ============================================================================
# SERVICE MANAGEMENT
# ============================================================================

# Flask/Gunicorn Service
echo "=== Flask/Gunicorn Service ==="
# Start
sudo systemctl start xyzapp

# Stop
sudo systemctl stop xyzapp

# Restart
sudo systemctl restart xyzapp

# Status
sudo systemctl status xyzapp

# Logs (real-time)
journalctl -u xyzapp -f

# Logs (last 50 lines)
journalctl -u xyzapp -n 50

# Enable on startup
sudo systemctl enable xyzapp

# ============================================================================
# NGINX SERVICE
# ============================================================================

echo "=== Nginx Service ==="
# Start
sudo systemctl start nginx

# Stop
sudo systemctl stop nginx

# Restart
sudo systemctl restart nginx

# Test configuration
sudo nginx -t

# Status
sudo systemctl status nginx

# Access logs
sudo tail -f /var/log/nginx/xyzapp_access.log

# Error logs
sudo tail -f /var/log/nginx/xyzapp_error.log

# ============================================================================
# UFW FIREWALL
# ============================================================================

echo "=== UFW Firewall ==="
# Check status
sudo ufw status

# Enable firewall
sudo ufw enable

# Disable firewall
sudo ufw disable

# Allow SSH
sudo ufw allow 22/tcp

# Allow HTTP
sudo ufw allow 80/tcp

# Allow HTTPS
sudo ufw allow 443/tcp

# Delete a rule
sudo ufw delete allow 443/tcp

# Show all rules
sudo ufw show added

# ============================================================================
# APPLICATION LOGS
# ============================================================================

echo "=== Application Logs ==="
# View access logs
tail -f /home/ubuntu/xyzapp/logs/access.log

# View error logs
tail -f /home/ubuntu/xyzapp/logs/error.log

# Clear logs (use with caution)
truncate -s 0 /home/ubuntu/xyzapp/logs/access.log
truncate -s 0 /home/ubuntu/xyzapp/logs/error.log

# Count log entries
wc -l /home/ubuntu/xyzapp/logs/*.log

# ============================================================================
# DATABASE MANAGEMENT
# ============================================================================

echo "=== Database Management ==="
# Connect to database
sqlite3 /home/ubuntu/xyzapp/projects.db

# View all tables
# (in sqlite3):
# .tables

# View projects
# SELECT * FROM projects;

# View tasks
# SELECT * FROM tasks;

# Backup database
cp /home/ubuntu/xyzapp/projects.db /home/ubuntu/xyzapp/projects.db.backup.$(date +%Y%m%d)

# Check database size
ls -lh /home/ubuntu/xyzapp/projects.db

# Restore database
# cp /home/ubuntu/xyzapp/projects.db.backup.YYYYMMDD /home/ubuntu/xyzapp/projects.db

# ============================================================================
# API TESTING
# ============================================================================

echo "=== API Testing ==="
# Health check
curl http://localhost/api/health

# Get all projects
curl http://localhost/api/projects

# Create project
curl -X POST http://localhost/api/projects \
  -H "Content-Type: application/json" \
  -d '{"name":"Test Project","description":"A test project"}'

# Get project tasks
curl http://localhost/api/projects/1/tasks

# Create task
curl -X POST http://localhost/api/tasks \
  -H "Content-Type: application/json" \
  -d '{
    "project_id": 1,
    "title": "Test Task",
    "status": "todo",
    "assigned_to": "John Doe"
  }'

# Update task
curl -X PUT http://localhost/api/tasks/1 \
  -H "Content-Type: application/json" \
  -d '{"status":"in-progress"}'

# Delete task
curl -X DELETE http://localhost/api/tasks/1

# Pretty print JSON response
curl -s http://localhost/api/projects | python3 -m json.tool

# ============================================================================
# SYSTEM INFORMATION
# ============================================================================

echo "=== System Information ==="
# Check CPU usage
top -bn1 | head -20

# Check memory usage
free -h

# Check disk usage
df -h

# Check current processes
ps aux | grep python

# Find process using port 5000
lsof -i :5000

# Find process using port 80
lsof -i :80

# ============================================================================
# FILE PERMISSIONS AND OWNERSHIP
# ============================================================================

echo "=== File Permissions ==="
# Change ownership to ubuntu
sudo chown -R ubuntu:ubuntu /home/ubuntu/xyzapp

# Set directory permissions
chmod 755 /home/ubuntu/xyzapp

# Set file permissions
chmod 644 /home/ubuntu/xyzapp/app.py

# Set executable permissions
chmod +x /home/ubuntu/xyzapp/scripts/*.sh

# ============================================================================
# ENVIRONMENT SETUP
# ============================================================================

echo "=== Environment Setup ==="
# Activate virtual environment
source /home/ubuntu/xyzapp/venv/bin/activate

# Deactivate virtual environment
deactivate

# Install package
pip install package_name

# Upgrade pip
pip install --upgrade pip

# Show installed packages
pip list

# Create requirements file
pip freeze > /home/ubuntu/xyzapp/requirements.txt

# ============================================================================
# NETWORKING
# ============================================================================

echo "=== Networking ==="
# Check instance IP
curl http://checkip.amazonaws.com/

# Check network interfaces
ip addr show

# Check routing table
route -n

# Ping test
ping -c 1 google.com

# DNS lookup
nslookup google.com

# ============================================================================
# CLOUDWATCH
# ============================================================================

echo "=== CloudWatch ==="
# Start CloudWatch Agent
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a start -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s

# Stop CloudWatch Agent
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a stop -m ec2 -s

# Check status
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a query -m ec2 -s

# View logs
sudo tail -f /opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log

# ============================================================================
# AWS CLI COMMANDS
# ============================================================================

echo "=== AWS CLI Commands ==="
# Get instance metadata
curl http://169.254.169.254/latest/meta-data/

# Get instance ID
ec2-metadata --instance-id

# Get availability zone
ec2-metadata --availability-zone

# List S3 buckets
aws s3 ls

# Upload file to S3
aws s3 cp /path/to/file s3://bucket-name/

# List CloudWatch metrics
aws cloudwatch list-metrics --namespace "XYZCorp/ProjectManagementAPI"

# Describe alarms
aws cloudwatch describe-alarms

# ============================================================================
# MAINTENANCE COMMANDS
# ============================================================================

echo "=== Maintenance ==="
# Update system packages
sudo apt update
sudo apt upgrade -y

# Clean up old packages
sudo apt autoremove -y

# Check system uptime
uptime

# Check system logs for errors
journalctl -p err -n 20

# Create full system backup (to S3)
# tar -czf backup.tar.gz /home/ubuntu/xyzapp
# aws s3 cp backup.tar.gz s3://backup-bucket/

# ============================================================================
# TROUBLESHOOTING
# ============================================================================

echo "=== Troubleshooting ==="
# Check service journal for errors
journalctl -u xyzapp -p err

# Check Nginx errors
sudo journalctl -u nginx -p err

# Restart all services
sudo systemctl restart xyzapp nginx

# Reset database (WARNING: Deletes all data)
# rm /home/ubuntu/xyzapp/projects.db

# Rebuild virtual environment
# rm -rf /home/ubuntu/xyzapp/venv
# python3 -m venv /home/ubuntu/xyzapp/venv
# source /home/ubuntu/xyzapp/venv/bin/activate
# pip install -r /home/ubuntu/xyzapp/requirements.txt

# ============================================================================
# USEFUL ALIASES (Add to ~/.bashrc)
# ============================================================================

echo "=== Useful Aliases to Add to ~/.bashrc ==="
# alias applog='journalctl -u xyzapp -f'
# alias appstatus='sudo systemctl status xyzapp'
# alias apprestart='sudo systemctl restart xyzapp'
# alias appdb='sqlite3 /home/ubuntu/xyzapp/projects.db'
# alias apptests='bash /home/ubuntu/xyzapp/scripts/test_endpoints.sh'
# alias apphealth='curl http://localhost/api/health | python3 -m json.tool'

echo ""
echo "=== QUICK REFERENCE READY ==="
echo "Copy and paste commands from above into your terminal"
echo "Replace YOUR_ELASTIC_IP with your actual Elastic IP address"
echo ""
