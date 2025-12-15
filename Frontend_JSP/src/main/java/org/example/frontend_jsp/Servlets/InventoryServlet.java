package org.example.frontend_jsp.Servlets;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;
import java.io.IOException;
import java.net.URI;
import java.net.http.*;
import java.nio.charset.StandardCharsets;

@WebServlet("/")
public class InventoryServlet extends HttpServlet {

//    private static final String INVENTORY_SERVICE_URL = "http://localhost:5002/api/inventory";
//
//    @Override
//    protected void doGet(HttpServletRequest request, HttpServletResponse response)
//            throws ServletException, IOException {
//
//        String productId = request.getParameter("product_id");
//        if (productId == null) {
//            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing product_id");
//            return;
//        }
//
//        // Build URL for GET request
//        String url = INVENTORY_SERVICE_URL + "/check/" + productId;
//
//        HttpClient client = HttpClient.newHttpClient();
//        HttpRequest flaskRequest = HttpRequest.newBuilder()
//                .uri(URI.create(url))
//                .GET()
//                .build();
//
//        try {
//            HttpResponse<String> flaskResponse = client.send(flaskRequest, HttpResponse.BodyHandlers.ofString());
//
//            // Return JSON result to JSP
//            request.setAttribute("inventoryResponse", flaskResponse.body());
//            request.getRequestDispatcher("index.jsp").forward(request, response);
//
//        } catch (InterruptedException e) {
//            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
//        }
//    }

    private static final String INVENTORY_CATALOG_URL = "http://localhost:5002/api/inventory/catalog";

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpClient client = HttpClient.newHttpClient();
        HttpRequest flaskRequest = HttpRequest.newBuilder()
                .uri(URI.create(INVENTORY_CATALOG_URL))
                .GET()
                .build();

        try {
            HttpResponse<String> flaskResponse = client.send(flaskRequest, HttpResponse.BodyHandlers.ofString());

            if (flaskResponse.statusCode() != 200) {
                response.sendError(flaskResponse.statusCode(), flaskResponse.body());
                return;
            }

            // Send catalog JSON to JSP
            request.setAttribute("catalog", flaskResponse.body());
            request.getRequestDispatcher("index.jsp").forward(request, response);

        } catch (InterruptedException e) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }
}
