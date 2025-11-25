package org.example.frontend_jsp.Servlets;
import java.io.IOException;
import java.net.http.*;
import java.net.URI;

import jakarta.servlet.ServletException;
import jakarta.servlet.http.*;
import jakarta.servlet.annotation.WebServlet;
@WebServlet("/submitOrder")
public class OrderServlet extends HttpServlet {
    protected void doPost(HttpServletRequest request,
                          HttpServletResponse response)
            throws ServletException, IOException {

        // Get form parameters
        String customerId = request.getParameter("customer_id");
        String productId = request.getParameter("product_id");
        String quantity = request.getParameter("quantity");

        // Build JSON payload
        String jsonPayload = String.format(
                "{\"customer_id\":%s,\"products\":[{\"product_id\":%s,\"quantity\":%s}]}",
                customerId, productId, quantity
        );

        // Call Flask Order Service
        HttpClient client = HttpClient.newHttpClient();
        HttpRequest flaskRequest = HttpRequest.newBuilder()
                .uri(URI.create("http://localhost:5001/api/orders/create"))
                .header("Content-Type", "application/json")
                .POST(HttpRequest.BodyPublishers.ofString(jsonPayload))
                .build();

        try {
            HttpResponse<String> flaskResponse =
                    client.send(flaskRequest, HttpResponse.BodyHandlers.ofString());

            // Forward to confirmation page
            request.setAttribute("orderResponse", flaskResponse.body());
            request.getRequestDispatcher("confirmation.jsp").forward(request, response);

        } catch (InterruptedException e) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}