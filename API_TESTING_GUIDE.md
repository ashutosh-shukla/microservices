# 🧪 Complete API Testing Guide - SecureBank Application

This guide provides comprehensive testing scenarios for all APIs in the SecureBank application across three different approaches.

## 📋 Table of Contents
1. [Direct Service API Testing](#1-direct-service-api-testing)
2. [API Gateway Testing](#2-api-gateway-testing)
3. [Frontend UI Testing](#3-frontend-ui-testing)
4. [Postman Collection](#4-postman-collection)
5. [Test Data Examples](#5-test-data-examples)

---

## 1. 🎯 Direct Service API Testing

### Auth Service (Port 8085)

#### 1.1 Health Check
```bash
curl -X GET http://localhost:8085/auth/health
```

#### 1.2 Admin Registration
```bash
curl -X POST http://localhost:8085/auth/admin/register \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "John",
    "lastName": "Admin",
    "email": "admin@bank.com",
    "password": "admin123"
  }'
```

#### 1.3 User Login (Customer or Admin)
```bash
curl -X POST http://localhost:8085/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@bank.com",
    "password": "admin123"
  }'
```

#### 1.4 Token Validation
```bash
curl -X POST http://localhost:8085/auth/validate-token \
  -H "Content-Type: application/json" \
  -d '{
    "token": "YOUR_JWT_TOKEN_HERE"
  }'
```

#### 1.5 Check Admin Exists
```bash
curl -X GET http://localhost:8085/auth/admin/check/admin@bank.com
```

### Customer Service (Port 8081)

#### 1.6 Health Check
```bash
curl -X GET http://localhost:8081/customers/hello
```

#### 1.7 Customer Registration
```bash
curl -X POST http://localhost:8081/customers/register \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Jane",
    "lastName": "Doe",
    "email": "jane.doe@email.com",
    "phoneNumber": "1234567890",
    "address": "123 Main St, City, State",
    "dateOfBirth": "1990-01-01",
    "password": "password123",
    "role": "CUSTOMER"
  }'
```

#### 1.8 Validate Customer Credentials
```bash
curl -X POST http://localhost:8081/customers/validate-credentials \
  -H "Content-Type: application/json" \
  -d '{
    "email": "jane.doe@email.com",
    "password": "password123"
  }'
```

#### 1.9 Get Customer Details
```bash
curl -X GET http://localhost:8081/customers/{customerId}
```

#### 1.10 Update Customer Details
```bash
curl -X PUT http://localhost:8081/customers/{customerId} \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Jane",
    "lastName": "Smith",
    "address": "456 Oak Ave, City, State",
    "phoneNumber": "0987654321",
    "status": "ACTIVE"
  }'
```

#### 1.11 Change Password
```bash
curl -X PUT http://localhost:8081/customers/{customerId}/change-password \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "currentPassword=password123&newPassword=newpassword123"
```

#### 1.12 Change Email
```bash
curl -X PUT http://localhost:8081/customers/{customerId}/change-email \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "newEmail=newemail@example.com"
```

### Account Service (Port 8082)

#### 1.13 Get Account by Customer ID
```bash
curl -X GET http://localhost:8082/account-api/accounts/customer/{customerId}
```

#### 1.14 Deposit Money
```bash
curl -X POST http://localhost:8082/account-api/accounts/{customerId}/deposit \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "amount=1000.00"
```

#### 1.15 Withdraw Money
```bash
curl -X POST http://localhost:8082/account-api/accounts/{customerId}/withdraw \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "amount=500.00"
```

#### 1.16 Transfer Money
```bash
curl -X POST http://localhost:8082/account-api/accounts/{customerId}/transfer \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "toAccountNumber=1234567890&amount=200.00"
```

#### 1.17 Get Transaction History
```bash
curl -X GET http://localhost:8082/account-api/accounts/{customerId}/transactions
```

### KYC Service (Port 8083)

#### 1.18 Get KYC Documents
```bash
curl -X GET http://localhost:8083/kyc/api/documents/{customerId}
```

#### 1.19 Upload KYC Document
```bash
curl -X POST http://localhost:8083/kyc/api/documents/{customerId}/upload \
  -F "file=@document.pdf" \
  -F "documentType=ID_PROOF"
```

### Admin Service (Port 8084)

#### 1.20 Admin Health Check
```bash
curl -X GET http://localhost:8084/admin/hello
```

#### 1.21 Get All Customers (Admin)
```bash
curl -X GET http://localhost:8084/admin/dashboard
```

#### 1.22 View Customer Details (Admin)
```bash
curl -X GET http://localhost:8084/admin/view?customerId={customerId}
```

---

## 2. 🌐 API Gateway Testing

All requests go through the API Gateway (Port 8080) with JWT authentication.

### 2.1 Public Routes (No Authentication Required)

#### Health Checks
```bash
curl -X GET http://localhost:8080/health/auth
curl -X GET http://localhost:8080/health/customer
curl -X GET http://localhost:8080/health/account
curl -X GET http://localhost:8080/health/kyc
curl -X GET http://localhost:8080/health/admin
```

#### Authentication Endpoints
```bash
# Login
curl -X POST http://localhost:8080/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@bank.com",
    "password": "admin123"
  }'

# Admin Registration
curl -X POST http://localhost:8080/auth/admin/register \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "John",
    "lastName": "Admin",
    "email": "admin@bank.com",
    "password": "admin123"
  }'

# Customer Registration
curl -X POST http://localhost:8080/customers/register \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Jane",
    "lastName": "Doe",
    "email": "jane.doe@email.com",
    "phoneNumber": "1234567890",
    "address": "123 Main St",
    "dateOfBirth": "1990-01-01",
    "password": "password123",
    "role": "CUSTOMER"
  }'

# Customer Credential Validation
curl -X POST http://localhost:8080/customers/validate-credentials \
  -H "Content-Type: application/json" \
  -d '{
    "email": "jane.doe@email.com",
    "password": "password123"
  }'
```

### 2.2 Protected Customer Routes (JWT Required)

First, get a JWT token from login, then use it in subsequent requests:

```bash
# Set your JWT token
TOKEN="YOUR_JWT_TOKEN_HERE"

# Customer Operations
curl -X GET http://localhost:8080/customers/{customerId} \
  -H "Authorization: Bearer $TOKEN"

curl -X PUT http://localhost:8080/customers/{customerId} \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Jane",
    "lastName": "Smith",
    "address": "456 Oak Ave",
    "phoneNumber": "0987654321"
  }'

curl -X PUT http://localhost:8080/customers/{customerId}/change-password \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "currentPassword=password123&newPassword=newpassword123"

# Account Operations
curl -X GET http://localhost:8080/account-api/accounts/customer/{customerId} \
  -H "Authorization: Bearer $TOKEN"

curl -X POST http://localhost:8080/account-api/accounts/{customerId}/deposit \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "amount=1000.00"

curl -X POST http://localhost:8080/account-api/accounts/{customerId}/withdraw \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "amount=500.00"

curl -X POST http://localhost:8080/account-api/accounts/{customerId}/transfer \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/x-www-form-urlencoded" \
  -d "toAccountNumber=1234567890&amount=200.00"

curl -X GET http://localhost:8080/account-api/accounts/{customerId}/transactions \
  -H "Authorization: Bearer $TOKEN"

# KYC Operations
curl -X GET http://localhost:8080/kyc/api/documents/{customerId} \
  -H "Authorization: Bearer $TOKEN"

curl -X POST http://localhost:8080/kyc/api/documents/{customerId}/upload \
  -H "Authorization: Bearer $TOKEN" \
  -F "file=@document.pdf" \
  -F "documentType=ID_PROOF"
```

### 2.3 Protected Admin Routes (Admin JWT Required)

```bash
# Set your Admin JWT token
ADMIN_TOKEN="YOUR_ADMIN_JWT_TOKEN_HERE"

# Admin Operations (Requires ADMIN role)
curl -X GET http://localhost:8080/admin/dashboard \
  -H "Authorization: Bearer $ADMIN_TOKEN"

curl -X GET http://localhost:8080/admin/view?customerId={customerId} \
  -H "Authorization: Bearer $ADMIN_TOKEN"
```

### 2.4 Error Testing

#### Invalid Token
```bash
curl -X GET http://localhost:8080/customers/123 \
  -H "Authorization: Bearer invalid_token"
```

#### Missing Token
```bash
curl -X GET http://localhost:8080/customers/123
```

#### Customer trying to access Admin route
```bash
curl -X GET http://localhost:8080/admin/dashboard \
  -H "Authorization: Bearer $CUSTOMER_TOKEN"
```

---

## 3. 🖥️ Frontend UI Testing

### 3.1 Authentication Pages

#### Login Page Testing
**URL:** http://localhost:8085/login

**Test Cases:**
1. **Valid Customer Login**
   - Email: jane.doe@email.com
   - Password: password123
   - Expected: Redirect to dashboard with customer role

2. **Valid Admin Login**
   - Email: admin@bank.com
   - Password: admin123
   - Expected: Redirect to dashboard with admin role

3. **Invalid Credentials**
   - Email: wrong@email.com
   - Password: wrongpassword
   - Expected: Error message displayed

4. **Empty Fields**
   - Leave fields empty and submit
   - Expected: Validation errors

5. **Network Error Simulation**
   - Disconnect network and try login
   - Expected: Network error message

#### Admin Registration Testing
**URL:** http://localhost:8085/admin-register

**Test Cases:**
1. **Valid Registration**
   - First Name: John
   - Last Name: Admin
   - Email: newadmin@bank.com
   - Password: admin123
   - Confirm Password: admin123
   - Expected: Success message and redirect to login

2. **Password Mismatch**
   - Passwords don't match
   - Expected: Error message

3. **Duplicate Email**
   - Use existing admin email
   - Expected: Error message

4. **Invalid Email Format**
   - Use invalid email format
   - Expected: Validation error

#### Customer Registration Testing
**URL:** http://localhost:8081/customers/register

**Test Cases:**
1. **Valid Registration**
   - Fill all required fields
   - Expected: Success message and redirect to login

2. **Missing Required Fields**
   - Leave required fields empty
   - Expected: Validation errors

3. **Invalid Phone Number**
   - Use invalid phone format
   - Expected: Validation error

### 3.2 Dashboard Testing

#### Customer Dashboard
**URL:** http://localhost:8085/home (after customer login)

**Test Cases:**
1. **Dashboard Load**
   - Expected: Customer services visible
   - Role badge shows "CUSTOMER"
   - Customer name displayed

2. **Service Navigation**
   - Click "Manage Account"
   - Expected: Navigate to customer service with token

3. **Account Balance Link**
   - Click "View Balance"
   - Expected: Navigate to account service with token

4. **Logout Functionality**
   - Click logout
   - Expected: Clear localStorage and redirect to login

#### Admin Dashboard
**URL:** http://localhost:8085/home (after admin login)

**Test Cases:**
1. **Dashboard Load**
   - Expected: Admin services visible
   - Role badge shows "ADMIN"
   - Admin name displayed

2. **Customer Management Link**
   - Click "Manage Customers"
   - Expected: Navigate to admin service with token

3. **Service Access**
   - All admin service links work
   - Token passed correctly

### 3.3 Form Validation Testing

#### JavaScript Validation
1. **Email Format**
   - Test invalid email formats
   - Expected: Real-time validation

2. **Password Strength**
   - Test weak passwords
   - Expected: Validation message

3. **Required Fields**
   - Submit with empty required fields
   - Expected: Prevent submission

#### AJAX Request Testing
1. **Login Request**
   - Monitor network tab
   - Verify correct API call format

2. **Registration Request**
   - Check request payload
   - Verify response handling

### 3.4 Responsive Design Testing

1. **Mobile View**
   - Test on mobile screen sizes
   - Expected: Responsive layout

2. **Tablet View**
   - Test on tablet screen sizes
   - Expected: Proper grid layout

3. **Desktop View**
   - Test on desktop
   - Expected: Full layout with all features

---

## 4. 📮 Postman Collection

### 4.1 Environment Setup
Create a Postman environment with these variables:
```json
{
  "auth_service": "http://localhost:8085",
  "customer_service": "http://localhost:8081",
  "account_service": "http://localhost:8082",
  "kyc_service": "http://localhost:8083",
  "admin_service": "http://localhost:8084",
  "gateway": "http://localhost:8080",
  "jwt_token": "",
  "admin_token": "",
  "customer_id": "",
  "admin_id": ""
}
```

### 4.2 Collection Structure
```
SecureBank API Tests/
├── Auth Service/
│   ├── Login
│   ├── Admin Register
│   ├── Validate Token
│   └── Health Check
├── Customer Service/
│   ├── Register Customer
│   ├── Get Customer
│   ├── Update Customer
│   ├── Validate Credentials
│   └── Change Password
├── Account Service/
│   ├── Get Account
│   ├── Deposit
│   ├── Withdraw
│   ├── Transfer
│   └── Transaction History
├── API Gateway/
│   ├── Public Routes/
│   ├── Protected Customer Routes/
│   └── Protected Admin Routes/
└── Error Testing/
    ├── Invalid Token
    ├── Missing Token
    └── Insufficient Permissions
```

### 4.3 Pre-request Scripts

#### Auto-login script for protected routes:
```javascript
// Pre-request script for protected routes
if (!pm.environment.get("jwt_token")) {
    pm.sendRequest({
        url: pm.environment.get("auth_service") + "/auth/login",
        method: 'POST',
        header: {
            'Content-Type': 'application/json'
        },
        body: {
            mode: 'raw',
            raw: JSON.stringify({
                "email": "jane.doe@email.com",
                "password": "password123"
            })
        }
    }, function (err, response) {
        if (response.code === 200) {
            const responseJson = response.json();
            pm.environment.set("jwt_token", responseJson.token);
            pm.environment.set("customer_id", responseJson.userId);
        }
    });
}
```

### 4.4 Test Scripts

#### Login test:
```javascript
pm.test("Login successful", function () {
    pm.response.to.have.status(200);
    const responseJson = pm.response.json();
    pm.expect(responseJson.success).to.be.true;
    pm.expect(responseJson.token).to.not.be.empty;
    
    // Save token for future requests
    pm.environment.set("jwt_token", responseJson.token);
    pm.environment.set("user_id", responseJson.userId);
});
```

#### Protected route test:
```javascript
pm.test("Protected route accessible with valid token", function () {
    pm.response.to.have.status(200);
    pm.expect(pm.response.headers.get("X-User-Id")).to.not.be.empty;
});
```

---

## 5. 📊 Test Data Examples

### 5.1 Customer Test Data
```json
{
  "customer1": {
    "firstName": "John",
    "lastName": "Customer",
    "email": "john.customer@email.com",
    "phoneNumber": "1234567890",
    "address": "123 Customer St, City, State",
    "dateOfBirth": "1990-01-01",
    "password": "customer123",
    "role": "CUSTOMER"
  },
  "customer2": {
    "firstName": "Jane",
    "lastName": "Smith",
    "email": "jane.smith@email.com",
    "phoneNumber": "0987654321",
    "address": "456 Smith Ave, City, State",
    "dateOfBirth": "1985-05-15",
    "password": "password123",
    "role": "CUSTOMER"
  }
}
```

### 5.2 Admin Test Data
```json
{
  "admin1": {
    "firstName": "Admin",
    "lastName": "User",
    "email": "admin@bank.com",
    "password": "admin123"
  },
  "admin2": {
    "firstName": "Super",
    "lastName": "Admin",
    "email": "superadmin@bank.com",
    "password": "superadmin123"
  }
}
```

### 5.3 Transaction Test Data
```json
{
  "deposit": {
    "amount": 1000.00
  },
  "withdrawal": {
    "amount": 500.00
  },
  "transfer": {
    "toAccountNumber": "1234567890",
    "amount": 200.00
  }
}
```

---

## 🚀 Quick Test Commands

### Start Testing Environment
```bash
# Start all services
./start-services.sh

# Wait for services to be ready (check health endpoints)
curl http://localhost:8080/health/auth
```

### Complete Test Flow
```bash
# 1. Register Admin
curl -X POST http://localhost:8085/auth/admin/register \
  -H "Content-Type: application/json" \
  -d '{"firstName":"Admin","lastName":"User","email":"admin@bank.com","password":"admin123"}'

# 2. Register Customer
curl -X POST http://localhost:8081/customers/register \
  -H "Content-Type: application/json" \
  -d '{"firstName":"John","lastName":"Customer","email":"john@email.com","phoneNumber":"1234567890","address":"123 St","dateOfBirth":"1990-01-01","password":"customer123","role":"CUSTOMER"}'

# 3. Login and get token
TOKEN=$(curl -s -X POST http://localhost:8085/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"john@email.com","password":"customer123"}' | jq -r '.token')

# 4. Test protected endpoint
curl -X GET http://localhost:8080/customers/$(echo $TOKEN | base64 -d | jq -r '.userId') \
  -H "Authorization: Bearer $TOKEN"
```

---

## 📝 Testing Checklist

### ✅ Authentication Testing
- [ ] Admin registration works
- [ ] Customer registration works
- [ ] Login with valid credentials
- [ ] Login with invalid credentials
- [ ] Token generation and validation
- [ ] Token expiration handling

### ✅ Authorization Testing
- [ ] Customer can access customer routes
- [ ] Admin can access admin routes
- [ ] Customer cannot access admin routes
- [ ] Invalid tokens are rejected
- [ ] Missing tokens are rejected

### ✅ API Gateway Testing
- [ ] Public routes work without authentication
- [ ] Protected routes require valid JWT
- [ ] Role-based access control works
- [ ] Error responses are properly formatted

### ✅ Frontend Testing
- [ ] Login page functionality
- [ ] Registration forms work
- [ ] Dashboard displays correctly
- [ ] Role-based navigation
- [ ] Form validation
- [ ] Error handling
- [ ] Responsive design

### ✅ Service Integration Testing
- [ ] Auth service communicates with customer service
- [ ] API Gateway forwards requests correctly
- [ ] User information is passed in headers
- [ ] Database operations work
- [ ] Error propagation works correctly

This comprehensive testing guide covers all aspects of your SecureBank application. Use it to thoroughly test your system before deployment!