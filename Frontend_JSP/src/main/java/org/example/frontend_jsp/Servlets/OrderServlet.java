package org.example.frontend_jsp.Servlets;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.net.URI;
import java.net.http.*;
import java.nio.charset.StandardCharsets;

@WebServlet("/order")
public class OrderServlet extends HttpServlet {
    //URL of order service
    private static final String ORDER_SERVICE_URL = "http://localhost:5001/api/orders";
   //create order
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Retrieve form parameters sent from the checkout page
        String customerId = request.getParameter("customer_id");
        String productId = request.getParameter("product_id");
        String quantity = request.getParameter("quantity");
        // Validate that all required parameters exist
        if (customerId == null || productId == null || quantity == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing customer_id, product_id, or quantity");
            return;
        }

        // JSON expected by Order Service
        String jsonPayload = String.format("""
            {
              "customer_id": %s,
              "products": [
                {
                  "product_id": %s,
                  "quantity": %s
                }
              ]
            }
            """, customerId, productId, quantity);
        // Create an HTTP client to communicate with the Order Service
        HttpClient client = HttpClient.newHttpClient();
        // Build the HTTP POST request
        HttpRequest flaskRequest = HttpRequest.newBuilder()
                .uri(URI.create(ORDER_SERVICE_URL + "/create"))
                .header("Content-Type", "application/json")
                .POST(HttpRequest.BodyPublishers.ofString(jsonPayload, StandardCharsets.UTF_8))
                .build();

        try {
            //Send the request to the Flask service and receive the response
            HttpResponse<String> flaskResponse = client.send(flaskRequest, HttpResponse.BodyHandlers.ofString());
            // Store the response body as a request attribute
            request.setAttribute("orderResponse", flaskResponse.body());
            // Forward the request to confirmation.jsp to display the result
            request.getRequestDispatcher("confirmation.jsp").forward(request, response);

        } catch (InterruptedException e) {
            // Handle communication errors with the Order Service
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }


}
