<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html>
<head>
    <title>Product Catolag</title>
</head>
<body>
<h2>Inventory Check Result</h2>
<pre>
<%= request.getAttribute("inventoryResponse") %>
</pre>

</body>
</html>