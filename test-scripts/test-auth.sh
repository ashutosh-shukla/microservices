#!/bin/bash

# Auth Service Testing Script
# Tests all authentication endpoints

echo "🔐 Testing Auth Service Endpoints..."
echo "===================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to test an endpoint
test_endpoint() {
    local test_name="$1"
    local method="$2"
    local url="$3"
    local data="$4"
    local expected_status="$5"
    
    echo -e "${BLUE}Testing: $test_name${NC}"
    
    if [ -n "$data" ]; then
        response=$(curl -s -w "HTTPSTATUS:%{http_code}" -X "$method" "$url" \
            -H "Content-Type: application/json" \
            -d "$data")
    else
        response=$(curl -s -w "HTTPSTATUS:%{http_code}" -X "$method" "$url")
    fi
    
    # Extract status code and body
    status_code=$(echo $response | grep -o "HTTPSTATUS:[0-9]*" | cut -d: -f2)
    body=$(echo $response | sed 's/HTTPSTATUS:[0-9]*$//')
    
    if [ "$status_code" = "$expected_status" ]; then
        echo -e "${GREEN}✓ $test_name - Status: $status_code${NC}"
        if [ -n "$body" ] && [ "$body" != "null" ]; then
            echo "Response: $body" | jq '.' 2>/dev/null || echo "Response: $body"
        fi
    else
        echo -e "${RED}✗ $test_name - Expected: $expected_status, Got: $status_code${NC}"
        echo "Response: $body"
    fi
    echo
}

# Test Variables
AUTH_BASE="http://localhost:8085"
GATEWAY_BASE="http://localhost:8080"

echo "Testing Auth Service Direct Endpoints..."
echo "======================================="

# 1. Health Check
test_endpoint "Auth Health Check" "GET" "$AUTH_BASE/auth/health" "" "200"

# 2. Admin Registration
ADMIN_DATA='{
    "firstName": "Test",
    "lastName": "Admin",
    "email": "testadmin@bank.com",
    "password": "admin123"
}'
test_endpoint "Admin Registration" "POST" "$AUTH_BASE/auth/admin/register" "$ADMIN_DATA" "200"

# 3. Customer Registration (via customer service)
CUSTOMER_DATA='{
    "firstName": "Test",
    "lastName": "Customer",
    "email": "testcustomer@bank.com",
    "phoneNumber": "1234567890",
    "address": "123 Test St",
    "dateOfBirth": "1990-01-01",
    "password": "customer123",
    "role": "CUSTOMER"
}'
test_endpoint "Customer Registration" "POST" "http://localhost:8081/customers/register" "$CUSTOMER_DATA" "200"

# Wait for registration to complete
sleep 2

# 4. Admin Login
ADMIN_LOGIN='{
    "email": "testadmin@bank.com",
    "password": "admin123"
}'
echo -e "${BLUE}Testing: Admin Login and Token Extraction${NC}"
login_response=$(curl -s -X POST "$AUTH_BASE/auth/login" \
    -H "Content-Type: application/json" \
    -d "$ADMIN_LOGIN")

if echo "$login_response" | jq -e '.success' >/dev/null 2>&1; then
    ADMIN_TOKEN=$(echo "$login_response" | jq -r '.token')
    echo -e "${GREEN}✓ Admin Login Successful${NC}"
    echo "Admin Token: ${ADMIN_TOKEN:0:50}..."
else
    echo -e "${RED}✗ Admin Login Failed${NC}"
    echo "Response: $login_response"
fi
echo

# 5. Customer Login
CUSTOMER_LOGIN='{
    "email": "testcustomer@bank.com",
    "password": "customer123"
}'
echo -e "${BLUE}Testing: Customer Login and Token Extraction${NC}"
customer_login_response=$(curl -s -X POST "$AUTH_BASE/auth/login" \
    -H "Content-Type: application/json" \
    -d "$CUSTOMER_LOGIN")

if echo "$customer_login_response" | jq -e '.success' >/dev/null 2>&1; then
    CUSTOMER_TOKEN=$(echo "$customer_login_response" | jq -r '.token')
    CUSTOMER_ID=$(echo "$customer_login_response" | jq -r '.userId')
    echo -e "${GREEN}✓ Customer Login Successful${NC}"
    echo "Customer Token: ${CUSTOMER_TOKEN:0:50}..."
    echo "Customer ID: $CUSTOMER_ID"
else
    echo -e "${RED}✗ Customer Login Failed${NC}"
    echo "Response: $customer_login_response"
fi
echo

# 6. Token Validation
if [ -n "$ADMIN_TOKEN" ]; then
    TOKEN_VALIDATION='{
        "token": "'$ADMIN_TOKEN'"
    }'
    test_endpoint "Admin Token Validation" "POST" "$AUTH_BASE/auth/validate-token" "$TOKEN_VALIDATION" "200"
fi

if [ -n "$CUSTOMER_TOKEN" ]; then
    TOKEN_VALIDATION='{
        "token": "'$CUSTOMER_TOKEN'"
    }'
    test_endpoint "Customer Token Validation" "POST" "$AUTH_BASE/auth/validate-token" "$TOKEN_VALIDATION" "200"
fi

# 7. Invalid Login
INVALID_LOGIN='{
    "email": "wrong@email.com",
    "password": "wrongpassword"
}'
test_endpoint "Invalid Login" "POST" "$AUTH_BASE/auth/login" "$INVALID_LOGIN" "400"

echo "Testing API Gateway Auth Endpoints..."
echo "====================================="

# 8. Gateway Health Checks
test_endpoint "Gateway Auth Health" "GET" "$GATEWAY_BASE/health/auth" "" "200"

# 9. Gateway Login
test_endpoint "Gateway Admin Login" "POST" "$GATEWAY_BASE/auth/login" "$ADMIN_LOGIN" "200"

# 10. Gateway Admin Registration
NEW_ADMIN_DATA='{
    "firstName": "Gateway",
    "lastName": "Admin",
    "email": "gatewayadmin@bank.com",
    "password": "admin123"
}'
test_endpoint "Gateway Admin Registration" "POST" "$GATEWAY_BASE/auth/admin/register" "$NEW_ADMIN_DATA" "200"

echo "Testing Protected Routes..."
echo "=========================="

# 11. Test protected route with valid token
if [ -n "$CUSTOMER_TOKEN" ] && [ -n "$CUSTOMER_ID" ]; then
    echo -e "${BLUE}Testing: Protected Customer Route${NC}"
    protected_response=$(curl -s -w "HTTPSTATUS:%{http_code}" \
        -H "Authorization: Bearer $CUSTOMER_TOKEN" \
        "$GATEWAY_BASE/customers/$CUSTOMER_ID")
    
    status_code=$(echo $protected_response | grep -o "HTTPSTATUS:[0-9]*" | cut -d: -f2)
    
    if [ "$status_code" = "200" ]; then
        echo -e "${GREEN}✓ Protected Customer Route Access${NC}"
    else
        echo -e "${RED}✗ Protected Customer Route Failed - Status: $status_code${NC}"
    fi
    echo
fi

# 12. Test admin route with customer token (should fail)
if [ -n "$CUSTOMER_TOKEN" ]; then
    echo -e "${BLUE}Testing: Customer accessing Admin Route (should fail)${NC}"
    admin_access_response=$(curl -s -w "HTTPSTATUS:%{http_code}" \
        -H "Authorization: Bearer $CUSTOMER_TOKEN" \
        "$GATEWAY_BASE/admin/dashboard")
    
    status_code=$(echo $admin_access_response | grep -o "HTTPSTATUS:[0-9]*" | cut -d: -f2)
    
    if [ "$status_code" = "403" ]; then
        echo -e "${GREEN}✓ Customer correctly denied admin access${NC}"
    else
        echo -e "${RED}✗ Customer access control failed - Status: $status_code${NC}"
    fi
    echo
fi

# 13. Test route without token (should fail)
echo -e "${BLUE}Testing: Protected Route without Token (should fail)${NC}"
no_token_response=$(curl -s -w "HTTPSTATUS:%{http_code}" \
    "$GATEWAY_BASE/customers/test")

status_code=$(echo $no_token_response | grep -o "HTTPSTATUS:[0-9]*" | cut -d: -f2)

if [ "$status_code" = "401" ]; then
    echo -e "${GREEN}✓ Correctly denied access without token${NC}"
else
    echo -e "${RED}✗ Token requirement not enforced - Status: $status_code${NC}"
fi
echo

echo "🎉 Auth Testing Complete!"
echo "========================"
echo "Tokens for further testing:"
if [ -n "$ADMIN_TOKEN" ]; then
    echo "Admin Token: $ADMIN_TOKEN"
fi
if [ -n "$CUSTOMER_TOKEN" ]; then
    echo "Customer Token: $CUSTOMER_TOKEN"
    echo "Customer ID: $CUSTOMER_ID"
fi