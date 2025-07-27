<%@ page contentType="text/html;charset=UTF-8" %>
<html>
<head>
    <title>Withdraw Money</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<div class="container mt-5">
    <h2>Withdraw</h2>
   <form action="${pageContext.request.contextPath}/customers/withdrawl" method="post">
        <input type="hidden" name="customerId" value="${customerId}">
        <input type="number" step="0.01" name="amount" class="form-control mb-3" placeholder="Enter amount" required>
        <button type="submit" class="btn btn-warning">Withdraw</button>
    </form>
</div>
</body>
</html>
