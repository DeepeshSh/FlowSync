```markdown
# FlowSync — Enterprise ERP & Mobile Inventory Management Suite

> A modern, full-stack, enterprise-grade business management and inventory ERP system architected specifically to digitize, streamline, and scale the operational lifecycle of sanitary, plumbing, and hardware commercial enterprises.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Node.js](https://img.shields.io/badge/Node.js-18.x-339933?logo=node.js&logoColor=white)](https://nodejs.org)
[![Express.js](https://img.shields.io/badge/Express.js-4.x-000000?logo=express&logoColor=white)](https://expressjs.com)
[![MongoDB Atlas](https://img.shields.io/badge/MongoDB-Atlas-47A248?logo=mongodb&logoColor=white)](https://www.mongodb.com/atlas)
[![Firebase](https://img.shields.io/badge/Firebase-Auth-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

---

## Download & Test the App (Production Release APK)

You can directly download and install the signed production release build of FlowSync on any physical Android device:

* **[Download FlowSync Release APK via Google Drive](https://drive.google.com/drive/folders/1KZ7TwCDymUL2U2gt1_b5SO_7L91Sfga2?usp=drive_link)** *(Directly installable production binary)*

> **Installation Note for Android:**  
> Because this APK is downloaded outside the Google Play Store, select **Install Anyway** or enable **Allow from this source** if prompted by Google Play Protect during package parsing.

---

## Problem Domain & Industry Context

Sanitary, bath-fitting, and hardware distribution businesses operate under uniquely complex supply chain dynamics:
* **High-SKU Catalogs**: A single line item (e.g., CPVC Concealed Stop Cock) requires tracking across 10+ variant permutations (size, thread grade, finish).
* **Multi-Godown Decentralization**: Stock is split across retail display storefronts and off-site bulk godowns.
* **Complex Credit Accounting**: Frequent B2B credit cycles require rigorous tracking of aging accounts receivable (dealers/plumbers) and accounts payable (manufacturers/distributors).
* **Tax Compliance Overhead**: Multi-tier GST calculation with distinct SGST/CGST/IGST rates, transportation surcharges, and advance ledger rebalances.

Manual record-keeping via paper ledgers or non-synchronized spreadsheets inevitably causes stock-outs, double sales, uncollected revenue, and miscalculated margins. **FlowSync** solves these challenges by providing a single, coherent source of operational truth.

---

##  Technical Architecture & System Design

FlowSync is built on a decoupled, asynchronous client-server architecture engineered for high availability and zero data corruption:

```text
┌────────────────────────────────────────────────────────┐
│             Flutter Mobile Client (Dart)               │
│   Material 3 UI  •  State Mgmt  •  Offline Caching     │
└───────────────┬────────────────────────▲───────────────┘
                │                        │
       HTTPS / REST (JSON)      Signed JWT Bearer
                │                        │
┌───────────────▼────────────────────────┴───────────────┐
│           Node.js & Express REST API Engine            │
│  authMiddleware • Controller Validation • Rate Limiter │
└───────────────┬────────────────────────▲───────────────┘
                │                        │
      Mongoose ODM Drivers       ACID Data Models
                │                        │
┌───────────────▼────────────────────────┴───────────────┐
│        MongoDB Atlas Multi-Tenant Cloud Cluster        │
│  Indexed Queries • TTL Sessions • Isolated Records     │
└────────────────────────────────────────────────────────┘

```

### Complete Technology Stack

| Domain | Technology / Library | Architectural Role |
| --- | --- | --- |
| **Mobile Frontend** | **Flutter 3.x (Dart 3.x)** | High-performance, 60fps native client compiled with Material 3 design patterns. |
| **Document Engine** | **`pdf: ^3.10.8` & `printing**` | Vector-level PDF generation pipeline with dynamic pagination. |
| **State & Networking** | **`http`, `shared_preferences**` | Resilient network clients with exponential retry strategies and token caching. |
| **Backend Runtime** | **Node.js (LTS v18+)** | Non-blocking event-driven server runtime hosted on Render Cloud. |
| **API Framework** | **Express.js (v4.x)** | RESTful routing with strict middleware chains and JSON serialization guards. |
| **Database** | **MongoDB Atlas Cloud** | Distributed document database featuring multi-tenant models and compound indexes. |
| **Security & Auth** | **Firebase Auth & JWT (HS256)** | Cryptographically verified tokens with zero unverified OAuth bypasses. |
| **Compiler & Obfuscation** | **Android Gradle Plugin & R8** | Shrinking, dead-code elimination, and ProGuard obfuscation for release APKs. |

---

##  Key Functional Modules

### 1. Executive Operations Dashboard

* Aggregates real-time KPIs: Net Inventory Valuation, Total Active Products, Low-Stock Warnings, Today's Sales Volume, and Outstanding Balance.
* Displays aging stock indicators to identify dead capital sitting idle across warehouses.
* Quick-action triggers for creating sales invoices, purchasing shipments, adding customers, and stock transfers.

### 2. Multi-Warehouse Inventory & SKU Engine

* **Physical Godown Mapping**: Assign and view stock balances across distinct physical locations (e.g., *Main Godown*, *Shop Floor Showroom*, *Damaged Returns Section*).
* **Inter-Warehouse Stock Relocation**: Atomic stock transfers between godowns with historical audit logs.
* **Low-Stock Triggers**: Automated alerts when variant stock falls below safety margins.

### 3. Dynamic GST Billing & PDF Generation

* **Multi-Page Layout Engine**: Powered by `pw.MultiPage`, allowing invoices with 15–50+ line items to automatically split across pages with repeating headers and footers without crashing.
* **Statutory Currency Rendering**: Eliminates missing-character tofu boxes (`▯`) by substituting Unicode glyphs with normalized, font-safe `Rs. ` prefixes.
* **Tax Splitting**: Computes base subtotal, flat/percentage discounts, SGST/CGST/IGST splits, shipping costs, and advance payments.
* **Instant Distribution**: Native printing, system spooling, and PDF sharing via WhatsApp or email.

### 4. B2B Customer & Supplier Ledger (CRM)

* Dedicated profiles for Dealers, Contractors, Retail Walk-ins, and Primary Manufacturers.
* Maintains dynamic balance ledgers (`receivable` vs. `payable`).
* Stores statutory tax data (15-character GSTIN, billing addresses, primary phone contacts).

### 5. Onboarding & Multi-Trade Classification Gate

* Guards newly authenticated users by verifying trade setup before allowing app access.
* Classifies businesses into distinct operational categories:
* **Wholesaler** (Bulk trade, tiered discount pricing)
* **Retailer** (Counter POS, unified MRP sales)
* **Distributor** (Territory allocations, supplier pipelines)
* **Contractor** (Project billing, site delivery tracking)

---

##  Security Hardening & Pre-Flight Audit Verification

Before releasing this build, the entire codebase passed an exhaustive security audit and automated verification matrix:

* **Cryptographic Route Protection**: All API endpoints (`/api/invoices`, `/api/parties`, `/api/profile`, `/api/products`) are guarded by `authMiddleware`. Unauthenticated requests immediately fail with `401 Unauthorized`.
* **Zero Database Wipe Fallbacks**: Eradicated legacy unsafe queries (such as unparameterized `findOneAndDelete()`), ensuring accounts cannot be purged without valid credentials.
* **Sanitized Cloud Logging**: Server handlers strip passwords, auth tokens, and raw request payloads before writing to console streams or cloud collectors.
* **Protected Secrets Pipeline**: `.env` and `serviceAccountKey.json` files are excluded from version control via `.gitignore`.
* **Render Cold-Start Resilience**: Frontend network timeouts are set to **60 seconds**, handling free-tier container spin-ups gracefully without throwing premature `TimeoutException` alerts.
* **Release Signing & Integrity**: Android binary is compiled under JDK 17, minified with ProGuard/R8, and signed with a private 2048-bit RSA upload keystore.

---

##  Local Developer Installation & Setup

### Prerequisites

* **Flutter SDK**: `^3.19.0`
* **Node.js**: `v18.x` or higher
* **npm**: `v9.x` or higher
* **MongoDB**: A local instance or MongoDB Atlas Connection URI
* **Android Studio / VS Code** with Flutter extensions installed

---

### Backend Setup

1. Clone the repository and navigate to the backend directory:
```bash
git clone [https://github.com/DeepeshSh/FlowSync.git](https://github.com/DeepeshSh/FlowSync.git)
cd FlowSync/backend

```

2. Install backend dependencies:
```bash
npm install

```

3. Create your local environment configuration file:
```bash
cp .env.example .env

```

*Edit `.env` and supply your variables:*
```env
PORT=5000
MONGO_URI=mongodb+srv://<username>:<password>@cluster0.mongodb.net/flowsync?retryWrites=true&w=majority
JWT_SECRET=your_high_entropy_jwt_secret_key_here

```

4. Launch the API server:
```bash
npm run dev

```


*The backend will boot up at `http://localhost:5000`.*

---

### Mobile Client Setup

1. Open a new terminal and navigate to the project root:
```bash
cd FlowSync

```

2. Retrieve Flutter packages:
```bash
flutter pub get

```

3. Run static analysis and automated verification tests:
```bash
flutter analyze
flutter test

```

4. Launch the application in debug mode on a connected emulator or physical device:
```bash
flutter run

```

---

### Building the Production Release APK

To compile your own signed production binary:

1. Ensure your `android/key.properties` file is configured:
```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEYSTORE_PASSWORD
keyAlias=upload
storeFile=upload-keystore.jks

```

2. Execute the production build command:
```bash
flutter clean
flutter pub get
flutter build apk --release

```

3. The compiled binary will be generated at:
```text
build/app/outputs/flutter-apk/app-release.apk

```
