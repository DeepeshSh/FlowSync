```markdown
# FlowSync

## Smart Business Management System for Sanitary & Hardware Businesses

FlowSync is a full-stack business management application built to digitize and streamline the day-to-day operations of sanitary and hardware businesses.

Sanitary businesses often manage thousands of products, multiple warehouses, suppliers, customers, purchase orders, sales orders, inventory movements, damaged stock, payments, and outstanding balances. Managing these operations manually can result in stock discrepancies, duplicated records, delayed reporting, and difficulty in tracking business performance.

FlowSync brings these operations together into a centralized, structured, and data-driven platform.

The system provides dedicated modules for **Products, Inventory, Warehouses, Purchases, Sales, Customers, Suppliers, Payments, Stock Movements, and Reports**, with a robust backend responsible for API communication, business logic, validation, database operations, and data consistency.

The project focuses not only on building responsive user interfaces, but also on modelling **real-world business workflows and relationships between different operational modules**.

---

# Download & Test the App (Release APK)

You can directly download and test the physical Android release build of FlowSync from the link below:

* **[Download FlowSync Release APK via Google Drive](https://drive.google.com/drive/folders/1-Placeholder-For-Your-Drive-Link)** *(Directly installable on physical Android devices)*

---

# Objectives

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

# Features & Business Modules

## Dashboard

The dashboard provides a centralized overview of the business and surfaces important information without requiring users to navigate through multiple modules.

It provides visibility into:
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

## Product Management

The Product Management module provides a centralized catalog for maintaining products handled by the business.

Products contain information such as:
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

### Key Capabilities
- Add and update products
- Categorize products
- Manage product pricing
- Search and filter products
- Monitor stock-related information
- Maintain backend-driven product data

---

## Multi-Warehouse Management

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

```

---

## Inventory Management

Inventory is one of the core modules of FlowSync.

The system treats inventory as more than just a quantity. Stock changes are connected to the business operations responsible for those changes.

Inventory can be affected by:

* Purchases
* Sales
* Warehouse transfers
* Damaged products
* Stock adjustments
* Returns

### Inventory Flow Diagram

```text
Purchase
    │
    ▼
Stock Received
    │
    ▼
Warehouse
    │
    ┌────────────┬────────────┐
    ▼            ▼            ▼
  Sales       Transfer     Damage
    │            │            │
    ▼            ▼            ▼
Stock ↓      Stock Move   Stock ↓

```

---

## Stock Movement Tracking

FlowSync maintains a structured history of inventory movements to ensure complete traceability.

Stock movements represent:

* Purchase receipts
* Sales
* Warehouse transfers
* Damaged stock
* Manual stock adjustments
* Returns

### Stock Movement Data Structure

A stock movement contains:

* Product reference
* Quantity change
* Movement type
* Source warehouse
* Destination warehouse
* Reference transaction ID
* Date and timestamp
* Reason or operational remarks

```text
Example: Ceramic Wash Basin
  ├── Purchase (+50 units) → Warehouse A
  ├── Sale (-10 units)     → Warehouse A
  ├── Transfer (20 units)  → Warehouse A ──> Warehouse B
  └── Damage (-2 units)    → Warehouse B

```

---

## Purchase Order Management

The Purchase Order module manages the procurement process from suppliers.

Purchase orders contain:

* Supplier details
* Order date and expected delivery
* Product line items and quantities
* Purchase prices and unit rates
* Discounts, taxes, and applicable charges
* Total order amount
* Order status and remarks

### Purchase Workflow Lifecycle

```text
Draft ──> Confirmed ──> Received ──> Completed

```

```text
Supplier ──> Purchase Order ──> Goods Received ──> Warehouse Selected 
    ──> Inventory Updated ──> Stock Movement Created ──> Supplier Payable Updated

```

---

## Supplier Management

The Supplier module maintains supplier profiles and provides visibility into supplier-related operational and financial transactions.

Records include:

* Supplier details and contact info
* Purchase history and order logs
* Payment history and outstanding payables
* Due amounts and reconciliation statements

---

## Sales Order Management

The Sales Order module manages customer transactions and connects sales activity directly with inventory depletion.

Sales orders contain:

* Customer details
* Order date and terms
* Product items, quantities, and selling prices
* Discounts, taxes, and total values
* Payment information and order status

### Sales Workflow Lifecycle

```text
Customer ──> Sales Order ──> Order Confirmation ──> Stock Availability Check 
    ──> Stock Deduction ──> Stock Movement Created ──> Payment / Receivable Updated

```

---

## Customer Management

The Customer module provides centralized management of customer records.

It maintains:

* Customer information and addresses
* Contact details and communication logs
* Sales history and order lists
* Payment history, outstanding receivables, and due balances

---

## Payment & Outstanding Management

FlowSync incorporates financial tracking directly into daily business operations.

### Customer Receivables

```text
Sales Amount ──> Payment Received ──> Remaining Balance ──> Customer Receivable

```

### Supplier Payables

```text
Purchase Amount ──> Payment Made ──> Remaining Balance ──> Supplier Payable

```

---

## Damage & Stock Adjustment Management

Physical inventory can differ from recorded inventory due to damaged products, loss, counting errors, or operational discrepancies.

FlowSync provides structured mechanisms for recording these changes instead of silently overriding stock numbers.

Adjustment parameters include:

* Product and target warehouse
* Quantity discrepancy and type
* Reason code, date, and administrative remarks

---

## Reports & Analytics

FlowSync transforms transactional data into actionable business insights.

### Supported Report Categories

* **Inventory Reports:** Current stock status, low-stock alerts, out-of-stock listings, warehouse valuation.
* **Stock Movement Reports:** Purchase history, sales dispatch, warehouse transfers, damage audits, returns.
* **Purchase Reports:** Supplier-wise procurement, order fulfillment status, cost trends.
* **Sales Reports:** Customer revenue, product-wise sales velocity, sales trends.
* **Financial Reports:** Outstanding customer receivables, supplier payables, ledger history.

---

# System Architecture

FlowSync uses a layered full-stack architecture that cleanly separates frontend presentation, API routing, business logic, and data persistence responsibilities.

```text
┌────────────────────────────────────────────────────────┐
│                        FRONTEND                        │
│                       Flutter App                      │
│            Screens • Widgets • State • Models          │
└───────────────────────────┬────────────────────────────┘
                            │
                            │ REST API / HTTP (Firebase Auth + Node/FastAPI)
                            ▼
┌────────────────────────────────────────────────────────┐
│                         BACKEND                        │
│               FastAPI / Node.js & Firebase             │
│    API Routes • Validation • Business Logic • Auth     │
└───────────────────────────┬────────────────────────────┘
                            │
                            │ Database Operations
                            ▼
┌────────────────────────────────────────────────────────┐
│                         DATABASE                       │
│                   PostgreSQL / Firebase                │
│    Products • Inventory • Warehouses • Customers       │
│    Suppliers • Orders • Payments • Stock Movements     │
└────────────────────────────────────────────────────────┘

```

---

# Backend Architecture

The backend exposes secured RESTful APIs and enforces strict business rules and data validation.

```text
Frontend ──> HTTP Request ──> API Endpoint ──> Request Validation 
    ──> Business Logic ──> Database Operation ──> Response ──> Frontend

```

---

# Database Design & Relationships

The database is built on a relational model ensuring complete data integrity across business modules:

```text
User
 ├── Customers
 └── Suppliers

Product
 ├── Inventory Records
 ├── Purchase Order Items
 └── Sales Order Items

Warehouse
 └── Inventory Items

Purchase Order
 ├── Supplier
 └── Purchase Order Items

Sales Order
 ├── Customer
 └── Sales Order Items

Inventory
 └── Stock Movements

```

---

# Technology Stack

### Frontend

* **Flutter & Dart:** Cross-platform mobile application development.
* **Material 3:** Modern, business-oriented card-based UI design.
* **REST API Integration:** Dynamic client-server data syncing.

### Backend & Database

* **Python / FastAPI / Node.js:** Robust server architecture and endpoints.
* **PostgreSQL / Firebase:** Relational database design and real-time backend synchronization.
* **Firebase Authentication:** Secure user identity management and token validation.

### Development & DevOps Tools

* **Git & GitHub:** Version control and collaboration.
* **Postman:** Independent API endpoint testing.
* **Android Studio & VS Code:** Primary IDE environments.
* **Google Cloud Console:** Credential management and API restriction configuration.

---

# Project Structure

```text
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

```

---

# Technical Diary & Engineering Journey

Throughout the development of FlowSync, several complex engineering challenges were solved to ensure reliability in production:

1. **Firebase Authentication on Native Release Builds:** Resolved persistent *"check your internet connection"* errors on physical devices by correcting Google Cloud Console project scopes, generating proper SHA-1 and SHA-256 debug/release fingerprints (`7E:52:2C:07:0C:A4:A6:EA:EC:B2:67:DD:61:85:7D:0F:BE:B0:22:8C`), configuring valid API key bindings (`Identity Toolkit API` / `Google Cloud APIs`), and updating `google-services.json`.
2. **Multi-Warehouse Stock Consistency:** Decoupled inventory from single global counters, ensuring stock changes correctly reference specific physical warehouses and maintain immutable audit trails via stock movements.
3. **Cross-Module Transaction Integrity:** Synchronized sales and purchase workflows so that placing an order automatically updates inventory levels, logs stock movements, and recalculates customer receivables or supplier payables in real time.

---

# Screenshots

### Login Page

### Purchase Module

### Sales Module

### PDF Billing

---

# Getting Started & Installation

## Prerequisites

Ensure you have the following installed on your machine:

* Flutter SDK & Dart SDK
* Python (for backend services)
* PostgreSQL
* Git
* Android Studio or VS Code

## 1. Clone the Repository

```bash
git clone [https://github.com/your-username/FlowSync.git](https://github.com/your-username/FlowSync.git)
cd FlowSync

```

## 2. Backend Setup

Navigate to the backend directory:

```bash
cd backend

```

Create and activate a virtual environment:

```bash
python -m venv venv
# Windows:
venv\Scripts\activate
# macOS / Linux:
source venv/bin/activate

```

Install dependencies and start the server:

```bash
pip install -r requirements.txt
uvicorn app.main:app --reload

```

## 3. Frontend Setup

Navigate to the frontend directory:

```bash
cd frontend
flutter pub get
flutter run

```

---

# Contributing

Contributions, bug reports, and feature suggestions are always welcome!

1. Fork the repository.
2. Create your feature branch (`git checkout -b feature/AmazingFeature`).
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`).
4. Push to the branch (`git push origin feature/AmazingFeature`).
5. Open a Pull Request.

---

# Download & Test the App (Release APK)

You can directly download and test the physical Android release build of FlowSync from the link below:

* **[Download FlowSync Release APK via Google Drive](https://drive.google.com/drive/folders/1KZ7TwCDymUL2U2gt1_b5SO_7L91Sfga2?usp=drive_link)** *(Directly installable on physical Android devices)*

# License

Developed for business management and advanced software engineering demonstration purposes.

---

**FlowSync** — *Manage Products. Control Inventory. Simplify Business.*
