from flask import Flask, request, jsonify
import requests

app = Flask(__name__)

# URL of the Inventory Service used to fetch product prices and availability
INVENTORY_SERVICE_URL = "http://localhost:5002/api/inventory/check"

# Define tax percentage
TAX_PERCENTAGE = 14  # 14% tax

@app.get("/")
def home():

    return {"message": "Pricing Service running"}


@app.post("/api/pricing/calculate")
def calculate_pricing():
    data = request.get_json()

    # Validate input exists and contains 'products' key
    if not data or "products" not in data:
        return jsonify({"error": "Invalid input, 'products' required"}), 400

    products = data["products"]

    # Return error if products list is empty
    if not products:
        return jsonify({"error": "Products list cannot be empty"}), 400
    

    total_before_tax = 0
    pricing_details = []  

    # Iterate over each product in the request
    for item in products:
        product_id = item.get("product_id")
        quantity = item.get("quantity")

        # Validate product_id and quantity presence
        if product_id is None or quantity is None:
            return jsonify({"error": "product_id and quantity are required"}), 400

        # Fetch product details from Inventory Service
        inventory_response = requests.get(f"{INVENTORY_SERVICE_URL}/{product_id}")

        # Handle possible errors from Inventory Service
        if inventory_response.status_code != 200:
            return jsonify({
                "error": f"Inventory service error for product {product_id}"
            }), 500

        product_data = inventory_response.json()
        unit_price = product_data["unit_price"]
        available_quantity = product_data["quantity_available"]

        # Check if requested quantity exceeds available stock
        if quantity > available_quantity:
            return jsonify({
                "error": f"Requested quantity ({quantity}) exceeds available stock ({available_quantity}) for product {product_id}"
            }), 409  # HTTP 409 Conflict

        # Calculate subtotal
        subtotal = unit_price * quantity

        # Apply discount: 10% discount for bulk orders (quantity >= 5)
        discount = 0
        if quantity >= 5:
            discount = subtotal * 0.10

        # Calculate price after discount
        price_after_discount = subtotal - discount
        
        # Append detailed product pricing to the list
        pricing_details.append({
            "product_id": product_id,
            "unit_price": unit_price,
            "quantity": quantity,
            "subtotal": round(subtotal, 2),
            "discount": round(discount, 2),
            "price_after_discount": round(price_after_discount, 2)
        })

        # Accumulate total before tax
        total_before_tax += price_after_discount

    # Calculate tax and final total
    tax_amount = total_before_tax * (TAX_PERCENTAGE / 100)
    final_total = total_before_tax + tax_amount

    # Return full pricing breakdown
    return jsonify({
        "items": pricing_details,
        "total_before_tax": round(total_before_tax, 2),
        "tax": round(tax_amount, 2),
        "final_total": round(final_total, 2)
    }), 200


if __name__ == "__main__":
    app.run(port=5003, debug=True)
