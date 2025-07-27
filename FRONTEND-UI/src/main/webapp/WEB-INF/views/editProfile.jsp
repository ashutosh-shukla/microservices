<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<html>
<head>
    <title>Edit Profile</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body>
<div class="container mt-5">
    <h2>Edit Your Profile</h2>

    <form action="${pageContext.request.contextPath}/customers/updateProfile" method="post">
        <input type="hidden" name="customerId" value="${customer.customerId}" />

        <label>First Name</label>
        <input type="text" name="firstName" value="${customer.firstName}" class="form-control" required>

        <label>Last Name</label>
        <input type="text" name="lastName" value="${customer.lastName}" class="form-control" required>

        <label>Phone</label>
        <input type="text" name="phoneNumber" value="${customer.phoneNumber}" class="form-control" required>

        <label>Address</label>
        <textarea name="address" class="form-control">${customer.address}</textarea>

        <label>Email (Leave blank if no change)</label>
        <input type="email" name="email" value="${customer.email}" class="form-control">

        <hr>

        <h4>Change Password (Optional)</h4>

        <label>Current Password</label>
        <input type="password" name="currentPassword" class="form-control">

        <label>New Password</label>
        <input type="password" name="newPassword" class="form-control">

        <button type="submit" class="btn btn-primary mt-3">Update Profile</button>
    </form>
</div>
</body>
</html>
