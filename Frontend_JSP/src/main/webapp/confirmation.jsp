<%--<%@ page contentType="text/html;charset=UTF-8" language="java" %>--%>
<%--<html>--%>
<%--<head>--%>
<%--    <title>Order Confirmation</title>--%>
<%--    <style>--%>
<%--        pre { background: #f4f4f4; padding: 10px; }--%>
<%--    </style>--%>
<%--</head>--%>
<%--<body>--%>

<%--<%--%>
<%--    String orderResponse = (String) request.getAttribute("orderResponse");--%>
<%--    if (orderResponse != null) {--%>
<%--%>--%>
<%--<h3>Order Details</h3>--%>
<%--<pre><%= orderResponse %></pre>--%>
<%--<%--%>
<%--} else {--%>
<%--%>--%>
<%--<p>No order information available.</p>--%>
<%--<%--%>
<%--    }--%>
<%--%>--%>

<%--</body>--%>
<%--</html>--%>
<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<html>
<head>
    <title>Order Confirmation</title>
    <style>
        body { font-family: Arial, sans-serif; padding: 20px; }
        .success { color: green; }
        .error { color: red; }
        pre { background: #f4f4f4; padding: 10px; border-radius: 5px; }
    </style>
</head>
<body>
<%
    String jsonResponse = (String) request.getAttribute("orderResponse");
    if (jsonResponse != null) {
        if (jsonResponse.contains("\"error\"")) {
%>
<div class="error">
    <pre><%= jsonResponse %></pre>
</div>
<%
} else {
%>
<h2>Order Placed Sucessfully</h2>
<h3>Order Details</h3>
<div class="success">
    <pre><%= jsonResponse %></pre>
</div>
<%
    }
} else {//if json response is null
%>
<div class="error">No response received.</div>
<%
    }
%>
</body>
</html>
