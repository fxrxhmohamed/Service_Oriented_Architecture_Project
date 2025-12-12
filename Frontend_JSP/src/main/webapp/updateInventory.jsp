<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Inventory Update Result</title>
    <style>
        body { font-family: Arial, sans-serif; padding: 20px; }
        .success { color: green; }
        .error { color: red; }
        pre { background: #f4f4f4; padding: 10px; border-radius: 5px; }
    </style>
</head>
<body>
<h2>Inventory Update Result</h2>
<%
    String jsonResponse = (String) request.getAttribute("updateResponse"); //get update response
    if (jsonResponse != null) {
        if (jsonResponse.contains("\"error\"")) {//if there is an error (backend service error)
%>
<div class="error">
    <pre><%= jsonResponse %></pre>
</div>
<%
} else {//if inventory updated successfully
%>
<div class="success">
    <pre><%= jsonResponse %></pre>
</div>
<%
    }
} else {//if json response is null
%>
<div class="error">No response received from Inventory Service.</div>
<%
    }
%>
</body>
</html>
