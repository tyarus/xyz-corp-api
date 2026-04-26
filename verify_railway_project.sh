#!/bin/bash

# Project Verification - Railway.app Version
# Run this to verify all Railway-ready files

echo "=========================================="
echo "XYZ Corp API - Railway.app Project"
echo "File Verification"
echo "=========================================="

PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MISSING_FILES=0

check_file() {
    if [ -f "$1" ]; then
        echo "✓ $(basename "$1")"
    else
        echo "✗ $(basename "$1") - MISSING"
        ((MISSING_FILES++))
    fi
}

echo ""
echo "📚 Documentation Files:"
echo "---"
check_file "$PROJECT_DIR/START_HERE.md"
check_file "$PROJECT_DIR/README.md"
check_file "$PROJECT_DIR/RAILWAY_SETUP_GUIDE.md"
check_file "$PROJECT_DIR/PROJECT_SUMMARY.md"
check_file "$PROJECT_DIR/RAILWAY_DEPLOYMENT_CHECKLIST.md"
check_file "$PROJECT_DIR/TROUBLESHOOTING.md"
check_file "$PROJECT_DIR/QUICK_REFERENCE.md"

echo ""
echo "🚀 Railway.app Files:"
echo "---"
check_file "$PROJECT_DIR/app.py"
check_file "$PROJECT_DIR/requirements.txt"
check_file "$PROJECT_DIR/Procfile"
check_file "$PROJECT_DIR/railway.json"

echo ""
echo "🐳 Docker Files (Optional):"
echo "---"
check_file "$PROJECT_DIR/Dockerfile"
check_file "$PROJECT_DIR/docker-compose.yml"

echo ""
echo "⚙️  Configuration Files:"
echo "---"
check_file "$PROJECT_DIR/configs/xyzapp.service"
check_file "$PROJECT_DIR/configs/nginx_config"
check_file "$PROJECT_DIR/configs/cloudwatch_config.json"

echo ""
echo "🛠️  Scripts:"
echo "---"
check_file "$PROJECT_DIR/scripts/railway-deploy.sh"
check_file "$PROJECT_DIR/scripts/test_endpoints.sh"
check_file "$PROJECT_DIR/scripts/setup.sh"
check_file "$PROJECT_DIR/scripts/cloudwatch_setup.sh"
check_file "$PROJECT_DIR/scripts/backup_restore.sh"
check_file "$PROJECT_DIR/scripts/docker-start.sh"

echo ""
echo "=========================================="
if [ $MISSING_FILES -eq 0 ]; then
    echo "✅ All Railway.app files present!"
    echo "=========================================="
    echo ""
    echo "🚀 Next Steps:"
    echo "1. Read: START_HERE.md"
    echo "2. Follow: RAILWAY_SETUP_GUIDE.md"
    echo "3. Deploy to Railway.app"
    echo ""
else
    echo "⚠️  $MISSING_FILES file(s) missing"
    echo "=========================================="
fi

exit $MISSING_FILES
