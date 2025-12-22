package org.example.frontend_jsp.Servlets;

import java.io.IOException;
import java.net.http.*;
import java.net.URI;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

@WebServlet("/orders")
public class OrdersHistoryServlet extends HttpServlet {
    private static final String CUSTOMER_SERVICE_URL = "http://localhost:5004/api/customers/";

    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String customerId = request.getParameter("customer_id");
        if (customerId == null || customerId.isEmpty()) {
            response.sendRedirect("index.jsp");
            return;
        }

        HttpClient client = HttpClient.newHttpClient();
        HttpRequest httpRequest = HttpRequest.newBuilder()
                .uri(URI.create(CUSTOMER_SERVICE_URL + customerId + "/orders"))
                .GET()
                .build();

        try {
            HttpResponse<String> httpResponse = client.send(httpRequest, HttpResponse.BodyHandlers.ofString());

            if (httpResponse.statusCode() != 200) {
                request.setAttribute("error", "Failed to fetch orders: " + httpResponse.body());
            } else {
                request.setAttribute("ordersJson", httpResponse.body());
            }
            request.setAttribute("customer_id", customerId);
            request.getRequestDispatcher("view_orders_history.jsp").forward(request, response);

        } catch (InterruptedException e) {
            e.printStackTrace();
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Error fetching orders.");
        }
    }
}

