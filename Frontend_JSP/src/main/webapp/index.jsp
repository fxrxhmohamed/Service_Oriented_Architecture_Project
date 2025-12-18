<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="org.json.JSONObject, org.json.JSONArray" %>
<html>
<%
    if (request.getAttribute("catalog") == null) {
        response.sendRedirect("inventory");
        return;
    }
%>
<head>
    <title>Product Catalog</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            padding: 40px 20px;
        }
        h2 { color: white; text-align: center; margin-bottom: 40px; }
        table {
            width: 100%;
            border-collapse: collapse;
            background: white;
            border-radius: 10px;
            overflow: hidden;
        }
        th, td {
            padding: 15px;
            text-align: left;
            border-bottom: 1px solid #ddd;
        }
        th { background-color: #667eea; color: white; }
        tr:hover { background-color: #f2f2f2; }
    </style>
</head>
<body>

<h2>Product Catalog</h2>

<%
    String catalogJson = (String) request.getAttribute("catalog");
    if (catalogJson != null) {
        JSONObject catalogObj = new JSONObject(catalogJson);
        JSONArray products = catalogObj.getJSONArray("products");
%>

<table>
    <thead>
    <tr>
        <th>Product ID</th>
        <th>Product Name</th>
        <th>Quantity </th>
        <th>Price</th>
    </tr>
    </thead>
    <tbody>
    <%
        for (int i = 0; i < products.length(); i++) {
            JSONObject product = products.getJSONObject(i);
    %>
    <tr>
        <td><%= product.getInt("product_id") %></td>
        <td><%= product.getString("product_name") %></td>
        <td><%= product.getInt("quantity_available") %></td>
        <td>$<%= product.getString("unit_price") %></td>
    </tr>
    <%
        }
    %>
    </tbody>
</table>

<%
} else {
%>
<p style="color:white; text-align:center;">No catalog data available.</p>
<%
    }
%>

</body>
</html>
