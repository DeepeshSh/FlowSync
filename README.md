
# FlowSync

## Smart Business Management System for Sanitary & Hardware Businesses

FlowSync is a full-stack business management application built to digitize and streamline the day-to-day operations of sanitary and hardware businesses.

Sanitary businesses often manage thousands of products, multiple warehouses, suppliers, customers, purchase orders, sales orders, inventory movements, damaged stock, payments, and outstanding balances. Managing these operations manually can result in stock discrepancies, duplicated records, delayed reporting, and difficulty in tracking business performance.

FlowSync brings these operations together into a centralized, structured, and data-driven platform.

The system provides dedicated modules for **Products, Inventory, Warehouses, Purchases, Sales, Customers, Suppliers, Payments, Stock Movements, and Reports**, with a backend responsible for API communication, business logic, validation, database operations, and data consistency.

The project focuses not only on building interfaces, but also on modelling **real-world business workflows and relationships between different operational modules**.

---

# 🎯 Objectives

FlowSync was developed with the following objectives:

- Digitize routine business operations and reduce manual record keeping.
- Centralize product, inventory, customer, supplier, and transaction data.
- Provide accurate stock visibility across multiple warehouses.
- Simplify purchase and sales order management.
- Track customer receivables and supplier payables.
- Maintain a traceable history of stock movements and adjustments.
- Provide meaningful reports for business analysis and decision-making.
- Build a modular and scalable foundation for future business automation.

---

# ✨ Features

## 📊 Dashboard

The dashboard provides a centralized overview of the business and surfaces important information without requiring users to navigate through multiple modules.

It can provide visibility into:

- Total products
- Inventory status
- Low-stock products
- Purchase activity
- Sales activity
- Customer receivables
- Supplier payables
- Warehouse stock
- Recent transactions
- Important stock movements

The dashboard is designed around actionable business information rather than simply displaying raw database values.

---

## 📦 Product Management

The Product Management module provides a centralized catalog for maintaining products handled by the business.

Products can contain information such as:

- Product name
- Product code / SKU
- Category
- Unit of measurement
- Purchase price
- Selling price
- Minimum stock level
- Product status
- Inventory information

Products are maintained as independent business entities and can subsequently be associated with purchase orders, sales orders, warehouses, and inventory records.

### Key capabilities

- Add and update products
- Categorize products
- Manage product pricing
- Search and filter products
- Monitor stock-related information
- Maintain backend-driven product data

---

# 🏢 Multi-Warehouse Management

FlowSync supports businesses operating with multiple physical warehouses.

Instead of maintaining only one global stock quantity, inventory can be associated with individual warehouses, allowing users to understand **where a particular product is physically available**.

The warehouse module supports:

- Creating and managing warehouses
- Maintaining warehouse information
- Viewing warehouse-specific inventory
- Monitoring stock at individual locations
- Transferring stock between warehouses
- Maintaining warehouse-wise stock history

### Warehouse Transfer Flow

```text
Warehouse A
     │
     │ Stock Transfer
     ▼
Warehouse B
     │
     ▼
Inventory Updated

This makes inventory management more practical for businesses that operate from multiple locations.


---

📦 Inventory Management

Inventory is one of the core modules of FlowSync.

The system treats inventory as more than just a quantity. Stock changes are connected to the business operations responsible for those changes.

Inventory can be affected by:

Purchases

Sales

Warehouse transfers

Damaged products

Stock adjustments

Returns


Inventory Flow

Purchase
                       │
                       ▼
                 Stock Received
                       │
                       ▼
                   Warehouse
                       │
          ┌────────────┼────────────┐
          ▼            ▼            ▼
        Sales       Transfer      Damage
          │            │            │
          ▼            ▼            ▼
       Stock ↓      Stock Move    Stock ↓

This approach provides better accountability and makes it easier to identify how the current stock position was reached.


---

🔄 Stock Movement Tracking

FlowSync maintains a structured history of inventory movements.

Stock movements can represent:

Purchase receipts

Sales

Warehouse transfers

Damaged stock

Manual stock adjustments

Returns


A stock movement can contain information such as:

Product

Quantity

Movement type

Source warehouse

Destination warehouse

Reference transaction

Date and time

Reason or remarks


Example

Product: Ceramic Wash Basin

Purchase
   ↓
+50 units
   ↓
Warehouse A

Sale
   ↓
-10 units
   ↓
Warehouse A

Transfer
   ↓
20 units
   ↓
Warehouse A → Warehouse B

Damage
   ↓
-2 units
   ↓
Warehouse B

This creates an audit-friendly trail of inventory changes instead of silently modifying stock quantities.


---

🛒 Purchase Order Management

The Purchase Order module manages the procurement process from suppliers.

Purchase orders can contain:

Supplier

Order date

Expected delivery information

Products

Quantities

Purchase prices

Discounts

Taxes or applicable charges

Total amount

Order status

Notes


A purchase order can progress through different stages:

Draft
  ↓
Confirmed
  ↓
Received
  ↓
Completed

The purchase workflow is connected to inventory so that receiving products can result in the appropriate stock update.

Purchase Workflow

Supplier
   ↓
Purchase Order
   ↓
Goods Received
   ↓
Warehouse Selected
   ↓
Inventory Updated
   ↓
Stock Movement Created
   ↓
Supplier Payable Updated


---

👥 Supplier Management

The Supplier module maintains supplier information and provides visibility into supplier-related transactions.

Supplier records can include:

Supplier details

Contact information

Purchase history

Purchase orders

Payment history

Outstanding payables

Due amounts

Transaction history


The module helps the business understand both the operational and financial relationship with each supplier.


---

💰 Sales Order Management

The Sales Order module manages customer orders and connects sales activity with inventory.

Sales orders can contain:

Customer

Order date

Products

Quantities

Selling prices

Discounts

Taxes or applicable charges

Total amount

Payment information

Order status

Notes


Sales Workflow

Customer
   ↓
Sales Order
   ↓
Order Confirmation
   ↓
Stock Availability Check
   ↓
Stock Deduction
   ↓
Stock Movement Created
   ↓
Payment / Receivable Updated

This connects sales transactions directly with inventory and customer financial information.


---

👤 Customer Management

The Customer module provides centralized management of customer records.

It can maintain:

Customer information

Contact details

Sales history

Sales orders

Payment history

Outstanding receivables

Due amounts

Transaction history


This allows the business to understand customer activity and outstanding balances from a single location.


---

💳 Payment & Outstanding Management

FlowSync incorporates financial tracking into its business workflows.

Customer Receivables

Receivables represent money that customers still owe to the business.

Sales Amount
     ↓
Payment Received
     ↓
Remaining Amount
     ↓
Customer Receivable

Supplier Payables

Payables represent money that the business still owes to suppliers.

Purchase Amount
     ↓
Payment Made
     ↓
Remaining Amount
     ↓
Supplier Payable

This provides a clearer view of outstanding financial obligations.


---

⚠️ Damage & Stock Adjustment Management

Physical inventory can differ from recorded inventory due to damaged products, loss, counting errors, or other operational reasons.

FlowSync provides mechanisms for recording these changes instead of directly modifying stock without context.

Examples include:

Damaged stock

Lost stock

Physical inventory corrections

Manual adjustments

Other stock discrepancies


Adjustment information can include:

Product

Warehouse

Quantity

Reason

Date

Remarks


This improves stock accountability and supports inventory reconciliation.


---

📈 Reports & Analytics

FlowSync provides reports that transform operational data into useful business information.

Inventory Reports

Current stock report

Low-stock report

Out-of-stock report

Warehouse-wise inventory

Stock valuation


Stock Movement Reports

Purchase movements

Sales movements

Warehouse transfers

Damaged stock

Stock adjustments

Returns


Purchase Reports

Purchase history

Supplier-wise purchases

Purchase order status

Purchase trends


Sales Reports

Sales history

Customer-wise sales

Product-wise sales

Sales trends


Financial Reports

Customer receivables

Supplier payables

Payment history

Outstanding amounts


The reporting system is designed around structured transactional data rather than manually maintained report values.


---

🔎 Search & Filtering

Business applications can contain a large number of records, making efficient data discovery important.

FlowSync provides search and filtering capabilities across major modules.

Users can search and filter:

Products

Customers

Suppliers

Purchase orders

Sales orders

Warehouses

Inventory

Transactions

Stock movements


Reusable search and filtering patterns are used to maintain consistency throughout the application.


---

🎨 User Interface & UX

FlowSync follows a modern, business-oriented card-based UI.

The interface focuses on:

Clear information hierarchy

Summary cards

Search bars

Filter chips

Structured list views

Status indicators

Action-oriented screens

Readable business metrics

Consistent navigation patterns


The same design language is used throughout modules such as:

Dashboard
     ↓
Products
     ↓
Inventory
     ↓
Purchases
     ↓
Sales
     ↓
Customers
     ↓
Suppliers
     ↓
Reports

This creates a consistent experience while allowing each module to present its own business-specific information.


---

🏗️ System Architecture

FlowSync follows a layered full-stack architecture that separates the frontend, backend, business logic, and database responsibilities.

┌───────────────────────────────────────────┐
│                 FRONTEND                  │
│                                           │
│               Flutter App                 │
│                                           │
│     Screens • Widgets • State • Models    │
└─────────────────────┬─────────────────────┘
                      │
                      │ REST API / HTTP
                      ▼
┌───────────────────────────────────────────┐
│                 BACKEND                   │
│                                           │
│                 FastAPI                   │
│                                           │
│   API Routes • Validation • Business      │
│   Logic • Authentication • Services       │
└─────────────────────┬─────────────────────┘
                      │
                      │ Database Operations
                      ▼
┌───────────────────────────────────────────┐
│                DATABASE                   │
│                                           │
│               PostgreSQL                  │
│                                           │
│ Products • Inventory • Warehouses         │
│ Customers • Suppliers • Orders            │
│ Payments • Stock Movements                │
└───────────────────────────────────────────┘

The separation of responsibilities makes the application easier to maintain, test, debug, and extend.


---

🔌 Backend Architecture

The backend is responsible for exposing APIs and enforcing the application's business rules.

A typical request follows this flow:

Frontend
   │
   │ HTTP Request
   ▼
API Endpoint
   │
   ▼
Request Validation
   │
   ▼
Business Logic
   │
   ▼
Database Operation
   │
   ▼
Response
   │
   ▼
Frontend

The backend handles responsibilities including:

API routing

Request validation

Response handling

Business logic

Database operations

Inventory calculations

Order processing

Stock updates

Payment calculations

Authentication

Authorization

Error handling


Keeping important business logic on the backend prevents critical rules from being dependent only on the client application.


---

🌐 REST API Architecture

FlowSync communicates between the frontend and backend using RESTful APIs.

The API is organized around business resources.

Examples include:

/products
/customers
/suppliers
/warehouses
/inventory
/purchases
/sales
/payments
/reports
/stock-movements

Common HTTP operations include:

GET       → Retrieve data
POST      → Create records
PUT       → Update records
PATCH     → Partially update records
DELETE    → Remove records

This resource-oriented approach keeps the backend modular and allows the same backend to potentially serve multiple clients in the future.


---

🗄️ Database Design

FlowSync uses a relational data model where business entities are connected through meaningful relationships.

Core entities include:

User
 │
 ├── Customers
 └── Suppliers

Product
 │
 ├── Inventory
 ├── Purchase Order Items
 └── Sales Order Items

Warehouse
 │
 └── Inventory

Purchase Order
 │
 ├── Supplier
 └── Purchase Order Items

Sales Order
 │
 ├── Customer
 └── Sales Order Items

Inventory
 │
 └── Stock Movements

The relational approach helps maintain data integrity and avoids unnecessary duplication.


---

🧠 Business Logic

A major focus of FlowSync is implementing real business workflows instead of limiting the application to basic CRUD operations.

For example, receiving a purchase can involve several coordinated operations:

Purchase Order
      ↓
Validate Products
      ↓
Validate Quantities
      ↓
Validate Warehouse
      ↓
Record Purchase
      ↓
Update Inventory
      ↓
Create Stock Movement
      ↓
Update Supplier Payable

Similarly, processing a sale can involve:

Sales Order
      ↓
Validate Customer
      ↓
Validate Products
      ↓
Check Available Stock
      ↓
Create Sales Transaction
      ↓
Deduct Inventory
      ↓
Create Stock Movement
      ↓
Update Customer Receivable

This demonstrates how a single business operation can affect multiple related entities while maintaining consistency.


---

🔐 Authentication & Authorization

FlowSync is designed around backend-controlled authentication and authorization.

Authentication establishes the identity of a user, while authorization determines which operations that user can perform.

This becomes especially important for business-critical operations such as:

Modifying inventory

Creating purchase orders

Creating sales orders

Updating products

Managing payments

Changing business records


Security rules should therefore be enforced at the backend rather than relying exclusively on frontend restrictions.


---

🧩 Modular Architecture

The application is divided into independent but interconnected business modules.

┌─────────────┐
                    │  Dashboard  │
                    └──────┬──────┘
                           │
        ┌──────────────────┼──────────────────┐
        ▼                  ▼                  ▼
    Products           Inventory           Reports
        │                  │                  │
        └──────────┬───────┴──────────┬───────┘
                   ▼                  ▼
              Purchases            Sales
                   │                  │
                   ▼                  ▼
               Suppliers          Customers
                   │                  │
                   └────────┬─────────┘
                            ▼
                         Payments

This modular approach makes it easier to develop, maintain, test, and extend individual parts of the system.


---

🛠️ Technology Stack

Frontend

Flutter

Dart

REST API integration

Reusable UI components

Backend-driven data

State management

Modern card-based UI


Backend

Python

FastAPI

RESTful APIs

Business logic

Request validation

Authentication & authorization

Database integration


Database

PostgreSQL

Relational database design

Entity relationships

Transaction-oriented data modelling


Development Tools

Git

GitHub

Postman

Android Studio

VS Code



---

📁 Project Structure

A high-level representation of the project architecture:

FlowSync/
│
├── frontend/
│   │
│   ├── lib/
│   │   ├── models/
│   │   ├── screens/
│   │   ├── widgets/
│   │   ├── services/
│   │   ├── providers/
│   │   └── utils/
│   │
│   └── assets/
│
├── backend/
│   │
│   ├── app/
│   │   ├── api/
│   │   ├── models/
│   │   ├── schemas/
│   │   ├── services/
│   │   ├── database/
│   │   ├── authentication/
│   │   └── main.py
│   │
│   └── requirements.txt
│
├── README.md
└── .gitignore

The exact structure may vary according to implementation, but the architecture follows the principle of separating UI, API, business logic, and data-access responsibilities.


---

🔄 End-to-End Business Flow

A complete purchase-to-inventory workflow can be represented as:

Supplier
   ↓
Purchase Order
   ↓
Products & Quantities
   ↓
Goods Received
   ↓
Warehouse
   ↓
Inventory Updated
   ↓
Stock Movement Recorded
   ↓
Supplier Payable Updated

A complete sales workflow:

Customer
   ↓
Sales Order
   ↓
Products & Quantities
   ↓
Stock Availability Check
   ↓
Inventory Deduction
   ↓
Stock Movement Recorded
   ↓
Payment Recorded
   ↓
Customer Receivable Updated

A warehouse transfer:

Source Warehouse
       ↓
   Stock Transfer
       ↓
Destination Warehouse
       ↓
Inventory Updated
       ↓
Movement Recorded

These workflows demonstrate how the different modules of FlowSync work together as one integrated business system.


---

🧪 API Testing

Backend APIs can be tested independently using tools such as Postman.

API testing is used to verify:

Request validation

Response structures

Authentication

CRUD operations

Business rules

Error handling

Database updates

Inventory calculations


Testing APIs independently also helps identify backend issues before integrating functionality with the frontend.


---

🚧 Technical Challenges

Developing FlowSync involved solving several practical software engineering challenges.

Inventory Consistency

Inventory cannot simply be modified from multiple screens without considering the underlying business operation.

Stock changes need to be associated with valid events such as purchases, sales, transfers, or adjustments.

Multi-Warehouse Inventory

The same product may exist in several warehouses.

Therefore, inventory needs to be tracked at the appropriate warehouse level rather than relying only on a single global stock quantity.

Transaction Relationships

Products, customers, suppliers, orders, warehouses, payments, and stock movements are interconnected.

The database must preserve these relationships while avoiding unnecessary duplication.

Backend-Driven Application

Business information should come from the backend and database instead of being hardcoded into the frontend.

This allows the UI to reflect actual business data.

Reusable Components

Customers and Suppliers share similar interaction patterns while having different business metrics.

Reusable UI components and consistent design patterns help avoid unnecessary duplication.

Cross-Module Business Logic

A single operation can affect multiple modules.

For example:

Sales
  ↓
Inventory
  ↓
Stock Movement
  ↓
Customer Balance

Implementing such workflows requires careful handling of business rules and data consistency.


---

📈 Reports & Decision Support

FlowSync is designed not only to store business information but also to make that information useful.

The reporting layer can help answer questions such as:

Which products are running low?

How much stock exists in each warehouse?

Which products are being sold most frequently?

How much has been purchased from a supplier?

Which customers have outstanding payments?

How much is payable to suppliers?

Where has stock moved?

How much inventory has been damaged or adjusted?


This transforms raw transactional data into information that can support operational decisions.


---

🚀 Future Enhancements

The architecture provides a foundation for additional capabilities, including:

Role-based access control

Advanced permission management

Automated invoice generation

PDF and Excel report exports

Barcode / QR code scanning

Low-stock notifications

Payment due reminders

WhatsApp / SMS notifications

Advanced sales analytics

Demand forecasting

Inventory valuation

Automated stock reconciliation

Cloud synchronization

Offline-first functionality

Detailed audit logs

Advanced financial reporting

Advanced business dashboards



---

💡 What This Project Demonstrates

FlowSync demonstrates practical understanding of:

Full-stack application development

Flutter application development

Dart programming

Python backend development

FastAPI

REST API architecture

PostgreSQL

Relational database design

API integration

CRUD operations

Business logic

Data validation

Authentication & authorization

Inventory management

Multi-warehouse architecture

Transaction management

State management

Modular application architecture

Reusable UI components

Search and filtering

Reporting systems

Git & GitHub

Real-world business problem modelling



---

📸 Screenshots

> Add screenshots of the actual application below to showcase the implementation.



Dashboard

Add dashboard screenshot here.

Inventory

Add inventory screenshot here.

Purchase Orders

Add purchase order screenshot here.

Sales Orders

Add sales order screenshot here.

Customers

Add customer management screenshot here.

Suppliers

Add supplier management screenshot here.

Warehouses

Add warehouse management screenshot here.

Reports

Add reports screenshot here.


---

⚙️ Getting Started

Prerequisites

Make sure the following are installed:

Flutter SDK

Dart SDK

Python

PostgreSQL

Git

Android Studio or VS Code



---

📥 Installation

1. Clone the Repository

git clone <repository-url>
cd FlowSync


---

2. Backend Setup

Navigate to the backend directory:

cd backend

Create a virtual environment:

python -m venv venv

Windows

venv\Scripts\activate

macOS / Linux

source venv/bin/activate

Install the required dependencies:

pip install -r requirements.txt

Configure the required environment variables and database connection.

Start the FastAPI server:

uvicorn app.main:app --reload


---

📱 Frontend Setup

Navigate to the frontend directory:

cd frontend

Install Flutter dependencies:

flutter pub get

Run the application:

flutter run

Make sure the frontend is configured with the correct backend API URL.


---

🌱 Development Approach

FlowSync was developed using a structured software engineering workflow:

Requirement Analysis
        ↓
Business Workflow Analysis
        ↓
Database Design
        ↓
API Design
        ↓
Backend Development
        ↓
Frontend Development
        ↓
API Integration
        ↓
Testing & Debugging
        ↓
UI/UX Refinement

The development process focused on understanding the underlying business requirements before implementing individual screens.


---

🏆 Project Highlights

Full-Stack Development

FlowSync covers both frontend application development and backend/API development, providing experience across the complete application stack.

Real-World Business Modelling

The application models actual business entities and workflows including products, inventory, warehouses, purchases, sales, customers, suppliers, payments, and stock movements.

Business Logic

The project goes beyond basic CRUD functionality by implementing workflows where a single operation can affect multiple related entities.

Data-Driven Architecture

Business information is dynamically retrieved from the backend and database rather than being hardcoded into the application interface.

Scalable Design

The separation between frontend, API, business logic, and database provides a foundation for future functionality and additional clients.

Practical Problem Solving

The application addresses real operational problems such as inventory discrepancies, warehouse-level stock tracking, outstanding payments, damaged inventory, and transaction history.


---

🤝 Contributing

Contributions and suggestions are welcome.

1. Fork the repository.


2. Create a new branch.


3. Make your changes.


4. Commit your changes.


5. Push the branch.


6. Open a Pull Request.




---

📄 License

This project is developed for business-management and software-engineering purposes.

If this project is distributed publicly, an appropriate open-source license can be added here.


---

⭐ FlowSync

Manage Products. Control Inventory. Simplify Business.

FlowSync connects products, inventory, warehouses, purchases, sales, customers, suppliers, payments, and reports into one unified business management platform.
