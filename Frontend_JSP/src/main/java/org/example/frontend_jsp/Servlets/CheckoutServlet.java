package org.example.frontend_jsp.Servlets;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import org.json.JSONArray;
import org.json.JSONObject;

import java.io.IOException;
import java.net.URI;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.util.Enumeration;

@WebServlet("/checkout")
public class CheckoutServlet extends HttpServlet {

    private static final String INVENTORY_CHECK_URL = "http://localhost:5002/api/inventory/check/";
    private static final String PRICING_URL = "http://localhost:5003/api/pricing/calculate";
@Override
protected void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {

    HttpClient client = HttpClient.newHttpClient();
    JSONArray productsForPricing = new JSONArray();

    //  Read customer_id from the hidden input
    String customerIdStr = request.getParameter("customer_id");
    Integer customerId = null;
    if (customerIdStr != null && !customerIdStr.isEmpty()) {
        try {
            customerId = Integer.parseInt(customerIdStr);
        } catch (NumberFormatException e) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Invalid customer ID");
            return;
        }
    } else {
        response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Customer ID is required");
        return;
    }

    //  Read selected products
    Enumeration<String> params = request.getParameterNames();
    while (params.hasMoreElements()) {
        String param = params.nextElement();
        if (param.startsWith("qty_")) {
            int qty = Integer.parseInt(request.getParameter(param));
            if (qty > 0) {
                int productId = Integer.parseInt(param.substring(4));
                JSONObject product = new JSONObject();
                product.put("product_id", productId);
                product.put("quantity", qty);
                productsForPricing.put(product);
            }
        }
    }

    if (productsForPricing.isEmpty()) {
        response.sendError(HttpServletResponse.SC_BAD_REQUEST, "No products selected");
        return;
    }

    //  Inventory validation using Inventory service
    for (int i = 0; i < productsForPricing.length(); i++) {
        JSONObject p = productsForPricing.getJSONObject(i);
        int productId = p.getInt("product_id");
        int requestedQty = p.getInt("quantity");

        HttpRequest invRequest = HttpRequest.newBuilder()
                .uri(URI.create(INVENTORY_CHECK_URL + productId))
                .GET()
                .build();

        try {
            HttpResponse<String> invResponse =
                    client.send(invRequest, HttpResponse.BodyHandlers.ofString());

            if (invResponse.statusCode() != 200) {
                response.sendError(HttpServletResponse.SC_BAD_REQUEST,
                        "Inventory service error");
                return;
            }

            JSONObject invData = new JSONObject(invResponse.body());
            int available = invData.getInt("quantity_available");

            if (requestedQty > available) {
                String message = "Only " + available + " items are available for product " + productId;
                request.setAttribute("stockMessage", message);

                // Forward back to checkout page
                request.getRequestDispatcher("checkout.jsp").forward(request, response);
                return;
            }


        } catch (InterruptedException e) {
            response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            return;
        }
    }

    // pricing calculation using pricing service
    JSONObject pricingPayload = new JSONObject();
    pricingPayload.put("products", productsForPricing);

    HttpRequest pricingRequest = HttpRequest.newBuilder()
            .uri(URI.create(PRICING_URL))
            .header("Content-Type", "application/json")
            .POST(HttpRequest.BodyPublishers.ofString(
                    pricingPayload.toString(), StandardCharsets.UTF_8))
            .build();

    try {
        HttpResponse<String> pricingResponse = client.send(pricingRequest, HttpResponse.BodyHandlers.ofString());

        if (pricingResponse.statusCode() != 200) {
            response.sendError(HttpServletResponse.SC_BAD_REQUEST, "Pricing service error");
            return;
        }


        JSONObject pricingResult = new JSONObject(pricingResponse.body());

        request.setAttribute("productsJson", pricingResult.getJSONArray("items").toString());
        request.setAttribute("subtotal", pricingResult.getDouble("subtotal"));
        request.setAttribute("totalAmount", pricingResult.getDouble("final_total"));

        // Pass customer ID to checkout.jsp
        request.setAttribute("customerId", customerId);

        request.getRequestDispatcher("checkout.jsp").forward(request, response);

    } catch (InterruptedException e) {
        response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
    }


}

}


