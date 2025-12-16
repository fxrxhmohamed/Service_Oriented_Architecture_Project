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
    //URL of inventory Catolag
    private static final String INVENTORY_CATALOG_URL = "http://localhost:5002/api/inventory/catalog";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        // Create HTTP client for communicating with the Inventory service
        HttpClient client = HttpClient.newHttpClient();
        // Build the HTTP GET request to fetch the catalog
        HttpRequest flaskRequest = HttpRequest.newBuilder()
                .uri(URI.create(INVENTORY_CATALOG_URL))
                .GET()
                .build();

        try {
            // Send request to the Flask Inventory service
            HttpResponse<String> flaskResponse = client.send(flaskRequest, HttpResponse.BodyHandlers.ofString());
            // Check if the response status is not successful
            if (flaskResponse.statusCode() != 200) {
                response.sendError(flaskResponse.statusCode(), flaskResponse.body());
                return;
            }

            // Store the response body as a request attribute
            request.setAttribute("catalog", flaskResponse.body());
            // Forward request to index.jsp for rendering the catalog
            request.getRequestDispatcher("index.jsp").forward(request, response);

        } catch (InterruptedException e) {
            // Handle communication failures with the Inventory service
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}
