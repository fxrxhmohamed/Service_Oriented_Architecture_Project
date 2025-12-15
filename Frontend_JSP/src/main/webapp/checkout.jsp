<%--<%@ page contentType="text/html;charset=UTF-8" language="java" %>--%>
<%--<html>--%>
<%--<head>--%>
<%--    <title>Checkout</title>--%>
<%--</head>--%>
<%--<body>--%>

<%--<h2>Checkout</h2>--%>

<%--<form action="inventory" method="post">--%>
<%--    <label>Product ID:</label>--%>
<%--    <input type="number" name="product_id" required placeholder="Enter product ID">--%>
<%--    <label>Quantity:</label>--%>
<%--    <input type="number" name="quantity" required placeholder="Enter quantity">--%>
<%--    <button type="submit">Update Inventory</button>--%>
<%--    <button type="submit">Calculate Price</button>--%>
<%--</form>--%>

<%--</body>--%>
<%--</html>--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Checkout</title>
    <style>
        body { font-family: Arial; padding: 20px; }
        label { display: block; margin-top: 10px; }
        input { padding: 6px; width: 200px; }
        button { padding: 8px; margin-top: 15px; }
    </style>
</head>
<body>

<h2>Checkout - Create Order</h2>

<form action="order" method="post">
    <label>Customer ID</label>
    <input type="number" name="customer_id" required>

    <label>Product ID</label>
    <input type="number" name="product_id" required>

    <label>Quantity</label>
    <input type="number" name="quantity" min="1" required>

    <br>
    <button type="submit">Place Order</button>

</form>
</body>
</html>
