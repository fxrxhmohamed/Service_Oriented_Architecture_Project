package org.example.frontend_jsp.Servlets;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.net.URI;
import java.net.http.*;
import java.nio.charset.StandardCharsets;

@WebServlet("/inventory")
public class InventoryServlet extends HttpServlet {

    private static final String INVENTORY_SERVICE_URL = "http://localhost:5002/api/inventory";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String productId = request.getParameter("product_id");
        if (productId == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing product_id");
            return;
        }

        // Build URL for GET request
        String url = INVENTORY_SERVICE_URL + "/check/" + productId;

        HttpClient client = HttpClient.newHttpClient();
        HttpRequest flaskRequest = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .GET()
                .build();

        try {
            HttpResponse<String> flaskResponse =
                    client.send(flaskRequest, HttpResponse.BodyHandlers.ofString());

            // Return JSON result to JSP
            request.setAttribute("inventoryResponse", flaskResponse.body());
            request.getRequestDispatcher("index.jsp").forward(request, response);

        } catch (InterruptedException e) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    // ********* UPDATE INVENTORY *********
    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        // From checkout.jsp form
        String productId = request.getParameter("product_id");
        String quantity = request.getParameter("quantity");

        if (productId == null || quantity == null) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing product_id or quantity");
            return;
        }

        // JSON payload expected by Flask
        String jsonPayload = String.format(
                "{\"products\": [{\"product_id\": %s, \"quantity\": %s}]}",
                productId, quantity
        );

        HttpClient client = HttpClient.newHttpClient();
        HttpRequest flaskRequest = HttpRequest.newBuilder()
                .uri(URI.create(INVENTORY_SERVICE_URL + "/update"))
                .header("Content-Type", "application/json")
                .method("PUT", HttpRequest.BodyPublishers.ofString(jsonPayload, StandardCharsets.UTF_8))
                .build();

        try {
            HttpResponse<String> flaskResponse =
                    client.send(flaskRequest, HttpResponse.BodyHandlers.ofString());

            request.setAttribute("updateResponse", flaskResponse.body());
            request.getRequestDispatcher("updateInventory.jsp").forward(request, response);

        } catch (InterruptedException e) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}
