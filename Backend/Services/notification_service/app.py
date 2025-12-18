from flask import Flask, request, jsonify
import mysql.connector
from mysql.connector import Error
import requests

app = Flask(__name__)

# Database connection configuration
# Adjust these parameters according to your database setup (check the mysql port you are using)
DB_CONFIG= {
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
    
# Customer Service URL to get customer contact info
CUSTOMER_SERVICE_URL = "http://localhost:5004/api/customers"

# Inventory service URL to check stock statuc and delivery estimates
INVENTORY_SERVICE_URL = "http://localhost:5002/api/inventory/check"


####################### API Endpoints #######################

@app.get("/")
def home():
    return {"message": "Notification Service running"}

############################################

@app.route("/api/notifications/send", methods = ['POST'])
def send_notification():
    data = request.get_json()

    if not data or "order_id" not in data or "customer_id" not in data or "products" not in data:
        return jsonify({"error": "order_id, customer_id and products list are required"}), 400
    
    order_id = data["order_id"]
    customer_id = data["customer_id"]
    products = data["products"]

    # 1) get customer contact info
    try:
        customer_response = requests.get(f"{CUSTOMER_SERVICE_URL}/{customer_id}/contact")
    except requests.exceptions.RequestException:
        return jsonify({"error": "Customer Service unavailable"}), 503
    
    if customer_response.status_code != 200:
        return jsonify({"error": "Failed to fetch customer contact info", "message": customer_response.json()}), customer_response.status_code
    
    customer = customer_response.json()
    customer_email = customer["email"]
    customer_phone = customer["phone"]

    # 2) check stock and delivery status
    partial_stock = False
    out_of_stock = False
    for product in products:
        product_id = product["product_id"]
        order_quantity = product["quantity"]

        # check that product_id and quantity is sent in the request
        if product_id is None or order_quantity is None:
            return jsonify({"error": "Product id and quantity required for each product."}), 400

        # check for negative or 0 quantities
        if order_quantity <= 0:
            return jsonify({"error": "Quantity must be greater than 0."}), 400
        
        # call Inventory Service (simulate delivery estimate)
        try:
            inventory_response = requests.get(f"{INVENTORY_SERVICE_URL}/{product_id}")
        except requests.exceptions.RequestException:
            return jsonify({"error": "Inventory Service unavailable"}), 503
        
        if inventory_response.status_code != 200:
            return jsonify({"error": "Failed to fetch from inventory service", "message": inventory_response.json()}), inventory_response.status_code
        
        product_info = inventory_response.json()
        quantity_avail = product_info["quantity_available"]
        
        if quantity_avail > 0 and quantity_avail < order_quantity:
            partial_stock = True
        elif quantity_avail == 0:
            out_of_stock = True
        
    # determine stock and delivery status, determine based on the worst case product (assumed rules, can be changed based on the business)
    stock_status = ""
    deliver_status = ""
    if out_of_stock:
        stock_status = "Out Of Stock"
        deliver_status = "7-10 business days"
    elif partial_stock:
        stock_status = "Partial Stock"
        deliver_status = "3-5 business days"
    else:
        stock_status = "In Stock"
        deliver_status = "2-3 business days"

    # 3) generate notification message
    message = (
        f"Order #{order_id} has been successfully placed.\n"
        f"Delivery Status: {deliver_status}\n"
        f"Products overall stock status: {stock_status}\n"
        f"Thank you for shopping with us!"
    )

    # 4) simulate Email/SMS sending
    print("===================================")
    print(f"EMAIL SENT TO: {customer_email}")
    print(f"Subject: Order #{order_id} Confirmed")
    print(f"Body:\n{message}")
    print("-----------------------------------")
    print(f"SMS SENT TO: {customer_phone}")
    print(f"Message: Order #{order_id} confirmed.")
    print("===================================")

    # 5) log notifications to DB
    conn = get_db_connection()
    if not conn:
        return jsonify({"error": "Database connection failed"}), 500
    
    cursor = conn.cursor()
    cursor.execute(
        """
        INSERT INTO notification_log (order_id, customer_id, notification_type, message)
        VALUES (%s, %s, %s, %s)
        """,
        (order_id, customer_id, "EMAIL_SMS", message)
    )
    conn.commit()
    cursor.close()
    conn.close()

    # 6) return success response
    return jsonify({
        "message": "Notification sent successfully",
        "order_id": order_id,
        "customer_id": customer_id
    }), 200

############################################

if __name__ == "__main__":
    app.run(port=5005, debug=True)
