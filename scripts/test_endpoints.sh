#!/bin/bash

# XYZ Corp Project Management API - Testing Script
# Complete API endpoint testing and verification

# Configuration
API_URL="http://localhost"
API_PORT="80"
BASE_URL="$API_URL:$API_PORT"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

print_header() {
    echo -e "\n${BLUE}================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}================================${NC}"
}

print_test() {
    echo -e "\n${YELLOW}TEST: $1${NC}"
}

print_request() {
    echo -e "${YELLOW}Request:${NC}"
    echo "$1"
}

print_response() {
    echo -e "${YELLOW}Response:${NC}"
    echo "$1" | python3 -m json.tool 2>/dev/null || echo "$1"
}

test_passed() {
    echo -e "${GREEN}✓ PASSED: $1${NC}"
    ((TESTS_PASSED++))
}

test_failed() {
    echo -e "${RED}✗ FAILED: $1${NC}"
    ((TESTS_FAILED++))
}

# ============================================================================
# CONNECTIVITY TEST
# ============================================================================

print_header "CONNECTIVITY TEST"

print_test "Checking if API is accessible"
if curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/api/health"; then
    test_passed "API is accessible"
else
    test_failed "API is not accessible"
    echo -e "\n${RED}Cannot connect to API. Exiting.${NC}"
    exit 1
fi

# ============================================================================
# TEST 1: HEALTH CHECK
# ============================================================================

print_header "TEST 1: HEALTH CHECK"

print_test "GET /api/health"
RESPONSE=$(curl -s "$BASE_URL/api/health")
print_request "GET $BASE_URL/api/health"
print_response "$RESPONSE"

if echo "$RESPONSE" | grep -q "healthy"; then
    test_passed "Health check endpoint working"
else
    test_failed "Health check endpoint not working"
fi

# ============================================================================
# TEST 2: CREATE PROJECT
# ============================================================================

print_header "TEST 2: CREATE PROJECT"

print_test "POST /api/projects - Create 'Website Redesign' project"
REQUEST_DATA='{"name": "Website Redesign", "description": "XYZ Corp website modernization"}'
RESPONSE=$(curl -s -X POST "$BASE_URL/api/projects" \
    -H "Content-Type: application/json" \
    -d "$REQUEST_DATA")
print_request "POST $BASE_URL/api/projects\nBody: $REQUEST_DATA"
print_response "$RESPONSE"

# Extract project ID
PROJECT_ID=$(echo "$RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin)['data']['id'])" 2>/dev/null)

if [ ! -z "$PROJECT_ID" ] && [ "$PROJECT_ID" != "null" ]; then
    test_passed "Project created successfully (ID: $PROJECT_ID)"
else
    test_failed "Failed to create project"
    exit 1
fi

# ============================================================================
# TEST 3: GET ALL PROJECTS
# ============================================================================

print_header "TEST 3: GET ALL PROJECTS"

print_test "GET /api/projects - List all projects"
RESPONSE=$(curl -s "$BASE_URL/api/projects")
print_request "GET $BASE_URL/api/projects"
print_response "$RESPONSE"

if echo "$RESPONSE" | grep -q "Website Redesign"; then
    test_passed "Projects listed successfully"
else
    test_failed "Failed to list projects"
fi

# ============================================================================
# TEST 4: CREATE TASKS
# ============================================================================

print_header "TEST 4: CREATE TASKS"

print_test "POST /api/tasks - Create 'Design homepage' task"
REQUEST_DATA="{\"project_id\": $PROJECT_ID, \"title\": \"Design homepage\", \"status\": \"todo\", \"assigned_to\": \"John Doe\"}"
RESPONSE=$(curl -s -X POST "$BASE_URL/api/tasks" \
    -H "Content-Type: application/json" \
    -d "$REQUEST_DATA")
print_request "POST $BASE_URL/api/tasks\nBody: $REQUEST_DATA"
print_response "$RESPONSE"

# Extract task ID
TASK_ID=$(echo "$RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin)['data']['id'])" 2>/dev/null)

if [ ! -z "$TASK_ID" ] && [ "$TASK_ID" != "null" ]; then
    test_passed "Task created successfully (ID: $TASK_ID)"
else
    test_failed "Failed to create task"
    exit 1
fi

# ============================================================================
# TEST 5: GET PROJECT TASKS
# ============================================================================

print_header "TEST 5: GET PROJECT TASKS"

print_test "GET /api/projects/$PROJECT_ID/tasks - Get project tasks"
RESPONSE=$(curl -s "$BASE_URL/api/projects/$PROJECT_ID/tasks")
print_request "GET $BASE_URL/api/projects/$PROJECT_ID/tasks"
print_response "$RESPONSE"

if echo "$RESPONSE" | grep -q "Design homepage"; then
    test_passed "Project tasks retrieved successfully"
else
    test_failed "Failed to retrieve project tasks"
fi

# ============================================================================
# TEST 6: UPDATE TASK STATUS
# ============================================================================

print_header "TEST 6: UPDATE TASK STATUS"

print_test "PUT /api/tasks/$TASK_ID - Change status to 'in-progress'"
REQUEST_DATA="{\"status\": \"in-progress\"}"
RESPONSE=$(curl -s -X PUT "$BASE_URL/api/tasks/$TASK_ID" \
    -H "Content-Type: application/json" \
    -d "$REQUEST_DATA")
print_request "PUT $BASE_URL/api/tasks/$TASK_ID\nBody: $REQUEST_DATA"
print_response "$RESPONSE"

if echo "$RESPONSE" | grep -q "in-progress"; then
    test_passed "Task status updated successfully"
else
    test_failed "Failed to update task status"
fi

# ============================================================================
# TEST 7: CREATE ADDITIONAL TASKS
# ============================================================================

print_header "TEST 7: CREATE ADDITIONAL TASKS"

print_test "POST /api/tasks - Create multiple tasks"
for i in {1..3}; do
    REQUEST_DATA="{\"project_id\": $PROJECT_ID, \"title\": \"Task $i\", \"status\": \"todo\", \"assigned_to\": \"Developer $i\"}"
    RESPONSE=$(curl -s -X POST "$BASE_URL/api/tasks" \
        -H "Content-Type: application/json" \
        -d "$REQUEST_DATA")
    
    CREATED_TASK_ID=$(echo "$RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin)['data']['id'])" 2>/dev/null)
    
    if [ ! -z "$CREATED_TASK_ID" ] && [ "$CREATED_TASK_ID" != "null" ]; then
        test_passed "Additional task $i created (ID: $CREATED_TASK_ID)"
    else
        test_failed "Failed to create additional task $i"
    fi
done

# ============================================================================
# TEST 8: GET UPDATED PROJECT TASKS
# ============================================================================

print_header "TEST 8: GET UPDATED PROJECT TASKS"

print_test "GET /api/projects/$PROJECT_ID/tasks - Verify all tasks"
RESPONSE=$(curl -s "$BASE_URL/api/projects/$PROJECT_ID/tasks")
print_request "GET $BASE_URL/api/projects/$PROJECT_ID/tasks"
print_response "$RESPONSE"

TASK_COUNT=$(echo "$RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin)['count'])" 2>/dev/null)

if [ ! -z "$TASK_COUNT" ] && [ "$TASK_COUNT" -ge 4 ]; then
    test_passed "All tasks retrieved (Count: $TASK_COUNT)"
else
    test_failed "Failed to retrieve all tasks"
fi

# ============================================================================
# TEST 9: DELETE TASK
# ============================================================================

print_header "TEST 9: DELETE TASK"

print_test "DELETE /api/tasks/$TASK_ID - Delete the 'Design homepage' task"
RESPONSE=$(curl -s -X DELETE "$BASE_URL/api/tasks/$TASK_ID")
print_request "DELETE $BASE_URL/api/tasks/$TASK_ID"
print_response "$RESPONSE"

if echo "$RESPONSE" | grep -q "deleted"; then
    test_passed "Task deleted successfully"
else
    test_failed "Failed to delete task"
fi

# ============================================================================
# TEST 10: VERIFY DELETION
# ============================================================================

print_header "TEST 10: VERIFY DELETION"

print_test "GET /api/projects/$PROJECT_ID/tasks - Verify task was deleted"
RESPONSE=$(curl -s "$BASE_URL/api/projects/$PROJECT_ID/tasks")
print_request "GET $BASE_URL/api/projects/$PROJECT_ID/tasks"
print_response "$RESPONSE"

REMAINING_TASK_COUNT=$(echo "$RESPONSE" | python3 -c "import sys, json; print(json.load(sys.stdin)['count'])" 2>/dev/null)

if [ ! -z "$REMAINING_TASK_COUNT" ] && [ "$REMAINING_TASK_COUNT" -lt "$TASK_COUNT" ]; then
    test_passed "Task deletion verified (Remaining tasks: $REMAINING_TASK_COUNT)"
else
    test_failed "Failed to verify task deletion"
fi

# ============================================================================
# TEST 11: ERROR HANDLING - 404
# ============================================================================

print_header "TEST 11: ERROR HANDLING - 404"

print_test "GET /api/projects/99999 - Non-existent project"
RESPONSE=$(curl -s "$BASE_URL/api/projects/99999/tasks")
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "$BASE_URL/api/projects/99999/tasks")
print_request "GET $BASE_URL/api/projects/99999/tasks"
print_response "$RESPONSE"

if [ "$HTTP_CODE" = "404" ]; then
    test_passed "404 error handling working (HTTP: $HTTP_CODE)"
else
    test_failed "404 error handling not working (HTTP: $HTTP_CODE)"
fi

# ============================================================================
# TEST 12: ERROR HANDLING - 400
# ============================================================================

print_header "TEST 12: ERROR HANDLING - 400"

print_test "POST /api/tasks - Missing required field"
REQUEST_DATA="{\"project_id\": $PROJECT_ID, \"title\": \"Test\"}"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X POST "$BASE_URL/api/tasks" \
    -H "Content-Type: application/json" \
    -d "$REQUEST_DATA")
RESPONSE=$(curl -s -X POST "$BASE_URL/api/tasks" \
    -H "Content-Type: application/json" \
    -d "$REQUEST_DATA")
print_request "POST $BASE_URL/api/tasks\nBody: $REQUEST_DATA (missing 'status')"
print_response "$RESPONSE"

if [ "$HTTP_CODE" = "400" ]; then
    test_passed "400 error handling working (HTTP: $HTTP_CODE)"
else
    test_failed "400 error handling not working (HTTP: $HTTP_CODE)"
fi

# ============================================================================
# TEST SUMMARY
# ============================================================================

print_header "TEST SUMMARY"

TOTAL_TESTS=$((TESTS_PASSED + TESTS_FAILED))

echo -e "\n${GREEN}Tests Passed: $TESTS_PASSED${NC}"
echo -e "${RED}Tests Failed: $TESTS_FAILED${NC}"
echo -e "${BLUE}Total Tests: $TOTAL_TESTS${NC}"

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "\n${GREEN}✓ All tests passed!${NC}"
    exit 0
else
    echo -e "\n${RED}✗ Some tests failed!${NC}"
    exit 1
fi
