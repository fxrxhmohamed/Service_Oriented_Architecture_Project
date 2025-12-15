from flask import Flask, request, jsonify
import mysql.connector
from mysql.connector import Error
import requests

app = Flask(__name__)

# Database connection configuration
db_config = {
    'host': 'localhost',
    'port': 3306,  
    'user': 'ecommerce_user',
    'password': 'secure_password',
    'database': 'ecommerce_system'
}

def get_db_connection():
    try:
        conn = mysql.connector.connect(**db_config)
        return conn
    except Error as e:
        print(f"Error connecting to DB: {e}")
        return None

# URL for the Inventory Service to fetch product info
INVENTORY_SERVICE_URL = "http://localhost:5002/api/inventory/check"

# Retrieve applicable discount percentage for a product based on quantity
def get_discount_percentage(product_id, quantity):
    conn = get_db_connection()
    if not conn:
        return 0
    cursor = conn.cursor(dictionary=True)
    query = """
        SELECT discount_percentage
        FROM pricing_rules
        WHERE product_id = %s AND min_quantity <= %s
        ORDER BY min_quantity DESC
        LIMIT 1
    """
    cursor.execute(query, (int(product_id), int(quantity)))
    rule = cursor.fetchone()
    cursor.close()
    conn.close()
    return float(rule["discount_percentage"]) if rule else 0
# Retrieve tax rate for a specified region
def get_tax_rate(region="default"):
    conn = get_db_connection()
    if not conn:
        return 0
    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT tax_rate FROM tax_rates WHERE region = %s", (region,))
    tax = cursor.fetchone()
    cursor.close()
    conn.close()
    return float(tax["tax_rate"]) if tax else 0.0

@app.route("/api/pricing/calculate", methods=["POST"])
def calculate_pricing():
    data = request.get_json()

    # Validate input exists and contains 'products' key
    if not data or "products" not in data:
        return jsonify({"error": "Missing products list,Invalid input'products' required"}), 400

    products = data["products"]

    # Return error if products list is empty
    if not products:
        return jsonify({"message": "No products provided in the request"}), 400  # <-- Added error message

    items = []
    subtotal = 0

    # Iterate over each product in the request
    for p in products:
        product_id = p.get("product_id")
        quantity = p.get("quantity")

        # Validate product_id and quantity presence
        if product_id is None or quantity is None:
            return jsonify({"error": "product_id and quantity are required"}), 400

        product_id = int(product_id)
        quantity = int(quantity)

        # Fetch product details from Inventory Service
        inventory_response = requests.get(f"{INVENTORY_SERVICE_URL}/{product_id}")
        
        # Handle possible errors from Inventory Service
        if inventory_response.status_code != 200:
            return jsonify({"error": f"Product {product_id} not found in inventory"}), 500

        product_data = inventory_response.json()
        unit_price = float(product_data["unit_price"])
        available_quantity = product_data["quantity_available"]

        # Check if requested quantity exceeds available stock
        if quantity > available_quantity:
            return jsonify({
                            "error": f"Requested quantity ({quantity}) exceeds available stock ({available_quantity}) for product {product_id}"
                        }), 409
      
        # Compute discount and final price for the product
        discount_percentage = get_discount_percentage(product_id, quantity)
        item_total = unit_price * quantity
        discount_amount = item_total * (discount_percentage / 100)
        final_price = item_total - discount_amount
        subtotal += final_price

        # Log product pricing details for debugging 
        print(f"Product {product_id} - Discount%: {discount_percentage}, Discount Amount: {discount_amount}")
        
        # Append detailed product pricing to the list
        items.append({
            "product_id": product_id,
            "product_name": product_data["product_name"],
            "quantity": quantity,
            "unit_price": unit_price,
            "discount_percentage": discount_percentage,
            "discount": round(discount_amount, 2),
            "price_after_discount": round(final_price, 2)
        })

    # Compute tax and final total
    tax_rate = get_tax_rate()  # Pass region name,Now is "Default" region
    tax_amount = subtotal * (tax_rate / 100)
    final_total = subtotal + tax_amount

    return jsonify({
        "items": items,
        "subtotal": round(subtotal, 2),
        "tax_rate": tax_rate,
        "tax": round(tax_amount, 2),
        "final_total": round(final_total, 2)
    }), 200


if __name__ == "__main__":
    app.run(port=5003, debug=True)
