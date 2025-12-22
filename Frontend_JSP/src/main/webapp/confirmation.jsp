<%@ page import="org.json.*" %>

<html>
<head>
    <title>Order Confirmed</title>

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
            padding: 35px;
            border-radius: 15px;
            width: 100%;
            max-width: 600px;
            box-shadow: 0 20px 40px rgba(0,0,0,0.3);
            text-align: center;
        }

        h2 {
            color: #2d7a2d;
            margin-bottom: 20px;
            font-size: 26px;
        }

        .order-info {
            margin-bottom: 25px;
            font-size: 16px;
        }

        .order-info p {
            margin: 6px 0;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            margin-top: 15px;
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

        tr:last-child td {
            border-bottom: none;
        }

        .home-btn {
            display: inline-block;
            margin-top: 30px;
            padding: 12px 30px;
            background: #667eea;
            color: white;
            border-radius: 8px;
            text-decoration: none;
            font-weight: 600;
            transition: all 0.3s ease;
        }

        .home-btn:hover {
            background: #5563d6;
            transform: translateY(-2px);
            box-shadow: 0 6px 15px rgba(0,0,0,0.25);
        }
    </style>
</head>
<body>

<div class="container">

    <h2>Order Successful!</h2>

    <div class="order-info">
        <p><strong>Order ID:</strong> <%= request.getAttribute("orderId") %></p>
        <p><strong>Total Amount:</strong> $<%= request.getAttribute("totalAmount") %></p>
    </div>

    <h3>Ordered Products</h3>

    <table>
        <tr>
            <th>Product ID</th>
            <th>Quantity</th>
        </tr>

        <%
            JSONArray products = new JSONArray((String) request.getAttribute("products"));
            for (int i = 0; i < products.length(); i++) {
                JSONObject p = products.getJSONObject(i);
        %>
        <tr>
            <td><%= p.getInt("product_id") %></td>
            <td><%= p.getInt("quantity") %></td>
        </tr>
        <% } %>
    </table>

    <a href="index.jsp" class="home-btn">Return to Home</a>

</div>

</body>
</html>
