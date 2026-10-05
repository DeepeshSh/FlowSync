const mongoose = require('mongoose');
const dotenv = require('dotenv');

dotenv.config();

// Models
const Product = require('./models/Product');
const Party = require('./models/Party');
const Movement = require('./models/Movement');
const Invoice = require('./models/Invoice');
const User = require('./models/User');

const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/inventory';

async function seedDatabase() {
  try {
    console.log('Connecting to MongoDB...');
    await mongoose.connect(MONGO_URI);
    console.log('Connected to database.');

    // 1. Clean slate
    await Promise.all([
      Product.deleteMany({}),
      Party.deleteMany({}),
      Movement.deleteMany({}),
      Invoice.deleteMany({}),
    ]);
    console.log('Cleared existing products, parties, movements, and invoices.');

    const db = mongoose.connection.db;

   // 2. Categories with unique codes
    const categoriesCol = db.collection('categories');
    const getOrCreateCategory = async (name, code, description) => {
      let doc = await categoriesCol.findOne({ name });
      if (!doc) {
        const res = await categoriesCol.insertOne({
          name,
          code,
          description,
          createdAt: new Date()
        });
        return { _id: res.insertedId };
      }
      return doc;
    };

    const catSanitary = await getOrCreateCategory('Sanitaryware', 'CAT-SAN', 'Vitrified ceramic basins, water closets, and urinals');
    const catFaucets = await getOrCreateCategory('CP Faucets & Brassware', 'CAT-FAU', 'Chrome-plated brass faucets, mixers, and diverters');
    const catPipes = await getOrCreateCategory('Pipes & Plumbing Fittings', 'CAT-PIP', 'UPVC, CPVC, SWR drainage lines, and joineries');
    const catHardware = await getOrCreateCategory('Hardware & Installation Consumables', 'CAT-HDW', 'Angle cocks, connection tubes, drains, and adhesives');

    // 3. Warehouses with unique codes
    const warehousesCol = db.collection('warehouses');
    const getOrCreateWarehouse = async (name, code, location, capacity) => {
      let doc = await warehousesCol.findOne({ name });
      if (!doc) {
        const res = await warehousesCol.insertOne({
          name,
          code,
          location,
          capacity,
          createdAt: new Date()
        });
        return { _id: res.insertedId };
      }
      return doc;
    };

    const mainDepot = await getOrCreateWarehouse('Central GIDC Depot', 'WH-GIDC-01', 'GIDC Phase 2, Ahmedabad', 8000);
    const showroomStock = await getOrCreateWarehouse('City Showroom Basement', 'WH-SRM-02', 'Satellite Road, Ahmedabad', 2500);
   
    // 4. Default Business Profile
    await User.findOneAndUpdate(
      {},
      {
        name: 'Deepesh Shrivastava',
        email: 'deepesh@flowsync.local',
        phone: '+91 9876543210',
        businessName: 'Shrivastava Sanitary & Hardware Mart',
        gstin: '24AAECS1234F1Z5',
        tradeType: 'Wholesaler & Authorized Stockist',
        businessAddress: 'Shop 14-16, Commerce House, GIDC Commercial Zone, Ahmedabad, Gujarat - 380015',
        bankDetails: {
          bankName: 'HDFC Bank',
          accountNumber: '50200012345678',
          ifsc: 'HDFC0000123'
        }
      },
      { upsert: true, new: true }
    );
    console.log('Seeded Business Profile.');

    // 5. Products Catalog (Full Spectrum: Healthy, Low Stock, Depleted)
    const productsData = [
      // --- SANITARYWARE ---
      {
        name: 'Wall-Hung Rimless Commode with Soft-Close Seat (Alpine White)',
        sku: 'SAN-WHC-001',
        brandName: 'Somany',
        category: catSanitary._id,
        warehouseId: mainDepot._id,
        purchasePrice: 4200,
        sellingPrice: 6850,
        price: 6850,
        stock: 3, // LOW STOCK
        minStockAlert: 8
      },
      {
        name: 'One-Piece Vitrified S-Trap Water Closet (Gloss Ivory)',
        sku: 'SAN-OPC-002',
        brandName: 'Cera',
        category: catSanitary._id,
        warehouseId: mainDepot._id,
        purchasePrice: 5100,
        sellingPrice: 8200,
        price: 8200,
        stock: 14,
        minStockAlert: 10
      },
      {
        name: 'Oval Ceramic Table Top Wash Basin 550x400mm (Matte Black)',
        sku: 'SAN-TTB-003',
        brandName: 'Hindware',
        category: catSanitary._id,
        warehouseId: showroomStock._id,
        purchasePrice: 1950,
        sellingPrice: 3400,
        price: 3400,
        stock: 2, // LOW STOCK
        minStockAlert: 6
      },
      {
        name: 'Wall Mount Half-Pedestal Wash Basin 450x350mm (Snow White)',
        sku: 'SAN-PWB-004',
        brandName: 'Cera',
        category: catSanitary._id,
        warehouseId: mainDepot._id,
        purchasePrice: 1100,
        sellingPrice: 1850,
        price: 1850,
        stock: 28,
        minStockAlert: 10
      },
      {
        name: 'Sensor Half-Stall Urinal with Integrated Spreader',
        sku: 'SAN-URN-005',
        brandName: 'Somany',
        category: catSanitary._id,
        warehouseId: mainDepot._id,
        purchasePrice: 3400,
        sellingPrice: 5900,
        price: 5900,
        stock: 0, // OUT OF STOCK
        minStockAlert: 5
      },

      // --- FAUCETS & BRASSWARE ---
      {
        name: 'Single Lever High-Neck Basin Mixer for Counter Basins',
        sku: 'CP-SBM-101',
        brandName: 'Jaquar',
        category: catFaucets._id,
        warehouseId: showroomStock._id,
        purchasePrice: 2100,
        sellingPrice: 3650,
        price: 3650,
        stock: 22,
        minStockAlert: 10
      },
      {
        name: 'Thermostatic Concealed Diverter (High Flow 40mm)',
        sku: 'CP-DIV-102',
        brandName: 'Jaquar',
        category: catFaucets._id,
        warehouseId: mainDepot._id,
        purchasePrice: 3800,
        sellingPrice: 6200,
        price: 6200,
        stock: 12,
        minStockAlert: 8
      },
      {
        name: 'Brass 2-in-1 Bib Cock with Wall Flange',
        sku: 'CP-BBC-103',
        brandName: 'Parryware',
        category: catFaucets._id,
        warehouseId: mainDepot._id,
        purchasePrice: 620,
        sellingPrice: 1150,
        price: 1150,
        stock: 45,
        minStockAlert: 15
      },
      {
        name: 'SS 304 Overhead Slim Rain Shower 10x10 Inch with Arm',
        sku: 'CP-SHW-104',
        brandName: 'Hindware',
        category: catFaucets._id,
        warehouseId: showroomStock._id,
        purchasePrice: 1250,
        sellingPrice: 2450,
        price: 2450,
        stock: 4, // LOW STOCK
        minStockAlert: 10
      },
      {
        name: 'Heavy Brass Health Faucet with 1.2m SS Flexible Tube',
        sku: 'CP-HLF-105',
        brandName: 'Jaquar',
        category: catFaucets._id,
        warehouseId: mainDepot._id,
        purchasePrice: 480,
        sellingPrice: 950,
        price: 950,
        stock: 35,
        minStockAlert: 12
      },

      // --- PIPES & DRAINAGE ---
      {
        name: 'CPVC Pro Cold & Hot Water Pipe 3/4 Inch (3 Meter SDR-11)',
        sku: 'PIP-CPVC-201',
        brandName: 'Astral',
        category: catPipes._id,
        warehouseId: mainDepot._id,
        purchasePrice: 240,
        sellingPrice: 380,
        price: 380,
        stock: 140,
        minStockAlert: 30
      },
      {
        name: 'UPVC Heavy Pressure Plumbing Pipe 1 Inch (3 Meter Class-2)',
        sku: 'PIP-UPVC-202',
        brandName: 'Supreme',
        category: catPipes._id,
        warehouseId: mainDepot._id,
        purchasePrice: 290,
        sellingPrice: 440,
        price: 440,
        stock: 95,
        minStockAlert: 25
      },
      {
        name: 'SWR Drainage Pipe with Rubber Ring 110mm 4 Inch (3 Meter)',
        sku: 'PIP-SWR-203',
        brandName: 'Supreme',
        category: catPipes._id,
        warehouseId: mainDepot._id,
        purchasePrice: 580,
        sellingPrice: 890,
        price: 890,
        stock: 40,
        minStockAlert: 15
      },
      {
        name: 'CPVC Brass Female Threaded Adaptor (FTA) 3/4 x 1/2 Inch',
        sku: 'FIT-FTA-204',
        brandName: 'Astral',
        category: catPipes._id,
        warehouseId: mainDepot._id,
        purchasePrice: 65,
        sellingPrice: 120,
        price: 120,
        stock: 1, // LOW STOCK
        minStockAlert: 20
      },
      {
        name: 'Heavy Duty Fast Setting CPVC Solvent Cement 500ml',
        sku: 'SOL-CPV-205',
        brandName: 'Astral',
        category: catPipes._id,
        warehouseId: mainDepot._id,
        purchasePrice: 260,
        sellingPrice: 410,
        price: 410,
        stock: 18,
        minStockAlert: 10
      },

      // --- HARDWARE & ACCESSORIES ---
      {
        name: 'SS 304 Anti-Foul Floor Drain Trap with Cockroach Trap 5x5',
        sku: 'HDW-DRN-301',
        brandName: 'Chilly',
        category: catHardware._id,
        warehouseId: mainDepot._id,
        purchasePrice: 280,
        sellingPrice: 520,
        price: 520,
        stock: 60,
        minStockAlert: 15
      },
      {
        name: 'Forged Brass Angular Stop Cock with Wall Flange 1/2 Inch',
        sku: 'HDW-ANG-302',
        brandName: 'Jaquar',
        category: catHardware._id,
        warehouseId: mainDepot._id,
        purchasePrice: 380,
        sellingPrice: 690,
        price: 690,
        stock: 50,
        minStockAlert: 20
      },
      {
        name: 'Braided SS 304 Geyser Connection Pipe 24 Inch (Pair)',
        sku: 'HDW-CNP-303',
        brandName: 'Supreme',
        category: catHardware._id,
        warehouseId: mainDepot._id,
        purchasePrice: 140,
        sellingPrice: 280,
        price: 280,
        stock: 0, // OUT OF STOCK
        minStockAlert: 15
      }
    ];

    const insertedProducts = await Product.insertMany(productsData);
    console.log(`Seeded ${insertedProducts.length} Products with purchasePrice and sellingPrice.`);

    // 6. Comprehensive Parties (Suppliers, Dealers, Contractors, Retailers)
    const partiesData = [
      // SUPPLIERS (Negative Balance = You owe them)
      {
        name: 'Bhavin Patel',
        businessName: 'Somany Ceramics Morbi Plant Depot',
        type: 'SUPPLIER',
        phone: '+91 9825123456',
        email: 'orders.morbi@somanyceramics.com',
        gstin: '24AAACS1122D1Z4',
        address: 'National Highway 8A, Morbi, Gujarat - 363642',
        currentBalance: -145000,
        creditLimit: 500000
      },
      {
        name: 'Ramesh Mehta',
        businessName: 'Jaquar Sanitaryware Regional Stockist',
        type: 'SUPPLIER',
        phone: '+91 9898012345',
        email: 'billing@jaquarstockist.in',
        gstin: '24AABCR3344E1Z8',
        address: 'Narol Industrial Estate, Ahmedabad - 382405',
        currentBalance: -88500,
        creditLimit: 300000
      },
      {
        name: 'Ketan Shah',
        businessName: 'Astral Pipes Gujarat Central Agency',
        type: 'SUPPLIER',
        phone: '+91 9824098765',
        email: 'supply@astralguajarat.com',
        gstin: '24AAACT5566F1Z1',
        address: 'Changodar Highway, Ahmedabad - 382213',
        currentBalance: 0,
        creditLimit: 250000
      },

      // DEALERS / CONTRACTORS (Positive Balance = They owe you)
      {
        name: 'Sunil Varma',
        businessName: 'Varma Luxury Plumbers & Interior Solutions',
        type: 'DEALER',
        phone: '+91 9426543210',
        email: 'sunil@varmabuilders.com',
        gstin: '24AAGPV9900J1Z6',
        address: 'Commerce Centre, Prahlad Nagar, Ahmedabad',
        currentBalance: 64200,
        creditLimit: 150000
      },
      {
        name: 'Hardik Prajapati',
        businessName: 'Prajapati Infrastructure Projects',
        type: 'DEALER',
        phone: '+91 9712345678',
        email: 'hardik@prajapatigroup.com',
        gstin: '24AAHFP4455K1Z9',
        address: 'Near Iscon Cross Road, SG Highway, Ahmedabad',
        currentBalance: 122800,
        creditLimit: 200000
      },
      {
        name: 'Manish Patel',
        businessName: 'Ambica Hardware & Electricals (Sub-Dealer)',
        type: 'DEALER',
        phone: '+91 9825987654',
        email: 'ambica.hardware@gmail.com',
        gstin: '24AAJPA8877L1Z0',
        address: 'Station Road, Kalol, Gandhinagar',
        currentBalance: 18400,
        creditLimit: 50000
      },

      // RETAIL CUSTOMERS
      {
        name: 'Dr. Anand Joshi',
        businessName: 'Bungalow Renovation Project',
        type: 'CUSTOMER',
        phone: '+91 9909011223',
        email: 'anand.joshi@gmail.com',
        gstin: '',
        address: 'Gulmohar Greens Villa 42, Sanand Road, Ahmedabad',
        currentBalance: 8500,
        creditLimit: 25000
      },
      {
        name: 'Mrs. Neha Shah',
        businessName: 'Retail Walk-in Customer',
        type: 'CUSTOMER',
        phone: '+91 9879512345',
        email: 'nehashah92@gmail.com',
        gstin: '',
        address: 'B-601, Shivalik Residency, Vastrapur, Ahmedabad',
        currentBalance: 0,
        creditLimit: 0
      }
    ];

    const insertedParties = await Party.insertMany(partiesData);
    console.log(`Seeded ${insertedParties.length} Parties across Suppliers, Dealers, and Retail Customers.`);

    // 7. Audit Ledger & Movement History
    const movementsData = [
      {
        productId: insertedProducts[0]._id, // Wall Hung Commode
        type: 'DAMAGE',
        quantity: 2,
        previousStock: 5,
        newStock: 3,
        reason: 'Cracked rim during unloading pallet inspection',
        reference: 'DAM-2026-08',
        timestamp: new Date(Date.now() - 3600000 * 3)
      },
      {
        productId: insertedProducts[2]._id, // Table Top Basin
        type: 'DAMAGE',
        quantity: 1,
        previousStock: 3,
        newStock: 2,
        reason: 'Matte glaze chip during showroom shelf transit',
        reference: 'DAM-2026-09',
        timestamp: new Date(Date.now() - 3600000 * 18)
      },
      {
        productId: insertedProducts[4]._id, // Urinal
        type: 'STOCK_OUT',
        quantity: 6,
        previousStock: 6,
        newStock: 0,
        reason: 'Commercial order dispatch for Prajapati Projects',
        reference: 'DISP-4402',
        timestamp: new Date(Date.now() - 3600000 * 36)
      },
      {
        productId: insertedProducts[5]._id, // Jaquar Basin Mixer
        type: 'STOCK_IN',
        quantity: 25,
        previousStock: 2,
        newStock: 27,
        reason: 'Authorized distributor seasonal consignment',
        reference: 'GRN-JAQ-901',
        timestamp: new Date(Date.now() - 3600000 * 72)
      },
      {
        productId: insertedProducts[10]._id, // CPVC Pipes
        type: 'STOCK_IN',
        quantity: 150,
        previousStock: 40,
        newStock: 190,
        reason: 'Bulk bundle replenishment',
        reference: 'GRN-AST-114',
        timestamp: new Date(Date.now() - 3600000 * 120)
      }
    ];

    await Movement.insertMany(movementsData);
    console.log(`Seeded ${movementsData.length} Stock Movement audit entries.`);

    // 8. Tax Invoices & Purchase Bills
    const invoicesData = [
      // TAX SALE INVOICE 1: Dealer (Partial Paid)
      {
        invoiceNumber: 'INV-2026-101',
        type: 'SALE',
        partyId: insertedParties[3]._id,
        partyName: insertedParties[3].businessName,
        items: [
          {
            productId: insertedProducts[0]._id,
            productName: insertedProducts[0].name,
            quantity: 4,
            rate: insertedProducts[0].sellingPrice,
            gstRate: 18,
            amount: 27400
          },
          {
            productId: insertedProducts[5]._id,
            productName: insertedProducts[5].name,
            quantity: 4,
            rate: insertedProducts[5].sellingPrice,
            gstRate: 18,
            amount: 14600
          },
          {
            productId: insertedProducts[15]._id,
            productName: insertedProducts[15].name,
            quantity: 10,
            rate: insertedProducts[15].sellingPrice,
            gstRate: 18,
            amount: 5200
          }
        ],
        subtotal: 47200,
        gstTotal: 8496,
        grandTotal: 55696,
        paymentStatus: 'PARTIAL',
        notes: 'Delivered to site. 50% paid via NEFT, balance due within 15 days.',
        date: new Date(Date.now() - 3600000 * 6)
      },

      // TAX SALE INVOICE 2: Retail Customer (Paid Full)
      {
        invoiceNumber: 'INV-2026-102',
        type: 'SALE',
        partyId: insertedParties[6]._id,
        partyName: insertedParties[6].name,
        items: [
          {
            productId: insertedProducts[2]._id,
            productName: insertedProducts[2].name,
            quantity: 1,
            rate: insertedProducts[2].sellingPrice,
            gstRate: 18,
            amount: 3400
          },
          {
            productId: insertedProducts[9]._id,
            productName: insertedProducts[9].name,
            quantity: 2,
            rate: insertedProducts[9].sellingPrice,
            gstRate: 18,
            amount: 1900
          }
        ],
        subtotal: 5300,
        gstTotal: 954,
        grandTotal: 6254,
        paymentStatus: 'PAID',
        notes: 'Paid via UPI instant settlement.',
        date: new Date(Date.now() - 3600000 * 24)
      },

      // TAX SALE INVOICE 3: Infrastructure Contractor (Unpaid)
      {
        invoiceNumber: 'INV-2026-103',
        type: 'SALE',
        partyId: insertedParties[4]._id,
        partyName: insertedParties[4].businessName,
        items: [
          {
            productId: insertedProducts[11]._id,
            productName: insertedProducts[11].name,
            quantity: 50,
            rate: insertedProducts[11].sellingPrice,
            gstRate: 18,
            amount: 22000
          },
          {
            productId: insertedProducts[12]._id,
            productName: insertedProducts[12].name,
            quantity: 30,
            rate: insertedProducts[12].sellingPrice,
            gstRate: 18,
            amount: 26700
          }
        ],
        subtotal: 48700,
        gstTotal: 8766,
        grandTotal: 57466,
        paymentStatus: 'UNPAID',
        notes: '30-day corporate credit terms applicable.',
        date: new Date(Date.now() - 3600000 * 48)
      },

      // PURCHASE BILL 1: Factory Restock (Unpaid)
      {
        invoiceNumber: 'PUR-SOM-881',
        type: 'PURCHASE',
        partyId: insertedParties[0]._id,
        partyName: insertedParties[0].businessName,
        items: [
          {
            productId: insertedProducts[0]._id,
            productName: insertedProducts[0].name,
            quantity: 15,
            rate: insertedProducts[0].purchasePrice,
            gstRate: 18,
            amount: 63000
          },
          {
            productId: insertedProducts[1]._id,
            productName: insertedProducts[1].name,
            quantity: 10,
            rate: insertedProducts[1].purchasePrice,
            gstRate: 18,
            amount: 51000
          }
        ],
        subtotal: 114000,
        gstTotal: 20520,
        grandTotal: 134520,
        paymentStatus: 'UNPAID',
        notes: 'Consignment received at Central GIDC Depot with e-Way Bill.',
        date: new Date(Date.now() - 3600000 * 96)
      },

      // PURCHASE BILL 2: Brassware Stockist (Paid)
      {
        invoiceNumber: 'PUR-JAQ-412',
        type: 'PURCHASE',
        partyId: insertedParties[1]._id,
        partyName: insertedParties[1].businessName,
        items: [
          {
            productId: insertedProducts[5]._id,
            productName: insertedProducts[5].name,
            quantity: 20,
            rate: insertedProducts[5].purchasePrice,
            gstRate: 18,
            amount: 42000
          },
          {
            productId: insertedProducts[6]._id,
            productName: insertedProducts[6].name,
            quantity: 10,
            rate: insertedProducts[6].purchasePrice,
            gstRate: 18,
            amount: 38000
          }
        ],
        subtotal: 80000,
        gstTotal: 14400,
        grandTotal: 94400,
        paymentStatus: 'PAID',
        notes: 'Full payment cleared via RTGS.',
        date: new Date(Date.now() - 3600000 * 168)
      }
    ];

    await Invoice.insertMany(invoicesData);
    console.log(`Seeded ${invoicesData.length} Invoices with line items, GST totals, and status.`);

    console.log('\n======================================================');
    console.log('✅ COMPREHENSIVE PRODUCTION DATA SEEDING COMPLETE!');
    console.log('======================================================');
    console.log('• Products: 18 SKUs (Includes purchasePrice & sellingPrice)');
    console.log('• Low Stock Items: 5 SKUs ready to trigger alerts');
    console.log('• Out of Stock Items: 2 SKUs');
    console.log('• Parties: 8 Contacts (Suppliers, Dealers, Retail)');
    console.log('• Movements: 5 Records (Damaged, Consignments, Dispatches)');
    console.log('• Invoices: 5 Invoices (Sales & Purchases with GST & Status)');
    console.log('======================================================\n');

    process.exit(0);
  } catch (error) {
    console.error('❌ Seeding failed:', error);
    process.exit(1);
  }
}

seedDatabase();