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

## Project Structure
```
Service_Oriented_Architecture_Project/
│├── Frontend_JSP/
│   ├── index.jsp
│   ├── order.jsp
│   └── ...
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


### Service Interactions
1. **Frontend (JSP)**: Receives order requests from users and forwards them to the Order Service.
2. **Order Service**: Coordinates the order processing by interacting with other services.
3. **Inventory Service**: Manages product stock and catalog information.
4. **Pricing Service**: Calculates total prices and applies discounts.
5. **Customer Service**: Manages customer data and order history.
6. **Notification Service**: Sends order confirmations and notifications to customers.

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


