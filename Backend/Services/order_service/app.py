from flask import Flask, request, jsonify
import mysql.connector
from mysql.connector import Error
import requests
import math

# URL of the Inventory Service used to check products availability
INVENTORY_SERVICE_CHECK_URL = "http://localhost:5002/api/inventory/check"

# URL of the Inventory Service used to update products stock after order placement
INVENTORY_SERVICE_UPDATE_URL = "http://localhost:5002/api/inventory/update"

# URL for Pricing service to calculate order price
PRICING_SERVICE_URL = "http://localhost:5003/api/pricing/calculate"

# URL for Customer service to vaildate customer_id
CUSTOMER_SERVICE_URL = "http://localhost:5004/api/customers"

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

app = Flask(__name__)

@app.get("/")
def home():
    return {"message": "Order Service running"}


####################### Helper functions #######################

# check if the custmer exists using the Customer Service
def validate_customer_id(customer_id):
    try: 
        customer_response = requests.get(f"{CUSTOMER_SERVICE_URL}/{customer_id}")
    except requests.exceptions.RequestException:
        return {"error": "Customer service unavailable"}

    if customer_response.status_code != 200:
        return False, {"error": "Customer service validating customer", "message": f"{customer_response.json()}"}, customer_response.status_code
    return True, customer_response.json(), 200

############################################

# validate all input parameters exist
def validate_request_data(data):
    # check if data is sent
    if not data:
        return False, {"error": "No Data is received."}
    # check fot customer_id in the data
    if "customer_id" not in data:
        return False, {"error": "Invalid input, 'customer_id' required."}
    # check for list of products in the data
    if "products" not in data:
        return False, {"error": "Invalid input, 'products' required."}
    return True, None

############################################

# check product_id and quantity exist in the input parameters
# check inventory for all order products and if their quantity is valid
def check_product_availability(products):
    products_info = []  # list to store all order items info
    for product in products:
        product_id = product.get("product_id")
        quantity = product.get("quantity")

        # check that product_id and quantity is sent in the request
        if product_id is None or quantity is None:
            return False, {"error": "Product id and quantity required for each product."}, 400
        # check for negative or 0 quantities
        if quantity <= 0:
            return False, {"error": "Quantity must be greater than 0."}, 400

        # use Inventory service to check product availability
        inventory_check_response = requests.get(f"{INVENTORY_SERVICE_CHECK_URL}/{product_id}")

        if inventory_check_response.status_code != 200:
            return False, {"error": f"Inventory service error for product {product_id}", "message": f"{inventory_check_response.json()}"}, 500

        product_info = inventory_check_response.json()
        quantity_avail = product_info["quantity_available"]
        if quantity > quantity_avail:
            return False, {"error": f"Requested quantity ({quantity}) exceeds available stock ({quantity_avail}) for product {product_id}"}, 409

        products_info.append({
            "product_id": product_id,
            "quantity": quantity,
            "unit_price": product_info["unit_price"]
        })
    return True, products_info, 200

############################################

# calculate order price
def calculate_order_total(products):
    # use Pricing service to calculate order price
    pricing_response = requests.post(PRICING_SERVICE_URL, json = {"products": products})

    if pricing_response.status_code != 200:
        return False, {"error": "Pricing service error calculating order price", "message": f"{pricing_response.json()}"}, pricing_response.status_code
    
    pricing_data = pricing_response.json()
    return True, pricing_data["final_total"], 200

############################################

# insert an order into orders table
def insert_order(cursor, customer_id, order_total, order_status):
    query = "Insert into orders (customer_id, total_amount, status) values (%s, %s, %s)"
    cursor.execute(query, (customer_id, order_total, order_status))
    # return the insered order id to be used to insert order items
    return cursor.lastrowid

############################################

# insert order items in order_items table
def insert_order_items(cursor, order_id, products_info):

    for product in products_info:
        product_id = product["product_id"]
        quantity = product["quantity"]
        unit_price = product["unit_price"]
        query = "Insert into order_items (order_id, product_id, quantity, unit_price) values (%s, %s, %s, %s)"
        cursor.execute(query, (order_id, product_id, quantity, unit_price))

############################################

# update inventory stock after order creation
def update_inventory_stock(products):
    # use Inventory service to update products stock
    inventory_update_response = requests.put(INVENTORY_SERVICE_UPDATE_URL, json = {"products": products})

    if inventory_update_response.status_code != 200:
        return False, {"error": "Error while updating inventory stock after order creation.","message": f"{inventory_update_response.json()}"}, inventory_update_response.status_code
    return True, None, 200

############################################

# update customer loyalty points
def update_loyalty_points(customer_id, loyalty_points):
    # use Customer service to update customer loyalty points
    response = requests.put(f"{CUSTOMER_SERVICE_URL}/{customer_id}/loyalty", json={"loyalty_points": loyalty_points})
    if response.status_code != 200:
        return False, {"error": "Customer service error updating loyalty points", "message": f"{response.json()}"}, response.status_code
    return True, response.json(), 200
     
####################### API Endpoints #######################

# Create new order
@app.route("/api/orders/create", methods = ['POST'])
def create_order():  
    # get request data 
    data = request.get_json()
    # 1) validate request data
    valid, error = validate_request_data(data)
    if not valid:
        return jsonify(error), 400

    customer_id = data.get("customer_id")
    products = data.get("products")

    # make db connection
    conn = get_db_connection()
    if not conn:
        return jsonify({"error": "Database connection failed."}), 500
    cursor = conn.cursor(dictionary=True)

    # 2) check if the customer exists
    valid, customer, status_code = validate_customer_id(customer_id)
    if not valid:
        return jsonify(customer), status_code

    # 3) Check product availability
    valid, products_info, status_code = check_product_availability(products)
    if not valid:
        cursor.close()
        conn.close()
        return jsonify(products_info), status_code
    
    # 4) calculate order price
    valid, order_total, status_code = calculate_order_total(products)
    if not valid:
        cursor.close()
        conn.close()
        return jsonify(order_total), status_code

    try:
        # 5) insert order info into db
        order_status = 'Created'    # to be updated after sending notifications
        order_id = insert_order(cursor, customer_id, order_total, order_status)
        insert_order_items(cursor, order_id, products_info)
        conn.commit()

    except Exception as e:
        conn.rollback()
        cursor.close()
        conn.close()
        return jsonify({"error": str(e)}), 500
    
    cursor.close()
    conn.close()

    # 6) update inventory
    valid, error, status_code = update_inventory_stock(products)
    if not valid:
        return jsonify(error), status_code
    
    # 7) calculate and update customer loyalty points
    new_loyalty_points = math.floor(order_total / 10)
    customer_loyalty_points = customer["loyalty_points"]
    valid, response, status_code = update_loyalty_points(customer_id, customer_loyalty_points + new_loyalty_points)
    if not valid:
        return jsonify(response), status_code

    return jsonify({
        "order_id": order_id,
        "products": products_info,
        "total_amount": order_total,
        "status": order_status
    }), 200


############################################

# Retrieve order details
@app.route("/api/orders/<int:order_id>", methods = ['GET'])
def get_order_details(order_id):
    # make db connection
    conn = get_db_connection()
    if not conn:
        return jsonify({"error": "Database connection failed."}), 500
    
    cursor = conn.cursor(dictionary=True)
    # query the orders table
    query = "Select * from orders where order_id = %s"
    cursor.execute(query, (order_id,))
    order = cursor.fetchone()

    if not order:
        return jsonify({"error": f"Order with id {order_id} not found"}), 404
    
    # query order_items table
    query = "Select product_id, quantity, unit_price from order_items where order_id = %s"
    cursor.execute(query, (order_id,))
    order_items = cursor.fetchall()

    cursor.close()
    conn.close()

    if not order_items:
        return jsonify({"error": f"Didn't find items for order with id {order_id}"}), 404
    
    return jsonify({
        "order_id": order_id, 
        "customer_id": order['customer_id'],
        "items": order_items,
        "total amount": order['total_amount'],
        "status": order['status'],
        "created_at": order['created_at']
    }), 200


############################################

# Get orders by customer_id used by Customer Service
@app.route("/api/orders", methods=["GET"])
def get_orders_by_customer():
    customer_id = request.args.get("customer_id")

    if not customer_id:
        return jsonify({"error": "customer_id query parameter is required"}), 400

    conn = get_db_connection()
    if not conn:
        return jsonify({"error": "Database connection failed"}), 500

    cursor = conn.cursor(dictionary=True)

    # Get orders for customer
    cursor.execute("SELECT order_id, total_amount, status, created_at FROM orders WHERE customer_id = %s",(customer_id,))
    orders = cursor.fetchall()

    if not orders:
        cursor.close()
        conn.close()
        return jsonify([]), 200  

    # Attach items to each order
    for order in orders:
        cursor.execute("SELECT product_id, quantity, unit_price FROM order_items WHERE order_id = %s",(order["order_id"],))
        order["items"] = cursor.fetchall()

    cursor.close()
    conn.close()

    return jsonify(orders), 200



if __name__ == "__main__":
    app.run(port=5001, debug=True)
