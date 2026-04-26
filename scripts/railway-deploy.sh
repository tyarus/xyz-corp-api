#!/bin/bash

# Railway.app Quick Start Guide
# Deploy XYZ Corp API to Railway.app

echo "=========================================="
echo "XYZ Corp API - Railway.app Deployment"
echo "=========================================="

echo ""
echo "PREREQUISITES:"
echo "- GitHub account with your xyz-corp-api repository"
echo "- Railway.app account"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# ============================================================================
# STEP 1: Initialize Git Repository
# ============================================================================

echo -e "${YELLOW}STEP 1: Initialize Git Repository${NC}"
echo "=================================="

# Check if git is installed
if ! command -v git &> /dev/null; then
    echo "Git not installed. Installing..."
    # Installation command depends on OS
    echo "Please install Git from https://git-scm.com/"
    exit 1
fi

# Initialize git if not already done
if [ ! -d ".git" ]; then
    echo "Initializing git repository..."
    git init
    git add .
    git commit -m "Initial commit: XYZ Corp API project"
    echo -e "${GREEN}✓ Git repository initialized${NC}"
else
    echo -e "${GREEN}✓ Git repository already exists${NC}"
fi

# ============================================================================
# STEP 2: Add Remote Repository
# ============================================================================

echo ""
echo -e "${YELLOW}STEP 2: Add GitHub Remote${NC}"
echo "============================"

read -p "Enter your GitHub repository URL: " github_url

if [ ! -z "$github_url" ]; then
    git remote add origin "$github_url" 2>/dev/null || git remote set-url origin "$github_url"
    git branch -M main
    git push -u origin main
    echo -e "${GREEN}✓ Repository pushed to GitHub${NC}"
else
    echo "GitHub URL required"
    exit 1
fi

# ============================================================================
# STEP 3: Verify Railway.app Files
# ============================================================================

echo ""
echo -e "${YELLOW}STEP 3: Verify Required Files${NC}"
echo "=============================="

files_needed=("Procfile" "requirements.txt" "app.py")
all_ok=true

for file in "${files_needed[@]}"; do
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓ $file${NC}"
    else
        echo "✗ $file - MISSING"
        all_ok=false
    fi
done

if [ "$all_ok" = false ]; then
    echo ""
    echo "Some files are missing. Please ensure all required files exist."
    exit 1
fi

# ============================================================================
# STEP 4: Display Railway Setup Instructions
# ============================================================================

echo ""
echo -e "${YELLOW}STEP 4: Connect to Railway.app${NC}"
echo "==============================="

echo ""
echo "Now follow these steps in Railway.app dashboard:"
echo ""
echo "1. Go to https://railway.app"
echo "2. Sign up / Sign in (preferably with GitHub)"
echo "3. Click 'New Project'"
echo "4. Select 'Deploy from GitHub repo'"
echo "5. Connect your GitHub account"
echo "6. Select 'xyz-corp-api' repository"
echo "7. Click 'Deploy'"
echo ""
echo "Railway will automatically:"
echo "  ✓ Detect Python project"
echo "  ✓ Build Docker container"
echo "  ✓ Deploy your application"
echo "  ✓ Assign public domain"
echo ""

# ============================================================================
# STEP 5: Test Deployment
# ============================================================================

echo -e "${YELLOW}STEP 5: Test Your Deployment${NC}"
echo "============================"

read -p "Enter your Railway domain (e.g., https://xyz-corp-api-production.up.railway.app): " domain

if [ ! -z "$domain" ]; then
    echo ""
    echo "Testing API endpoints..."
    echo ""
    
    # Health check
    echo "1. Testing health endpoint..."
    health_response=$(curl -s "$domain/api/health")
    if echo "$health_response" | grep -q "healthy"; then
        echo -e "${GREEN}✓ Health check passed${NC}"
    else
        echo "✗ Health check failed"
    fi
    
    # Create project
    echo ""
    echo "2. Testing create project..."
    project_response=$(curl -s -X POST "$domain/api/projects" \
        -H "Content-Type: application/json" \
        -d '{"name":"Test Project","description":"Testing Railway deployment"}')
    
    if echo "$project_response" | grep -q "success"; then
        echo -e "${GREEN}✓ Project creation passed${NC}"
        project_id=$(echo "$project_response" | grep -o '"id":[0-9]*' | head -1 | grep -o '[0-9]*')
        echo "  Project ID: $project_id"
    else
        echo "✗ Project creation failed"
    fi
    
    echo ""
    echo "Test complete!"
else
    echo "Domain not provided. You can test later manually."
fi

# ============================================================================
# STEP 6: Display Summary
# ============================================================================

echo ""
echo -e "${GREEN}=========================================="
echo "Railway.app Deployment Complete! 🚀"
echo "==========================================${NC}"
echo ""
echo "Your API is now live!"
echo ""
echo "Quick Reference:"
echo "  Documentation: RAILWAY_SETUP_GUIDE.md"
echo "  Repository: $github_url"
echo "  Dashboard: https://railway.app/dashboard"
echo ""
echo "Next time you push to GitHub:"
echo "  git push"
echo "  Railway will automatically redeploy! ✨"
echo ""
