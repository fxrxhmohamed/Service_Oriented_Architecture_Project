<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Checkout</title>
</head>
<body>

<h2>Checkout - Reduce Inventory</h2>

<form action="inventory" method="post">
    <label>Product ID:</label>
    <input type="number" name="product_id" required placeholder="Enter product ID">

    <label>Quantity:</label>
    <input type="number" name="quantity" required placeholder="Enter quantity">

    <button type="submit">Update Inventory</button>
</form>

</body>
</html>
