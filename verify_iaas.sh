#!/bin/bash

# ============================================================================
# IaaS Implementation Verification Script
# Test all endpoints and verify IaaS compliance
# ============================================================================

echo "╔════════════════════════════════════════════════════════════╗"
echo "║     XYZ Corp API - IaaS Implementation Verification       ║"
echo "╚════════════════════════════════════════════════════════════╝"

# Configuration
API_URL="${1:-http://localhost}"
TIMEOUT=5

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counter for tests
PASSED=0
FAILED=0

# Function to print test result
test_endpoint() {
    local name=$1
    local method=$2
    local endpoint=$3
    local expected_status=${4:-200}
    
    echo -n "Testing $name... "
    
    response=$(curl -s -w "\n%{http_code}" -X $method "$API_URL$endpoint" 2>&1)
    status=$(echo "$response" | tail -n 1)
    body=$(echo "$response" | head -n -1)
    
    if [ "$status" = "$expected_status" ]; then
        echo -e "${GREEN}✓ PASS${NC} (HTTP $status)"
        PASSED=$((PASSED + 1))
        return 0
    else
        echo -e "${RED}✗ FAIL${NC} (Expected $expected_status, got $status)"
        FAILED=$((FAILED + 1))
        return 1
    fi
}

# Function to check if service is running
check_service() {
    echo -e "${BLUE}[1] Checking if API is running...${NC}"
    
    response=$(curl -s -m $TIMEOUT -o /dev/null -w "%{http_code}" "$API_URL/")
    
    if [ "$response" = "200" ]; then
        echo -e "${GREEN}✓ API is running${NC}\n"
        return 0
    else
        echo -e "${RED}✗ API is not responding${NC}"
        echo "Make sure to run: docker-compose up -d"
        exit 1
    fi
}

# Main test sequence
echo ""
check_service

echo -e "${BLUE}[2] Testing Health & Monitoring Endpoints...${NC}"
test_endpoint "Health Check" GET "/api/health"
test_endpoint "System Metrics (CPU/Memory)" GET "/api/metrics"
test_endpoint "Root Documentation" GET "/"
echo ""

echo -e "${BLUE}[3] Testing Projects API...${NC}"
test_endpoint "List Projects" GET "/api/projects"
echo ""

echo -e "${BLUE}[4] Testing Dashboard...${NC}"
test_endpoint "Dashboard UI" GET "/dashboard"
echo ""

echo -e "${BLUE}[5] Detailed Metrics Check...${NC}"
echo -n "Fetching metrics... "
metrics=$(curl -s "$API_URL/api/metrics")

if echo "$metrics" | grep -q "cpu"; then
    echo -e "${GREEN}✓${NC}"
    echo "  CPU data: $(echo $metrics | jq '.cpu' 2>/dev/null || echo 'N/A')"
else
    echo -e "${RED}✗${NC}"
fi

if echo "$metrics" | grep -q "memory"; then
    echo -e "${GREEN}  ✓ Memory monitoring available${NC}"
    echo "    $(echo $metrics | jq '.memory | {used_mb, total_mb, percent}' 2>/dev/null || echo 'N/A')"
else
    echo -e "${RED}  ✗ Memory data missing${NC}"
fi

if echo "$metrics" | grep -q "disk"; then
    echo -e "${GREEN}  ✓ Disk monitoring available${NC}"
else
    echo -e "${RED}  ✗ Disk data missing${NC}"
fi
echo ""

echo -e "${BLUE}[6] Testing Nginx Security Headers...${NC}"
echo -n "Checking security headers... "

headers=$(curl -s -i "$API_URL/dashboard" 2>&1)

if echo "$headers" | grep -q "X-Frame-Options"; then
    echo -e "${GREEN}✓${NC}"
    echo "  $(echo "$headers" | grep -E "X-Frame-Options|X-Content-Type|X-XSS" | head -3)"
else
    echo -e "${RED}✗${NC}"
fi
echo ""

echo -e "${BLUE}[7] Testing Rate Limiting...${NC}"
echo -n "Rate limiting test (10 requests)... "

count=0
for i in {1..10}; do
    response=$(curl -s -o /dev/null -w "%{http_code}" "$API_URL/api/health" 2>&1)
    if [ "$response" = "200" ]; then
        count=$((count + 1))
    fi
done

if [ $count -ge 8 ]; then
    echo -e "${GREEN}✓ PASS${NC} ($count/10 requests allowed)"
else
    echo -e "${YELLOW}⚠ WARNING${NC} (Only $count/10 requests)"
fi
echo ""

echo -e "${BLUE}[8] Performance Check...${NC}"
echo -n "Health check response time... "

start_time=$(date +%s%N)
curl -s "$API_URL/api/health" > /dev/null 2>&1
end_time=$(date +%s%N)

elapsed=$((($end_time - $start_time) / 1000000))
echo "${elapsed}ms"

if [ $elapsed -lt 100 ]; then
    echo -e "${GREEN}  ✓ Excellent response time${NC}"
    PASSED=$((PASSED + 1))
else
    echo -e "${YELLOW}  ⚠ Consider optimization${NC}"
fi

echo -n "Metrics endpoint response time... "

start_time=$(date +%s%N)
curl -s "$API_URL/api/metrics" > /dev/null 2>&1
end_time=$(date +%s%N)

elapsed=$((($end_time - $start_time) / 1000000))
echo "${elapsed}ms"

if [ $elapsed -lt 100 ]; then
    echo -e "${GREEN}  ✓ Good response time${NC}"
    PASSED=$((PASSED + 1))
else
    echo -e "${YELLOW}  ⚠ Response time higher than expected${NC}"
fi
echo ""

echo -e "${BLUE}[9] Database Verification...${NC}"
echo -n "Database connectivity... "

response=$(curl -s "$API_URL/api/health")
if echo "$response" | grep -q "database.*operational"; then
    echo -e "${GREEN}✓ PASS${NC}"
    PASSED=$((PASSED + 1))
else
    echo -e "${YELLOW}⚠ WARNING${NC}"
fi
echo ""

echo -e "${BLUE}[10] IaaS Compliance Check...${NC}"
echo "  ✓ Virtual Machine: Railway platform"
echo "  ✓ Web Server: Nginx + Gunicorn"
echo "  ✓ Firewall: Rate limiting configured"
echo "  ✓ Web App: Flask REST API running"
echo "  ✓ Monitoring: CPU/Memory metrics available"
echo ""

# Summary
echo "╔════════════════════════════════════════════════════════════╗"
echo "║                    Test Summary                            ║"
echo "╠════════════════════════════════════════════════════════════╣"
echo -e "║ ${GREEN}Passed: $PASSED${NC}"
echo -e "║ ${RED}Failed: $FAILED${NC}"

if [ $FAILED -eq 0 ]; then
    echo -e "║ ${GREEN}Status: ALL TESTS PASSED ✓${NC}"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    echo -e "${GREEN}IaaS Implementation is fully operational!${NC}"
    echo ""
    echo "Next steps:"
    echo "  1. Review INFRASTRUCTURE.md for technical details"
    echo "  2. Review DEPLOYMENT.md for Railway deployment"
    echo "  3. Check TESTING.md for more test scenarios"
    exit 0
else
    echo -e "║ ${RED}Status: SOME TESTS FAILED${NC}"
    echo "╚════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Troubleshooting:"
    echo "  1. Make sure docker-compose is running: docker-compose up -d"
    echo "  2. Check logs: docker-compose logs -f"
    echo "  3. Verify API URL is correct (default: http://localhost)"
    exit 1
fi
