package org.example.frontend_jsp.Servlets;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

@WebServlet("/profile")
public class ProfileServlet extends HttpServlet {
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String customerId = request.getParameter("customer_id");
        if (customerId == null || customerId.isEmpty()) {
            response.sendRedirect("index.jsp");
            return;
        }

        // Call Customer Service
        HttpClient client = HttpClient.newHttpClient();
        HttpRequest httpRequest = HttpRequest.newBuilder()
                .uri(URI.create("http://localhost:5004/api/customers/" + customerId))
                .header("Accept", "application/json")
                .GET()
                .build();

        try {
            HttpResponse<String> httpResponse = client.send(httpRequest, HttpResponse.BodyHandlers.ofString());
            if (httpResponse.statusCode() == 200) {
                String customerJson = httpResponse.body();
                request.setAttribute("customerProfile", customerJson);
                request.getRequestDispatcher("profile.jsp").forward(request, response);
            } else {
                response.getWriter().println("Error retrieving customer profile: " + httpResponse.statusCode());
            }
        } catch (InterruptedException e) {
            throw new ServletException(e);
        }
    }
}

