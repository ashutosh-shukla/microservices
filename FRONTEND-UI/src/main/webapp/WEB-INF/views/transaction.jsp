<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<html>
<head>
    <title>Transaction History</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<div class="container mt-5">
    <h2>Transaction History</h2>
    <table class="table table-bordered">
        <thead>
        <tr>
            <th>Type</th>
            <th>Amount</th>
            <th>Date</th>
            <th>Transaction Date/Time</th>
        </tr>
        </thead>
        <tbody>
        <c:forEach var="transaction" items="${transactions}">
    <tr>
        <td>${transaction.transactionId}</td>
        <td>${transaction.type}</td>
        <td>${transaction.amount}</td>
        <td>${transaction.date}</td>
    </tr>
</c:forEach>
        </tbody>
    </table>
    <a href="customers/dashboard?customerId=${customerId}" class="btn btn-secondary">Back</a>
</div>
</body>
</html>
