package org.example.frontend_jsp.Servlets;

import jakarta.servlet.*;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.*;

import org.json.JSONArray;
import org.json.JSONObject;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;

@WebServlet("/confirmOrder")
public class ConfirmOrderServlet extends HttpServlet {

    private static final String ORDER_SERVICE_URL = "http://localhost:5001/api/orders/create";

    private static final String CUSTOMER_SERVICE_URL = "http://localhost:5004/api/customers";

    private static final String NOTIFICATION_SERVICE_URL = "http://localhost:5005/api/notifications/send";

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpClient client = HttpClient.newHttpClient();

        // 1. Read parameters from checkout.jsp
        int customerId = Integer.parseInt(request.getParameter("customer_id"));
        double totalAmount = Double.parseDouble(request.getParameter("totalAmount"));
        JSONArray products = new JSONArray(request.getParameter("productsJson"));

        // 2. create an order using the order service
        JSONObject orderPayload = new JSONObject();
        orderPayload.put("customer_id", customerId);
        orderPayload.put("products", products);
        orderPayload.put("total_amount", totalAmount);

        HttpRequest orderRequest = HttpRequest.newBuilder()
                .uri(URI.create(ORDER_SERVICE_URL))
                .header("Content-Type", "application/json")
                .POST(HttpRequest.BodyPublishers.ofString(
                        orderPayload.toString(), StandardCharsets.UTF_8))
                .build();

        HttpResponse<String> orderResponse;
        try {
            orderResponse = client.send(orderRequest, HttpResponse.BodyHandlers.ofString());
        } catch (InterruptedException e) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            return;
        }

        if (orderResponse.statusCode() != 200) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST,
                    "Order service error");
            return;
        }

        JSONObject orderResult = new JSONObject(orderResponse.body());
        int orderId = orderResult.getInt("order_id");

        // 3. get customer profile
        HttpRequest customerGetRequest = HttpRequest.newBuilder()
                .uri(URI.create(CUSTOMER_SERVICE_URL + "/" + customerId))
                .GET()
                .build();

        HttpResponse<String> customerResponse;
        try {
            customerResponse = client.send(customerGetRequest, HttpResponse.BodyHandlers.ofString());
        } catch (InterruptedException e) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            return;
        }

        if (customerResponse.statusCode() != 200) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST,
                    "Customer service error");
            return;
        }

        JSONObject customerObj = new JSONObject(customerResponse.body());
        int oldPoints = customerObj.getInt("loyalty_points");
        int updatedPoints = oldPoints + 10;

        // 4. update customer loyalty points using customer service

        JSONObject loyaltyPayload = new JSONObject();
        loyaltyPayload.put("loyalty_points", updatedPoints);

        HttpRequest loyaltyRequest = HttpRequest.newBuilder()
                .uri(URI.create(CUSTOMER_SERVICE_URL + "/" + customerId + "/loyalty"))
                .header("Content-Type", "application/json")
                .PUT(HttpRequest.BodyPublishers.ofString(
                        loyaltyPayload.toString(), StandardCharsets.UTF_8))
                .build();

        try {
            client.send(loyaltyRequest, HttpResponse.BodyHandlers.ofString());
        } catch (InterruptedException e) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            return;
        }

        // 5. send notification using notification service
        JSONObject notifPayload = new JSONObject();
        notifPayload.put("order_id", orderId);
        notifPayload.put("customer_id", customerId);
        notifPayload.put("products", products);

        HttpRequest notifRequest = HttpRequest.newBuilder()
                .uri(URI.create(NOTIFICATION_SERVICE_URL))
                .header("Content-Type", "application/json")
                .POST(HttpRequest.BodyPublishers.ofString(
                        notifPayload.toString(), StandardCharsets.UTF_8))
                .build();

        try {
            client.send(notifRequest, HttpResponse.BodyHandlers.ofString());
        } catch (InterruptedException e) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            return;
        }

       // 6. forward to confirmation page
        request.setAttribute("orderId", orderId);
        request.setAttribute("products", products.toString());
        request.setAttribute("totalAmount", totalAmount);

        request.getRequestDispatcher("confirmation.jsp").forward(request, response);
    }
}
