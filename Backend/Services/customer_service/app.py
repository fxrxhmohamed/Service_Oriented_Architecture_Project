from flask import Flask, request, jsonify
import mysql.connector
from mysql.connector import Error
import requests

app = Flask(__name__)

@app.route("/")
def home():
    return {"message": "Customer Service running"}

# Database connection configuration
DB_CONFIG = {
    'host': 'localhost',
    'port': 3306,
    'user': 'ecommerce_user',
    'password': 'secure_password',
    'database': 'ecommerce_system'
}

def get_db_connection():
    try:
        conn = mysql.connector.connect(**DB_CONFIG)
        return conn
    except Error as e:
        print(f"Error connecting to DB: {e}")
        return None
    
# URL for Order Service to get customer orders
ORDER_SERVICE_URL = "http://localhost:5001/api/orders"

# Get customer profile by customer_id
@app.route("/api/customers/<int:customer_id>", methods=["GET"])
def get_customer_profile(customer_id):
    conn = get_db_connection()
    if not conn:
        return jsonify({"error": "Database connection failed"}), 500

    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT customer_id, name, email, phone, loyalty_points, created_at FROM customers WHERE customer_id = %s", (customer_id,))
    customer = cursor.fetchone()
    cursor.close()
    conn.close()

    if not customer:
        return jsonify({"error": f"Customer with id {customer_id} not found"}), 404

    return jsonify(customer), 200

# Get customer order history by calling Order Service
@app.route("/api/customers/<int:customer_id>/orders", methods=["GET"])
def get_customer_orders(customer_id):
    # Optional: Validate if customer exists first to give better error message
    conn = get_db_connection()
    if not conn:
        return jsonify({"error": "Database connection failed"}), 500
    cursor = conn.cursor()
    cursor.execute("SELECT customer_id FROM customers WHERE customer_id = %s", (customer_id,))
    if not cursor.fetchone():
        cursor.close()
        conn.close()
        return jsonify({"error": f"Customer with id {customer_id} not found"}), 404
    cursor.close()
    conn.close()

    try:
        response = requests.get(f"{ORDER_SERVICE_URL}?customer_id={customer_id}")
    except requests.exceptions.RequestException as e:
        return jsonify({"error": "Order Service unavailable", "message": str(e)}), 503

    if response.status_code != 200:
        return jsonify({"error": "Failed to fetch orders from Order Service", "message": response.json()}), response.status_code

    orders = response.json()
    return jsonify(orders), 200

# Update customer loyalty points
@app.route("/api/customers/<int:customer_id>/loyalty", methods=["PUT"])
def update_loyalty_points(customer_id):
    data = request.get_json()
    if not data or "loyalty_points" not in data:
        return jsonify({"error": "Missing 'loyalty_points' in request body"}), 400

    loyalty_points = data["loyalty_points"]
    if not isinstance(loyalty_points, int) or loyalty_points < 0:
        return jsonify({"error": "'loyalty_points' must be a non-negative integer"}), 400

    conn = get_db_connection()
    if not conn:
        return jsonify({"error": "Database connection failed"}), 500

    cursor = conn.cursor()
    cursor.execute("SELECT customer_id FROM customers WHERE customer_id = %s", (customer_id,))
    if not cursor.fetchone():
        cursor.close()
        conn.close()
        return jsonify({"error": f"Customer with id {customer_id} not found"}), 404

    try:
        cursor.execute("UPDATE customers SET loyalty_points = %s WHERE customer_id = %s", (loyalty_points, customer_id))
        conn.commit()
    except Exception as e:
        conn.rollback()
        cursor.close()
        conn.close()
        return jsonify({"error": "Failed to update loyalty points", "message": str(e)}), 500

    cursor.close()
    conn.close()

    return jsonify({"message": f"Loyalty points updated to {loyalty_points} for customer {customer_id}"}), 200

# Get customer contact information used by Notification Service
@app.route("/api/customers/<int:customer_id>/contact", methods=["GET"])
def get_customer_contact(customer_id):
    conn = get_db_connection()
    if not conn:
        return jsonify({"error": "Database connection failed"}), 500

    cursor = conn.cursor(dictionary=True)
    cursor.execute("SELECT email, phone FROM customers WHERE customer_id = %s", (customer_id,))
    contact_info = cursor.fetchone()
    cursor.close()
    conn.close()

    if not contact_info:
        return jsonify({"error": f"Customer with id {customer_id} not found"}), 404

    return jsonify(contact_info), 200


if __name__ == "__main__":
    app.run(port=5004, debug=True)
