from flask import Flask, jsonify, request, abort
import mysql.connector
from mysql.connector import Error
from datetime import datetime

app = Flask(__name__)

@app.get("/")
def home():
    return {"message": "Inventory Service running"}

# Database connection configuration
# Adjust these parameters according to your database setup (check the mysql port you are using)
db_config = {
    'host': 'localhost',
    'port': 3307,
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

# check: Returns product details including available quantity and unit price
@app.route('/api/inventory/check/<int:product_id>', methods=['GET'])
def check_stock(product_id):
    conn = get_db_connection()
    if not conn:
        return jsonify({"error": "Database connection failed"}), 500
    cursor = conn.cursor(dictionary=True)
    query = "SELECT product_id, product_name, quantity_available, unit_price FROM inventory WHERE product_id = %s"
    cursor.execute(query, (product_id,))
    product = cursor.fetchone()
    cursor.close()
    conn.close()

    if not product:
        return jsonify({"error": "Product not found"}), 404
    
    # return product availability info
    return jsonify({
        "product_id": product['product_id'],
        "product_name": product['product_name'],
        "quantity_available": product['quantity_available'],
        "unit_price": float(product['unit_price'])
    }), 200


# update: Accepts JSON with a list of products and quantities to reduce stock
# Checks for sufficient stock before updating to prevent negative inventory
@app.route('/api/inventory/update', methods=['PUT'])
def update_inventory():

    data = request.get_json()
    if not data or 'products' not in data:
        return jsonify({"error": "Invalid input, missing 'products'"}), 400

    products = data['products']

    conn = get_db_connection()
    if not conn:
        return jsonify({"error": "Database connection failed"}), 500
    cursor = conn.cursor()

    try:
        # Check inventory first to avoid negative stock
        for p in products:
            product_id = p.get('product_id')
            quantity = p.get('quantity')
            if product_id is None or quantity is None:
                return jsonify({"error": "Product id and quantity required for each product"}), 400

            cursor.execute("SELECT quantity_available FROM inventory WHERE product_id = %s", (product_id,))
            row = cursor.fetchone()
            if not row:
                return jsonify({"error": f"Product ID {product_id} not found"}), 404

            current_qty = row[0]
            if quantity > current_qty:
                return jsonify({
                    "error": f"Not enough stock for product ID {product_id}. Available: {current_qty}, requested: {quantity}"
                }), 409  # Conflict

        # Update stock quantities
        for p in products:
            product_id = p['product_id']
            quantity = p['quantity']
            cursor.execute("""
                UPDATE inventory 
                SET quantity_available = quantity_available - %s, last_updated = %s
                WHERE product_id = %s
            """, (quantity, datetime.now(), product_id))

        conn.commit()

    except Exception as e:
        conn.rollback()
        return jsonify({"error": str(e)}), 500

    finally:
        cursor.close()
        conn.close()

    return jsonify({"message": "Inventory updated successfully"}), 200


# Get all products in inventory with details
@app.route('/api/inventory/catalog', methods=['GET'])
def get_inventory_catalog():
    conn = get_db_connection()
    if not conn:
        return jsonify({"error": "Database connection failed"}), 500
    cursor = conn.cursor(dictionary=True)
    query = "SELECT product_id, product_name, quantity_available, unit_price FROM inventory"
    cursor.execute(query)
    products = cursor.fetchall()
    cursor.close()
    conn.close()

    return jsonify({"products": products}), 200

if __name__ == "__main__":
    app.run(port=5002, debug=True)
