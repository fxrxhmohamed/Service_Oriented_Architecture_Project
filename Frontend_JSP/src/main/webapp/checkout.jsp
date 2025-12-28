<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="org.json.JSONArray, org.json.JSONObject" %>
<html>
<head>
    <title>Checkout</title>
    <style>
        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
        }
        .container {
            background: white;
            padding: 30px;
            border-radius: 15px;
            width: 100%;
            max-width: 650px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.3);
        }
        h2 {
            text-align: center;
            margin-bottom: 25px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 20px;
        }
        th, td {
            padding: 12px;
            border-bottom: 1px solid #ddd;
            text-align: center;
        }
        th {
            background-color: #667eea;
            color: white;
        }
        .total {
            font-size: 18px;
            font-weight: bold;
            text-align: right;
            margin-top: 15px;
        }
        .buttons {
            display: flex;
            justify-content: space-between;
            margin-top: 30px;
        }
        button {
            padding: 12px 25px;
            border: none;
            border-radius: 8px;
            font-size: 14px;
            cursor: pointer;
        }
        .cancel {
            background: #ccc;
        }
        .confirm {
            background: #667eea;
            color: white;
        }
    </style>
</head>
<body>

<div class="container">
    <h2>Checkout</h2>

    <%
        String stockMessage = (String) request.getAttribute("stockMessage");
        if (stockMessage != null) {
    %>
    <div style="color: red; font-weight: bold; margin-bottom: 15px;">
        <%= stockMessage %>
    </div>
    <div class="buttons">
        <a href="index.jsp">
            <button type="button" class="cancel">Back</button>
        </a>
    </div>
    <%
            return;
        }
    %>

    <%
        String productsJson = (String) request.getAttribute("productsJson");
        Double totalAmount = (Double) request.getAttribute("totalAmount");
        Integer customerId = (Integer) request.getAttribute("customerId");
        Double subtotal = (Double) request.getAttribute("subtotal");

        if (productsJson == null || totalAmount == null || subtotal == null) {
    %>
    <p style="color:red; text-align:center;">
        Checkout data is missing. Please start again.
    </p>
    <%
            return;
        }

        JSONArray products = new JSONArray(productsJson);
    %>

    <form action="confirmOrder" method="post">

        <!-- Customer ID (DISPLAY ONLY) -->
        <div class="form-group">
            <label><strong>Customer ID</strong></label>
            <p style="padding:10px; background:#f5f5f5; border-radius:5px;">
                <%= customerId %>
            </p>
        </div>


        <!-- Hidden data -->
        <input type="hidden" name="customer_id" value="<%= customerId %>">
        <input type="hidden" name="productsJson" value='<%= productsJson %>'>
        <input type="hidden" name="totalAmount" value="<%= totalAmount %>">

        <table>
            <tr>
                <th>Product ID</th>
                <th>Quantity</th>
                <th>Unit Price</th>
            </tr>

            <%
                for (int i = 0; i < products.length(); i++) {
                    JSONObject p = products.getJSONObject(i);
            %>
            <tr>
                <td><%= p.getInt("product_id") %></td>
                <td><%= p.getInt("quantity") %></td>
                <td>$<%= p.getDouble("unit_price") %></td>
            </tr>
            <% } %>
        </table>

        <h3 class="total">Sub-Total Amount: $<%= subtotal %></h3>
        <h3 class="total">Total Amount: $<%= totalAmount %></h3>

        <div class="buttons">
            <button type="submit" class="confirm">Confirm Order</button>
            <a href="index.jsp">
                <button type="button" class="cancel">Cancel</button>
            </a>
        </div>

    </form>

</div>

</body>
</html>
