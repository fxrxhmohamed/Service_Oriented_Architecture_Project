<%@ page contentType="text/html;charset=UTF-8" language="java" %>
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
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }

        body {
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            padding: 40px 20px;
        }

        .header {
            text-align: center;
            margin-bottom: 40px;
            animation: fadeIn 0.6s ease-out;
        }

        @keyframes fadeIn {
            from {
                opacity: 0;
                transform: translateY(-20px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        h2 {
            color: white;
            font-size: 36px;
            font-weight: 600;
        }

        .container {
            max-width: 1200px;
            margin: 0 auto;
            animation: slideUp 0.6s ease-out;
        }

        @keyframes slideUp {
            from {
                opacity: 0;
                transform: translateY(30px);
            }
            to {
                opacity: 1;
                transform: translateY(0);
            }
        }

        .catalog-card {
            background: rgba(255, 255, 255, 0.95);
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
            padding: 40px;
        }

        .catalog-header {
            margin-bottom: 30px;
            padding-bottom: 20px;
            border-bottom: 2px solid #e0e0e0;
        }

        .catalog-title {
            font-size: 24px;
            color: #333;
            font-weight: 600;
        }

        pre {
            background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
            padding: 25px;
            border-radius: 12px;
            overflow-x: auto;
            font-family: 'Courier New', monospace;
            font-size: 14px;
            line-height: 1.8;
            color: #2d3748;
            border: 1px solid #dee2e6;
            white-space: pre-wrap;
            word-wrap: break-word;
        }

        .no-data {
            text-align: center;
            padding: 60px 20px;
            color: #666;
            font-size: 18px;
        }

        @media (max-width: 768px) {
            h2 {
                font-size: 28px;
            }

            .catalog-card {
                padding: 25px 20px;
            }

            pre {
                font-size: 12px;
                padding: 15px;
            }
        }
    </style>
</head>

<body>

<div class="header">
    <h2>Product Catalog</h2>
</div>

<div class="container">
    <div class="catalog-card">
        <%
            String catalogJson = (String) request.getAttribute("catalog");
            if (catalogJson != null) {
        %>
        <div class="catalog-header">
            <div class="catalog-title">Catalog Data</div>
        </div>

        <pre><%= catalogJson %></pre>

        <%
        } else {
        %>
        <div class="no-data">
            No catalog data available.
        </div>
        <%
            }
        %>
    </div>
</div>

</body>
</html>
