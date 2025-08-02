#!/bin/bash

# Complete Banking Application Testing Script
# Tests all services with direct calls and gateway calls

echo "🏦 Complete SecureBank API Testing..."
echo "===================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Service URLs
AUTH_SERVICE="http://localhost:8085"
CUSTOMER_SERVICE="http://localhost:8081"
ACCOUNT_SERVICE="http://localhost:8082"
KYC_SERVICE="http://localhost:8083"
ADMIN_SERVICE="http://localhost:8084"
GATEWAY="http://localhost:8080"

# Global variables for tokens and IDs
ADMIN_TOKEN=""
CUSTOMER_TOKEN=""
CUSTOMER_ID=""
ADMIN_ID=""

# Function to test an endpoint
test_endpoint() {
    local test_name="$1"
    local method="$2"
    local url="$3"
    local data="$4"
    local expected_status="$5"
    local headers="$6"
    
    echo -e "${BLUE}Testing: $test_name${NC}"
    
    local curl_cmd="curl -s -w HTTPSTATUS:%{http_code} -X $method $url"
    
    if [ -n "$headers" ]; then
        curl_cmd="$curl_cmd $headers"
    fi
    
    if [ -n "$data" ]; then
        curl_cmd="$curl_cmd -H 'Content-Type: application/json' -d '$data'"
    fi
    
    response=$(eval $curl_cmd)
    
    # Extract status code and body
    status_code=$(echo $response | grep -o "HTTPSTATUS:[0-9]*" | cut -d: -f2)
    body=$(echo $response | sed 's/HTTPSTATUS:[0-9]*$//')
    
    if [ "$status_code" = "$expected_status" ]; then
        echo -e "${GREEN}✓ $test_name - Status: $status_code${NC}"
        if [ -n "$body" ] && [ "$body" != "null" ] && [ "$body" != "" ]; then
            echo "Response: $body" | jq '.' 2>/dev/null || echo "Response: $body"
        fi
        return 0
    else
        echo -e "${RED}✗ $test_name - Expected: $expected_status, Got: $status_code${NC}"
        echo "Response: $body"
        return 1
    fi
}

# Function to get JWT token
get_jwt_token() {
    local email="$1"
    local password="$2"
    local service_url="$3"
    
    local login_data="{\"email\":\"$email\",\"password\":\"$password\"}"
    local response=$(curl -s -X POST "$service_url/auth/login" \
        -H "Content-Type: application/json" \
        -d "$login_data")
    
    if echo "$response" | jq -e '.success' >/dev/null 2>&1; then
        echo "$response" | jq -r '.token'
    else
        echo ""
    fi
}

# Function to get user ID from token response
get_user_id() {
    local email="$1"
    local password="$2"
    local service_url="$3"
    
    local login_data="{\"email\":\"$email\",\"password\":\"$password\"}"
    local response=$(curl -s -X POST "$service_url/auth/login" \
        -H "Content-Type: application/json" \
        -d "$login_data")
    
    if echo "$response" | jq -e '.success' >/dev/null 2>&1; then
        echo "$response" | jq -r '.userId'
    else
        echo ""
    fi
}

echo "1. Testing Service Health Checks..."
echo "================================="

# Test all service health checks
test_endpoint "Auth Service Health" "GET" "$AUTH_SERVICE/auth/health" "" "200"
test_endpoint "Customer Service Health" "GET" "$CUSTOMER_SERVICE/customers/hello" "" "200"
test_endpoint "Gateway Health - Auth" "GET" "$GATEWAY/health/auth" "" "200"
test_endpoint "Gateway Health - Customer" "GET" "$GATEWAY/health/customer" "" "200"
test_endpoint "Gateway Health - Account" "GET" "$GATEWAY/health/account" "" "200"
test_endpoint "Gateway Health - KYC" "GET" "$GATEWAY/health/kyc" "" "200"
test_endpoint "Gateway Health - Admin" "GET" "$GATEWAY/health/admin" "" "200"

echo
echo "2. Testing User Registration..."
echo "=============================="

# Admin Registration
ADMIN_DATA='{
    "firstName": "Test",
    "lastName": "Admin",
    "email": "testadmin@bank.com",
    "password": "admin123"
}'

test_endpoint "Admin Registration (Direct)" "POST" "$AUTH_SERVICE/auth/admin/register" "$ADMIN_DATA" "200"
test_endpoint "Admin Registration (Gateway)" "POST" "$GATEWAY/auth/admin/register" "$ADMIN_DATA" "200"

# Customer Registration
CUSTOMER_DATA='{
    "firstName": "Test",
    "lastName": "Customer",
    "email": "testcustomer@bank.com",
    "phoneNumber": "1234567890",
    "address": "123 Test St, Test City",
    "dateOfBirth": "1990-01-01",
    "password": "customer123",
    "role": "CUSTOMER"
}'

test_endpoint "Customer Registration (Direct)" "POST" "$CUSTOMER_SERVICE/customers/register" "$CUSTOMER_DATA" "200"
test_endpoint "Customer Registration (Gateway)" "POST" "$GATEWAY/customers/register" "$CUSTOMER_DATA" "200"

# Wait for registration to complete
sleep 3

echo
echo "3. Testing Authentication..."
echo "==========================="

# Admin Login
echo -e "${PURPLE}Getting Admin JWT Token...${NC}"
ADMIN_TOKEN=$(get_jwt_token "testadmin@bank.com" "admin123" "$AUTH_SERVICE")
ADMIN_ID=$(get_user_id "testadmin@bank.com" "admin123" "$AUTH_SERVICE")

if [ -n "$ADMIN_TOKEN" ]; then
    echo -e "${GREEN}✓ Admin token obtained: ${ADMIN_TOKEN:0:50}...${NC}"
    echo -e "${GREEN}✓ Admin ID: $ADMIN_ID${NC}"
else
    echo -e "${RED}✗ Failed to get admin token${NC}"
fi

# Customer Login
echo -e "${PURPLE}Getting Customer JWT Token...${NC}"
CUSTOMER_TOKEN=$(get_jwt_token "testcustomer@bank.com" "customer123" "$AUTH_SERVICE")
CUSTOMER_ID=$(get_user_id "testcustomer@bank.com" "customer123" "$AUTH_SERVICE")

if [ -n "$CUSTOMER_TOKEN" ]; then
    echo -e "${GREEN}✓ Customer token obtained: ${CUSTOMER_TOKEN:0:50}...${NC}"
    echo -e "${GREEN}✓ Customer ID: $CUSTOMER_ID${NC}"
else
    echo -e "${RED}✗ Failed to get customer token${NC}"
fi

# Test token validation
if [ -n "$ADMIN_TOKEN" ]; then
    TOKEN_VALIDATION="{\"token\":\"$ADMIN_TOKEN\"}"
    test_endpoint "Admin Token Validation" "POST" "$AUTH_SERVICE/auth/validate-token" "$TOKEN_VALIDATION" "200"
fi

if [ -n "$CUSTOMER_TOKEN" ]; then
    TOKEN_VALIDATION="{\"token\":\"$CUSTOMER_TOKEN\"}"
    test_endpoint "Customer Token Validation" "POST" "$AUTH_SERVICE/auth/validate-token" "$TOKEN_VALIDATION" "200"
fi

echo
echo "4. Testing Customer Service APIs..."
echo "=================================="

if [ -n "$CUSTOMER_TOKEN" ] && [ -n "$CUSTOMER_ID" ]; then
    # Direct Customer Service Calls
    test_endpoint "Get Customer (Direct)" "GET" "$CUSTOMER_SERVICE/customers/$CUSTOMER_ID" "" "200"
    
    # Gateway Customer Service Calls
    CUSTOMER_AUTH_HEADER="-H 'Authorization: Bearer $CUSTOMER_TOKEN'"
    test_endpoint "Get Customer (Gateway)" "GET" "$GATEWAY/customers/$CUSTOMER_ID" "" "200" "$CUSTOMER_AUTH_HEADER"
    
    # Update Customer
    UPDATE_DATA='{
        "firstName": "Updated",
        "lastName": "Customer",
        "address": "456 Updated St",
        "phoneNumber": "0987654321",
        "status": "ACTIVE"
    }'
    test_endpoint "Update Customer (Gateway)" "PUT" "$GATEWAY/customers/$CUSTOMER_ID" "$UPDATE_DATA" "200" "$CUSTOMER_AUTH_HEADER"
    
    # Change Password
    test_endpoint "Change Password (Gateway)" "PUT" "$GATEWAY/customers/$CUSTOMER_ID/change-password" "" "200" "$CUSTOMER_AUTH_HEADER -H 'Content-Type: application/x-www-form-urlencoded' -d 'currentPassword=customer123&newPassword=newpassword123'"
fi

echo
echo "5. Testing Account Service APIs..."
echo "================================="

if [ -n "$CUSTOMER_TOKEN" ] && [ -n "$CUSTOMER_ID" ]; then
    CUSTOMER_AUTH_HEADER="-H 'Authorization: Bearer $CUSTOMER_TOKEN'"
    
    # Account operations through gateway
    test_endpoint "Get Account (Gateway)" "GET" "$GATEWAY/account-api/accounts/customer/$CUSTOMER_ID" "" "200" "$CUSTOMER_AUTH_HEADER"
    
    # Deposit
    test_endpoint "Deposit Money (Gateway)" "POST" "$GATEWAY/account-api/accounts/$CUSTOMER_ID/deposit" "" "200" "$CUSTOMER_AUTH_HEADER -H 'Content-Type: application/x-www-form-urlencoded' -d 'amount=1000.00'"
    
    # Withdraw
    test_endpoint "Withdraw Money (Gateway)" "POST" "$GATEWAY/account-api/accounts/$CUSTOMER_ID/withdraw" "" "200" "$CUSTOMER_AUTH_HEADER -H 'Content-Type: application/x-www-form-urlencoded' -d 'amount=500.00'"
    
    # Transfer
    test_endpoint "Transfer Money (Gateway)" "POST" "$GATEWAY/account-api/accounts/$CUSTOMER_ID/transfer" "" "200" "$CUSTOMER_AUTH_HEADER -H 'Content-Type: application/x-www-form-urlencoded' -d 'toAccountNumber=1234567890&amount=200.00'"
    
    # Transaction History
    test_endpoint "Get Transactions (Gateway)" "GET" "$GATEWAY/account-api/accounts/$CUSTOMER_ID/transactions" "" "200" "$CUSTOMER_AUTH_HEADER"
fi

echo
echo "6. Testing KYC Service APIs..."
echo "============================="

if [ -n "$CUSTOMER_TOKEN" ] && [ -n "$CUSTOMER_ID" ]; then
    CUSTOMER_AUTH_HEADER="-H 'Authorization: Bearer $CUSTOMER_TOKEN'"
    
    # KYC operations through gateway
    test_endpoint "Get KYC Documents (Gateway)" "GET" "$GATEWAY/kyc/api/documents/$CUSTOMER_ID" "" "200" "$CUSTOMER_AUTH_HEADER"
fi

echo
echo "7. Testing Admin Service APIs..."
echo "==============================="

if [ -n "$ADMIN_TOKEN" ]; then
    ADMIN_AUTH_HEADER="-H 'Authorization: Bearer $ADMIN_TOKEN'"
    
    # Admin operations through gateway
    test_endpoint "Admin Dashboard (Gateway)" "GET" "$GATEWAY/admin/dashboard" "" "200" "$ADMIN_AUTH_HEADER"
    
    if [ -n "$CUSTOMER_ID" ]; then
        test_endpoint "View Customer (Admin Gateway)" "GET" "$GATEWAY/admin/view?customerId=$CUSTOMER_ID" "" "200" "$ADMIN_AUTH_HEADER"
    fi
fi

echo
echo "8. Testing Authorization & Error Cases..."
echo "========================================"

# Test invalid token
test_endpoint "Invalid Token" "GET" "$GATEWAY/customers/test" "" "401" "-H 'Authorization: Bearer invalid_token'"

# Test missing token
test_endpoint "Missing Token" "GET" "$GATEWAY/customers/test" "" "401"

# Test customer accessing admin route
if [ -n "$CUSTOMER_TOKEN" ]; then
    CUSTOMER_AUTH_HEADER="-H 'Authorization: Bearer $CUSTOMER_TOKEN'"
    test_endpoint "Customer accessing Admin (should fail)" "GET" "$GATEWAY/admin/dashboard" "" "403" "$CUSTOMER_AUTH_HEADER"
fi

# Test invalid login
INVALID_LOGIN='{"email":"wrong@email.com","password":"wrongpassword"}'
test_endpoint "Invalid Login" "POST" "$AUTH_SERVICE/auth/login" "$INVALID_LOGIN" "400"

echo
echo "9. Testing Credential Validation..."
echo "=================================="

# Test customer credential validation
CRED_VALIDATION='{"email":"testcustomer@bank.com","password":"customer123"}'
test_endpoint "Customer Credential Validation (Direct)" "POST" "$CUSTOMER_SERVICE/customers/validate-credentials" "$CRED_VALIDATION" "200"
test_endpoint "Customer Credential Validation (Gateway)" "POST" "$GATEWAY/customers/validate-credentials" "$CRED_VALIDATION" "200"

echo
echo "10. Performance & Load Testing..."
echo "==============================="

echo -e "${BLUE}Running quick load test on health endpoints...${NC}"
for i in {1..5}; do
    start_time=$(date +%s%N)
    curl -s "$GATEWAY/health/auth" > /dev/null
    end_time=$(date +%s%N)
    duration=$(( (end_time - start_time) / 1000000 ))
    echo "Health check $i: ${duration}ms"
done

echo
echo "🎉 Complete API Testing Finished!"
echo "================================="

# Summary
echo -e "${GREEN}✓ Services Tested:${NC}"
echo "  - Auth Service (Direct & Gateway)"
echo "  - Customer Service (Direct & Gateway)"
echo "  - Account Service (Gateway)"
echo "  - KYC Service (Gateway)"
echo "  - Admin Service (Gateway)"

echo -e "${GREEN}✓ Test Categories:${NC}"
echo "  - Health Checks"
echo "  - User Registration"
echo "  - Authentication & JWT"
echo "  - Protected Routes"
echo "  - Role-based Access Control"
echo "  - Error Handling"
echo "  - Credential Validation"

echo -e "${GREEN}✓ Generated Test Data:${NC}"
if [ -n "$ADMIN_TOKEN" ]; then
    echo "  Admin Token: $ADMIN_TOKEN"
    echo "  Admin ID: $ADMIN_ID"
fi
if [ -n "$CUSTOMER_TOKEN" ]; then
    echo "  Customer Token: $CUSTOMER_TOKEN"
    echo "  Customer ID: $CUSTOMER_ID"
fi

echo
echo "📝 Next Steps:"
echo "- Use the tokens above for manual API testing"
echo "- Test the UI at http://localhost:8085/login"
echo "- Run individual service tests for detailed analysis"
echo "- Import the API collection into Postman for automated testing"