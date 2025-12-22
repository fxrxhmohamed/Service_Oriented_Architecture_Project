package org.example.frontend_jsp.Servlets;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;
import org.json.*;

import java.io.*;
import java.net.HttpURLConnection;
import java.net.URL;

@WebServlet("/confirmOrder")
public class ConfirmOrderServlet extends HttpServlet {

    private static final String ORDER_SERVICE_URL =
            "http://localhost:5001/api/orders/create";

    private static final String CUSTOMER_SERVICE_URL =
            "http://localhost:5004/api/customers";

    private static final String NOTIFICATION_SERVICE_URL =
            "http://localhost:5005/api/notifications/send";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        int customerId = Integer.parseInt(request.getParameter("customer_id"));
        double totalAmount = Double.parseDouble(request.getParameter("totalAmount"));

        JSONArray products = new JSONArray(request.getParameter("productsJson"));

       // create order using Order service

        JSONObject orderPayload = new JSONObject();
        orderPayload.put("customer_id", customerId);
        orderPayload.put("products", products);
        orderPayload.put("total_amount", totalAmount);

        JSONObject orderResponse =
                callService(ORDER_SERVICE_URL, "POST", orderPayload);

        int orderId = orderResponse.getInt("order_id");

       // update loyalty points using Customer service

        int newPoints = (int) Math.floor(totalAmount / 10);

        JSONObject loyaltyPayload = new JSONObject();
        loyaltyPayload.put("loyalty_points", newPoints);

        callService(
                CUSTOMER_SERVICE_URL + "/" + customerId + "/loyalty",
                "PUT",
                loyaltyPayload
        );

        // Send notification using Notification service

        JSONObject notifPayload = new JSONObject();
        notifPayload.put("order_id", orderId);
        notifPayload.put("customer_id", customerId);
        notifPayload.put("products", products);

        callService(
                NOTIFICATION_SERVICE_URL,
                "POST",
                notifPayload
        );

        // Go to confirmation page

        request.setAttribute("orderId", orderId);
        request.setAttribute("products", products.toString());
        request.setAttribute("totalAmount", totalAmount);

        request.getRequestDispatcher("confirmation.jsp")
                .forward(request, response);
    }

    // helper method
    private JSONObject callService(String url, String method, JSONObject payload)
            throws IOException {

        URL serviceUrl = new URL(url);
        HttpURLConnection conn = (HttpURLConnection) serviceUrl.openConnection();

        conn.setRequestMethod(method);
        conn.setRequestProperty("Content-Type", "application/json");
        conn.setDoOutput(true);

        try (OutputStream os = conn.getOutputStream()) {
            os.write(payload.toString().getBytes());
        }

        InputStream is = conn.getResponseCode() < 400
                ? conn.getInputStream()
                : conn.getErrorStream();

        BufferedReader reader = new BufferedReader(new InputStreamReader(is));
        StringBuilder response = new StringBuilder();
        String line;

        while ((line = reader.readLine()) != null) {
            response.append(line);
        }

        return new JSONObject(response.toString());
    }
}
