#!/bin/bash

# Project File Verification Script
# Run this to verify all project files are in place

echo "=========================================="
echo "XYZ Corp API - Project File Verification"
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
echo "Documentation Files:"
echo "-------------------"
check_file "$PROJECT_DIR/README.md"
check_file "$PROJECT_DIR/PROJECT_SUMMARY.md"
check_file "$PROJECT_DIR/AWS_SETUP_GUIDE.md"
check_file "$PROJECT_DIR/DEPLOYMENT_CHECKLIST.md"
check_file "$PROJECT_DIR/TROUBLESHOOTING.md"
check_file "$PROJECT_DIR/QUICK_REFERENCE.md"

echo ""
echo "Application Files:"
echo "-----------------"
check_file "$PROJECT_DIR/app.py"
check_file "$PROJECT_DIR/requirements.txt"

echo ""
echo "Configuration Files:"
echo "-------------------"
check_file "$PROJECT_DIR/configs/xyzapp.service"
check_file "$PROJECT_DIR/configs/nginx_config"
check_file "$PROJECT_DIR/configs/cloudwatch_config.json"

echo ""
echo "Scripts:"
echo "--------"
check_file "$PROJECT_DIR/scripts/setup.sh"
check_file "$PROJECT_DIR/scripts/test_endpoints.sh"
check_file "$PROJECT_DIR/scripts/cloudwatch_setup.sh"
check_file "$PROJECT_DIR/scripts/backup_restore.sh"
check_file "$PROJECT_DIR/scripts/docker-start.sh"

echo ""
echo "Docker Files (Bonus):"
echo "-------------------"
check_file "$PROJECT_DIR/Dockerfile"
check_file "$PROJECT_DIR/docker-compose.yml"

echo ""
echo "=========================================="
if [ $MISSING_FILES -eq 0 ]; then
    echo "✓ All files present and ready!"
    echo "=========================================="
    echo ""
    echo "Next Steps:"
    echo "1. Read PROJECT_SUMMARY.md for overview"
    echo "2. Follow AWS_SETUP_GUIDE.md to create EC2"
    echo "3. Run setup.sh on your EC2 instance"
    echo "4. Run test_endpoints.sh to verify"
    echo ""
else
    echo "✗ $MISSING_FILES file(s) missing!"
    echo "=========================================="
fi

exit $MISSING_FILES
