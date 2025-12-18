# 📦 E-Commerce Order Management System

## 📝 Project Overview

This project implements a complete E-Commerce Order Management System following microservices architecture and Service-Oriented Architecture (SOA) principles.

### The system consists of:

`Frontend`: Java JSP application (Tomcat)

`Backend`: 5 Python Flask microservices

`Database`: MySQL 8.0

`Communication`: HTTP-based REST APIs with JSON

`Orchestration`: JSP → Order Service → Other Services

Each microservice is completely independent, has its own virtual environment, runs on its own port, and handles its own domain logic.

## 🚀 System Architecture

### Services & Ports
| Component            | Description                       | Port  |
|----------------------|-----------------------------------|-------|
| JSP Frontend         | API Gateway + UI                  | 8080  |
| Order Service        | Receives order requests           | 5001  |
| Inventory Service    | Stock + catalog + MySQL           | 5002  |
| Pricing Service      | Total calculation + discounts     | 5003  |
| Customer Service     | Customer DB + order history       | 5004  |
| Notification Service | Aggregates data & sends notifications | 5005  |

---
## 📚 API Documentation

### 🟦 Order Service (port 5001)

#### 1. Create Order
**POST** `/api/orders/create`

**Request Body:**
```json
{
	"customer_id": 1,
	"products": [
		{ "product_id": 101, "quantity": 2 },
		{ "product_id": 102, "quantity": 1 }
	]
}
```
**Response:**
```json
{
	"order_id": 123,
	"products": [
		{ "product_id": 101, "quantity": 2, "unit_price": 50.0 },
		{ "product_id": 102, "quantity": 1, "unit_price": 30.0 }
	],
	"total_amount": 130.0,
	"status": "Created"
}
```

#### 2. Get Order Details
**GET** `/api/orders/<order_id>`

**Response:**
```json
{
	"order_id": 123,
	"customer_id": 1,
	"items": [
		{ "product_id": 101, "quantity": 2, "unit_price": 50.0 },
		{ "product_id": 102, "quantity": 1, "unit_price": 30.0 }
	],
	"total amount": 130.0,
	"status": "Created",
	"created_at": "2025-12-18T10:00:00"
}
```

#### 3. Get Orders by Customer
**GET** `/api/orders?customer_id=<customer_id>`

**Response:**
```json
[
	{
		"order_id": 123,
		"total_amount": 130.0,
		"status": "Created",
		"created_at": "2025-12-18T10:00:00",
		"items": [
			{ "product_id": 101, "quantity": 2, "unit_price": 50.0 },
			{ "product_id": 102, "quantity": 1, "unit_price": 30.0 }
		]
	}
]
```
### 🟩 Inventory Service (port 5002)

#### 1. Check Product Stock
**GET** `/api/inventory/check/<product_id>`

**Response:**
```json
{
	"product_id": 101,
	"product_name": "Product Name",
	"quantity_available": 50,
	"unit_price": 25.0
}
```

#### 2. Update Inventory
**PUT** `/api/inventory/update`

**Request Body:**
```json
{
	"products": [
		{ "product_id": 101, "quantity": 2 },
		{ "product_id": 102, "quantity": 1 }
	]
}
```
**Response:**
```json
{
	"message": "Inventory updated successfully"
}
```

#### 3. Get Inventory Catalog
**GET** `/api/inventory/catalog`

**Response:**
```json
{
	"products": [
		{ "product_id": 101, "product_name": "Product Name", "quantity_available": 50, "unit_price": 25.0 }
	]
}
```
### 🟨 Pricing Service (port 5003)

#### 1. Calculate Pricing
**POST** `/api/pricing/calculate`

**Request Body:**
```json
{
	"products": [
		{ "product_id": 101, "quantity": 2 },
		{ "product_id": 102, "quantity": 1 }
	]
}
```
**Response:**
```json
{
	"items": [
		{
			"product_id": 101,
			"product_name": "Product Name",
			"quantity": 2,
			"unit_price": 25.0,
			"discount_percentage": 10,
			"discount": 5.0,
			"price_after_discount": 45.0
		}
	],
	"subtotal": 45.0,
	"tax_rate": 5.0,
	"tax": 2.25,
	"final_total": 47.25
}
```
### 🟦 Customer Service (port 5004)

#### 1. Get Customer Profile
**GET** `/api/customers/<customer_id>`

**Response:**
```json
{
	"customer_id": 1,
	"name": "John Doe",
	"email": "john@example.com",
	"phone": "1234567890",
	"loyalty_points": 100,
	"created_at": "2025-12-18T10:00:00"
}
```

#### 2. Get Customer Order History
**GET** `/api/customers/<customer_id>/orders`

**Response:**
```json
[
	{
		"order_id": 123,
		"total_amount": 130.0,
		"status": "Created",
		"created_at": "2025-12-18T10:00:00",
		"items": [
			{ "product_id": 101, "quantity": 2, "unit_price": 50.0 },
			{ "product_id": 102, "quantity": 1, "unit_price": 30.0 }
		]
	}
]
```

#### 3. Update Customer Loyalty Points
**PUT** `/api/customers/<customer_id>/loyalty`

**Request Body:**
```json
{
	"loyalty_points": 120
}
```
**Response:**
```json
{
	"message": "Loyalty points updated to 120 for customer 1"
}
```

#### 4. Get Customer Contact Info
**GET** `/api/customers/<customer_id>/contact`

**Response:**
```json
{
	"email": "john@example.com",
	"phone": "1234567890"
}
```
### 🟧 Notification Service (port 5005)

#### 1. Send Notification
**POST** `/api/notifications/send`

**Request Body:**
```json
{
	"order_id": 123,
	"customer_id": 1,
	"products": [
		{ "product_id": 101, "quantity": 2 },
		{ "product_id": 102, "quantity": 1 }
	]
}
```
**Response:**
```json
{
	"message": "Notification sent successfully",
	"order_id": 123,
	"customer_id": 1
}
```

---

## Project Structure
```
Service_Oriented_Architecture_Project/
│├── Frontend_JSP/
│   ├── Servlets/
│   │   ├── orderServlet.java
│   │   ├── inventoryServlet.java
│   ├── JSP Files/
│   ├── index.jsp
│   ├── checkout.jsp
│   └── confirmation.jsp
│├── Backend/
│   ├── Services/
│   │   ├── order_service/
│   │   │   ├── app.py
│   │   │   ├── requirements.txt
│   │   │   └── ...
│   │   ├── inventory_service/
│   │   │   ├── app.py
│   │   │   ├── requirements.txt
│   │   │   └── ...
│   │   ├── pricing_service/
│   │   │   ├── app.py
│   │   │   ├── requirements.txt
│   │   │   └── ...
│   │   ├── customer_service/
│   │   │   ├── app.py
│   │   │   ├── requirements.txt
│   │   │   └── ...
│   │   └── notification_service/
│   │       ├── app.py
│   │       ├── requirements.txt
│   │       └── ...
│   ├── README.md
│   ├── .gitignore
│   └── SOA_project_tables.sql

```
---

### Service Interactions
1. **Frontend (JSP)**: Receives order requests from users and forwards them to the Order Service.
2. **Order Service**: Coordinates the order processing by interacting with other services.
3. **Inventory Service**: Manages product stock and catalog information.
4. **Pricing Service**: Calculates total prices and applies discounts.
5. **Customer Service**: Manages customer data and order history.
6. **Notification Service**: Sends order confirmations and notifications to customers.

---

## 🛠️ Setup Instructions
### Prerequisites
- Java Development Kit (JDK) 8 or higher
- Apache Tomcat 9 or higher
- Python 3.7 or higher
- MySQL 8.0
- pip (Python package installer)

### Clone the Repository
```bash
git clone https://github.com/fxrxhmohamed/Service_Oriented_Architecture_Project.git
```

### Setting Up the Database
1. Install MySQL 8.0 and create a new database.
2. Run the provided `SOA_project_tables.sql` script to create necessary tables.
3. Update database connection details in each microservice's configuration file.
### Setting Up Backend Microservices
1. Navigate to each microservice directory under `Backend/Services/`.
2. Create a virtual environment and activate it:
```bash
python -m venv venv
venv\Scripts\activate 
```
3. Install required dependencies:
```bash
pip install -r requirements.txt
```
4. Start each microservice:
```bash
python app.py
```


