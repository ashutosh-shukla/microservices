<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<!DOCTYPE html>
<html>
<head>
    <title>Customer Dashboard</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background-color: #f5f5f5; }
        .container { max-width: 1200px; margin: 0 auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 0 10px rgba(0,0,0,0.1); }
        .dashboard-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; }
        .customer-info { background-color: #f8f9fa; padding: 20px; border-radius: 5px; margin-bottom: 20px; }
        .account-info { background-color: #e7f3ff; padding: 20px; border-radius: 5px; margin-bottom: 20px; }
        .transaction-section { margin-top: 30px; }
        .form-group { margin-bottom: 15px; }
        .form-inline { display: flex; gap: 10px; align-items: end; }
        label { display: block; margin-bottom: 5px; font-weight: bold; }
        input[type="number"], input[type="text"] { padding: 8px; border: 1px solid #ddd; border-radius: 4px; }
        .btn { padding: 8px 16px; border: none; border-radius: 4px; cursor: pointer; text-decoration: none; display: inline-block; }
        .btn-primary { background-color: #007bff; color: white; }
        .btn-success { background-color: #28a745; color: white; }
        .btn-warning { background-color: #ffc107; color: black; }
        .btn-danger { background-color: #dc3545; color: white; }
        .btn:hover { opacity: 0.8; }
        .alert { padding: 15px; margin-bottom: 20px; border-radius: 5px; }
        .alert-success { background-color: #d4edda; color: #155724; border: 1px solid #c3e6cb; }
        .alert-error { background-color: #f8d7da; color: #721c24; border: 1px solid #f5c6cb; }
        table { width: 100%; border-collapse: collapse; margin-top: 15px; }
        th, td { padding: 10px; text-align: left; border-bottom: 1px solid #ddd; }
        th { background-color: #f8f9fa; }
        .balance { font-size: 24px; font-weight: bold; color: #28a745; }
        .transaction-forms { display: grid; grid-template-columns: 1fr 1fr 1fr; gap: 20px; margin: 20px 0; }
        .transaction-form { background-color: #f8f9fa; padding: 15px; border-radius: 5px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="dashboard-header">
            <h1>Customer Dashboard</h1>
            <div>
                <a href="/customer/profile/${customer.customerId}" class="btn btn-primary">Profile</a>
                <a href="/customer/register" class="btn btn-success">New Customer</a>
            </div>
        </div>
        
        <c:if test="${not empty success}">
            <div class="alert alert-success">${success}</div>
        </c:if>
        
        <c:if test="${not empty error}">
            <div class="alert alert-error">${error}</div>
        </c:if>
        
        <c:if test="${not empty customer}">
            <div class="customer-info">
                <h3>Customer Information</h3>
                <p><strong>Customer ID:</strong> ${customer.customerId}</p>
                <p><strong>Name:</strong> ${customer.firstName} ${customer.lastName}</p>
                <p><strong>Email:</strong> ${customer.email}</p>
                <p><strong>Phone:</strong> ${customer.phoneNumber}</p>
            </div>
        </c:if>
        
        <c:if test="${not empty account}">
            <div class="account-info">
                <h3>Account Information</h3>
                <p><strong>Account Number:</strong> ${account.accountNumber}</p>
                <p><strong>Account Type:</strong> ${account.accountType}</p>
                <p><strong>Balance:</strong> <span class="balance">₹${account.balance}</span></p>
            </div>
            
            <div class="transaction-forms">
                <div class="transaction-form">
                    <h4>Deposit Money</h4>
                    <form action="/customer/deposit/${customer.customerId}" method="post">
                        <div class="form-group">
                            <label for="depositAmount">Amount:</label>
                            <input type="number" id="depositAmount" name="amount" step="0.01" min="1" required>
                        </div>
                        <button type="submit" class="btn btn-success">Deposit</button>
                    </form>
                </div>
                
                <div class="transaction-form">
                    <h4>Withdraw Money</h4>
                    <form action="/customer/withdraw/${customer.customerId}" method="post">
                        <div class="form-group">
                            <label for="withdrawAmount">Amount:</label>
                            <input type="number" id="withdrawAmount" name="amount" step="0.01" min="1" max="${account.balance}" required>
                        </div>
                        <button type="submit" class="btn btn-warning">Withdraw</button>
                    </form>
                </div>
                
                <div class="transaction-form">
                    <h4>Transfer Money</h4>
                    <form action="/customer/transfer/${customer.customerId}" method="post">
                        <div class="form-group">
                            <label for="toAccount">To Account Number:</label>
                            <input type="text" id="toAccount" name="toAccountNumber" required>
                        </div>
                        <div class="form-group">
                            <label for="transferAmount">Amount:</label>
                            <input type="number" id="transferAmount" name="amount" step="0.01" min="1" max="${account.balance}" required>
                        </div>
                        <button type="submit" class="btn btn-primary">Transfer</button>
                    </form>
                </div>
            </div>
        </c:if>
        
        <c:if test="${not empty accountError}">
            <div class="alert alert-error">${accountError}</div>
        </c:if>
        
        <div class="transaction-section">
            <h3>Recent Transactions</h3>
            <c:choose>
                <c:when test="${not empty transactions}">
                    <table>
                        <thead>
                            <tr>
                                <th>Date</th>
                                <th>Type</th>
                                <th>Amount</th>
                                <th>Balance</th>
                                <th>Description</th>
                            </tr>
                        </thead>
                        <tbody>
                            <c:forEach var="transaction" items="${transactions}">
                                <tr>
                                    <td><fmt:formatDate value="${transaction.transactionDate}" pattern="dd/MM/yyyy HH:mm"/></td>
                                    <td>${transaction.transactionType}</td>
                                    <td>₹${transaction.amount}</td>
                                    <td>₹${transaction.balanceAfter}</td>
                                    <td>${transaction.description}</td>
                                </tr>
                            </c:forEach>
                        </tbody>
                    </table>
                </c:when>
                <c:when test="${not empty transactionError}">
                    <div class="alert alert-error">${transactionError}</div>
                </c:when>
                <c:otherwise>
                    <p>No transactions found.</p>
                </c:otherwise>
            </c:choose>
        </div>
        
        <div style="text-align: center; margin-top: 30px;">
            <a href="/kyc/form" class="btn btn-primary">KYC Upload</a>
            <a href="/account/manage/${customer.customerId}" class="btn btn-primary">Account Management</a>
        </div>
    </div>
</body>
</html>
