<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Order Confirmation</title>
    <style>
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            justify-content: center;
            align-items: center;
            padding: 20px;
        }

        .container {
            background: rgba(255, 255, 255, 0.95);
            backdrop-filter: blur(10px);
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            padding: 40px;
            width: 100%;
            max-width: 600px;
            animation: slideIn 0.5s ease-out;
        }

        @keyframes slideIn {
            from {
                opacity: 0;
                transform: translateY(-30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .success-icon,
        .error-icon {
            width: 80px;
            height: 80px;
            margin: 0 auto 20px;
            border-radius: 50%;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .success-icon {
            background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%);
        }

        .error-icon {
            background: linear-gradient(135deg, #ff6b6b 0%, #ee5a6f 100%);
        }

        .success-icon::before {
            content: '✓';
            font-size: 40px;
            color: white;
            font-weight: bold;
        }

        .error-icon::before {
            content: '✕';
            font-size: 40px;
            color: white;
            font-weight: bold;
        }

        h2 {
            color: #333;
            font-size: 28px;
            margin-bottom: 10px;
            text-align: center;
        }

        h3 {
            color: #666;
            font-size: 18px;
            margin: 25px 0 15px;
            text-align: center;
        }

        .success {
            background: #e8f5e9;
            border-left: 4px solid #4caf50;
            padding: 20px;
            border-radius: 10px;
            margin-top: 20px;
        }

        .error {
            background: #ffebee;
            border-left: 4px solid #f44336;
            padding: 20px;
            border-radius: 10px;
            margin-top: 20px;
        }

        pre {
            background: rgba(0, 0, 0, 0.05);
            padding: 15px;
            border-radius: 8px;
            font-family: 'Courier New', monospace;
            font-size: 13px;
            white-space: pre-wrap;
        }

        .success pre {
            color: #2e7d32;
        }

        .error pre {
            color: #c62828;
        }
    </style>
</head>
<body>

<div class="container">
    <%
        String jsonResponse = (String) request.getAttribute("orderResponse");
        if (jsonResponse != null) {
            if (jsonResponse.contains("\"error\"")) {
    %>
    <div class="error-icon"></div>
    <h2>Order Failed</h2>
    <div class="error">
        <pre><%= jsonResponse %></pre>
    </div>
    <%
    } else {
    %>
    <div class="success-icon"></div>
    <h2>Order Placed Successfully!</h2>
    <h3>Order Details</h3>
    <div class="success">
        <pre><%= jsonResponse %></pre>
    </div>
    <%
        }
    } else {
    %>
    <div class="error-icon"></div>
    <h2>Error</h2>
    <div class="error">
        <p style="text-align:center; color:#c62828;">
            No response received from server.
        </p>
    </div>
    <%
        }
    %>
</div>

</body>
</html>
