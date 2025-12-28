
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="org.json.JSONObject, org.json.JSONArray" %>

<html>
<head>
    <title>Product Catalog</title>
    <style>
        body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 40px 20px; }
        h2 { color: white; text-align: center; margin-bottom: 20px; }
        .nav { text-align: center; margin-bottom: 25px; }
        .nav a { color: white; margin: 0 15px; text-decoration: none; font-weight: bold; }
        table { width: 100%; border-collapse: collapse; background: white; border-radius: 10px; overflow: hidden; }
        th, td { padding: 14px; border-bottom: 1px solid #ddd; text-align: center; }
        th { background-color: #667eea; color: white; }
        tr:hover { background-color: #f2f2f2; }
        .submit-btn { margin-top: 25px; text-align: center; }
        button { padding: 14px 30px; border: none; border-radius: 8px; font-size: 16px; background: linear-gradient(135deg, #667eea, #764ba2); color: white; cursor: pointer; }
        .customer-id { text-align: center; margin-bottom: 25px; }
        .customer-id input { padding: 10px; font-size: 16px; border-radius: 6px; border: 1px solid #ddd; width: 200px; }
    </style>
</head>
<body>

<%
    if (request.getAttribute("catalog") == null) {
        response.sendRedirect("inventory");
        return;
    }
%>

<h2>Product Catalog</h2>

<div class="customer-id">
    <form id="customerForm">
        <label>Customer ID: </label>
        <input type="number" name="customer_id" id="customer_id" required>
    </form>
</div>

<div class="nav">
    <a href="#" onclick="navigateWithCustomer('profile')">Profile</a>
    <a href="#" onclick="navigateWithCustomer('orders')">Orders History</a>
</div>

<%
    String catalogJson = (String) request.getAttribute("catalog");
    JSONObject catalogObj = new JSONObject(catalogJson);
    JSONArray products = catalogObj.getJSONArray("products");
%>

<form action="checkout" method="post" id="checkoutForm">
    <input type="hidden" name="customer_id" id="hidden_customer_id">
    <table>
        <thead>
        <tr>
            <th>ID</th>
            <th>Name</th>
            <th>Available</th>
            <th>Price</th>
            <th>Quantity</th>
        </tr>
        </thead>
        <tbody>
        <%
            for (int i = 0; i < products.length(); i++) {
                JSONObject p = products.getJSONObject(i);
                if (p.getInt("quantity_available") > 0) {
        %>
        <tr>
            <td><%= p.getInt("product_id") %></td>
            <td><%= p.getString("product_name") %></td>
            <td><%= p.getInt("quantity_available") %></td>
            <td>$<%= p.getDouble("unit_price") %></td>
            <td>
                <input type="number"
                       name="qty_<%= p.getInt("product_id") %>"
                       min="0"
                       value="0">
            </td>
        </tr>
        <%
                }
            }
        %>
        </tbody>
    </table>

    <div class="submit-btn">
        <button type="submit" onclick="syncCustomerId()">Make Order</button>
    </div>
</form>

<script>
    function syncCustomerId() {
        const cid = document.getElementById('customer_id').value;
        document.getElementById('hidden_customer_id').value = cid;
    }

    function navigateWithCustomer(page) {
        const cid = document.getElementById('customer_id').value;
        if (!cid) {
            alert('Please enter Customer ID first.');
            return;
        }
        window.location.href = page + "?customer_id=" + cid;
    }
</script>

</body>
</html>
