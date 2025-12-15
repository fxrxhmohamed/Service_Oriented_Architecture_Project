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

    private static final String ORDER_SERVICE_URL = "http://localhost:5001/api/orders";
    /* =======================
       CREATE ORDER (POST)
       ======================= */
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String customerId = request.getParameter("customer_id");
        String productId = request.getParameter("product_id");
        String quantity = request.getParameter("quantity");

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

        HttpClient client = HttpClient.newHttpClient();
        HttpRequest flaskRequest = HttpRequest.newBuilder()
                .uri(URI.create(ORDER_SERVICE_URL + "/create"))
                .header("Content-Type", "application/json")
                .POST(HttpRequest.BodyPublishers.ofString(jsonPayload, StandardCharsets.UTF_8))
                .build();

        try {
            HttpResponse<String> flaskResponse = client.send(flaskRequest, HttpResponse.BodyHandlers.ofString());

            request.setAttribute("orderResponse", flaskResponse.body());
            request.getRequestDispatcher("confirmation.jsp").forward(request, response);

        } catch (InterruptedException e) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }


}
