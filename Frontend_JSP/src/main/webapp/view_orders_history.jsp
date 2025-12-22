<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="org.json.JSONArray, org.json.JSONObject" %>
<html>
<head>
  <title>Orders History</title>
  <style>
    body { font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; padding: 30px; background: #f7f7f7; }
    h2 { text-align: center; }
    table { width: 100%; border-collapse: collapse; margin-top: 20px; }
    th, td { padding: 12px; border: 1px solid #ddd; text-align: center; }
    th { background-color: #667eea; color: white; }
    tr:hover { background-color: #f2f2f2; }
  </style>
</head>
<body>

<h2>Orders History</h2>

<%
  String ordersJson = (String) request.getAttribute("ordersJson");
  if (ordersJson == null || ordersJson.isEmpty()) {
%>
<p>No orders found or an error occurred.</p>
<%
} else {
  JSONArray orders = new JSONArray(ordersJson);
%>

<table>
  <thead>
  <tr>
    <th>Order ID</th>
    <th>Date</th>
    <th>Products</th>
    <th>Total Amount</th>
    <th>Status</th>
  </tr>
  </thead>
  <tbody>
  <%
    for (int i = 0; i < orders.length(); i++) {
      JSONObject order = orders.getJSONObject(i);
      JSONArray products = order.getJSONArray("items");

      StringBuilder productList = new StringBuilder();
      for (int j = 0; j < products.length(); j++) {
        JSONObject p = products.getJSONObject(j);
        double unitPrice = Double.parseDouble(p.getString("unit_price"));
        productList.append("Product ID: ").append(p.getInt("product_id"))
                .append(" (Qty: ").append(p.getInt("quantity"))
                .append(", Unit Price: $").append(String.format("%.2f", unitPrice))
                .append(")<br>");
      }

      double totalAmount = Double.parseDouble(order.getString("total_amount"));
  %>
  <tr>
    <td><%= order.getInt("order_id") %></td>
    <td><%= order.getString("created_at") %></td>
    <td><%= productList.toString() %></td>
    <td>$<%= String.format("%.2f", totalAmount) %></td>
    <td><%= order.getString("status") %></td>
  </tr>
  <%
    }
  %>
  </tbody>
</table>
<%
  }
%>

<div style="margin-top: 20px; text-align:center;">
  <a href="index.jsp?customer_id=<%= request.getAttribute("customer_id") %>">Back to Catalog</a>
</div>

</body>
</html>
