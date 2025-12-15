<%--<%@ page contentType="text/html;charset=UTF-8" language="java" %>--%>
<%--<html>--%>
<%--<head>--%>
<%--    <title>Product Catalog</title>--%>
<%--    <style>--%>
<%--        body { font-family: Arial; padding: 20px; }--%>
<%--        input, button { padding: 6px; margin-top: 5px; }--%>
<%--        pre { background: #f4f4f4; padding: 10px; }--%>
<%--    </style>--%>
<%--</head>--%>
<%--<body>--%>

<%--<h2>Product Catalog </h2>--%>

<%--<form action="inventory" method="get">--%>
<%--    <label>Enter Product ID:</label>--%>
<%--    <input type="number" name="product_id" required>--%>
<%--    <button type="submit">Check Product</button>--%>
<%--</form>--%>

<%--<hr>--%>

<%--<h3>Inventory Result</h3>--%>

<%--<%--%>
<%--    String inventoryResponse = (String) request.getAttribute("inventoryResponse");--%>
<%--    if (inventoryResponse != null) {--%>
<%--%>--%>
<%--<pre><%= inventoryResponse %></pre>--%>
<%--<%--%>
<%--} else {--%>
<%--%>--%>
<%--<p>No product selected yet.</p>--%>
<%--<%--%>
<%--    }--%>
<%--%>--%>

<%--</body>--%>
<%--</html>--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<%
    if (request.getAttribute("catalog") == null &&
            request.getAttribute("product") == null) {
        response.sendRedirect("inventory");
        return;
    }
%>
<head>
    <title>Product Catalog</title>
    <style>
        body { font-family: Arial; padding: 20px; }
        table { border-collapse: collapse; width: 80%; }
        th, td { border: 1px solid #ccc; padding: 8px; text-align: center; }
        th { background-color: #f2f2f2; }
        pre { background: #f4f4f4; padding: 10px; }
    </style>
</head>
<body>

<h2>Product Catalog</h2>

<%
    String catalogJson = (String) request.getAttribute("catalog");
    if (catalogJson != null) {
%>
<pre><%= catalogJson %></pre>
<%
} else {
%>
<p>No catalog data available.</p>
<%
    }
%>
</body>
</html>

