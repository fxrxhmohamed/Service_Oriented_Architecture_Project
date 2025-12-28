<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="org.json.JSONObject" %>

<html>
<head>
    <title>Customer Profile</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; padding: 40px; background-color: #f4f4f4; }
        h2 { color: #333; text-align: center; margin-bottom: 20px; }
        .profile { max-width: 500px; margin: auto; background: white; padding: 20px; border-radius: 10px; }
        .profile p { font-size: 18px; margin: 10px 0; }
        .back-link { text-align: center; margin-top: 20px; }
        .back-link a { text-decoration: none; color: #667eea; font-weight: bold; }
    </style>
</head>
<body>
<%
    String customerJson = (String) request.getAttribute("customerProfile");
    if (customerJson != null) {
        JSONObject customer = new JSONObject(customerJson);
%>
<div class="profile">
    <h2>Customer Profile</h2>
    <p><strong>ID:</strong> <%= customer.getInt("customer_id") %></p>
    <p><strong>Name:</strong> <%= customer.getString("name") %></p>
    <p><strong>Email:</strong> <%= customer.getString("email") %></p>
    <p><strong>Phone:</strong> <%= customer.getString("phone") %></p>
    <p><strong>Loyalty Points:</strong> <%= customer.getInt("loyalty_points") %></p>
</div>
<div class="back-link">
    <a href="index.jsp">Back</a>
</div>
<%
} else {
%>
<p style="text-align:center; color:red;">No customer profile available.</p>
<%
    }
%>
</body>
</html>
