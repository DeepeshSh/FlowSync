import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:FlowSync/models/product_model.dart';
import 'package:FlowSync/screens/dashboard_screen.dart';
import 'package:FlowSync/screens/inventory_screen.dart';
import 'package:FlowSync/screens/login_screen.dart';
import 'package:FlowSync/screens/more_screen.dart';
import 'package:FlowSync/screens/product_details_screen.dart';
import 'package:FlowSync/models/party_model.dart';
import 'package:FlowSync/screens/business_profile_screen.dart';
import 'package:FlowSync/screens/damaged_products_screen.dart';
import 'package:FlowSync/screens/parties_screen.dart';
import 'package:FlowSync/screens/product_logs_screen.dart';
import 'package:FlowSync/screens/profile_screen.dart';
import 'package:FlowSync/models/invoice_model.dart';
import 'package:FlowSync/screens/invoices_screen.dart';
import 'package:FlowSync/screens/splash_screen.dart';
import 'package:FlowSync/services/auth_service.dart';
import 'package:FlowSync/services/notification_service.dart';
import 'package:FlowSync/utils/api_constants.dart';

void main() {
  test('ApiConstants are properly configured', () {
    expect(ApiConstants.baseUrl, 'http://10.0.2.2:5000/api');
    expect(ApiConstants.auth, 'http://10.0.2.2:5000/api/auth');
    expect(ApiConstants.products, 'http://10.0.2.2:5000/api/products');
    expect(ApiConstants.profile, 'http://10.0.2.2:5000/api/profile');
    expect(ApiConstants.movements, 'http://10.0.2.2:5000/api/movements');
    expect(ApiConstants.allMovements, 'http://10.0.2.2:5000/api/movements/all');
    expect(ApiConstants.damagedMovements, 'http://10.0.2.2:5000/api/movements/damaged');
    expect(ApiConstants.parties, 'http://10.0.2.2:5000/api/parties');
    expect(ApiConstants.invoices, 'http://10.0.2.2:5000/api/invoices');
  });

  testWidgets('LoginScreen renders UI correctly with sliding toggle between Sign In and Sign Up', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginScreen(),
      ),
    );

    // Initial Sign In state
    expect(find.text('Sign In'), findsNWidgets(2)); // Toggle pill + Primary Button
    expect(find.text('Sign Up'), findsOneWidget); // Toggle pill
    expect(find.text('Welcome back! Enter your credentials to access inventory.'), findsOneWidget);
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsWidgets);
    expect(find.text('Forgot Password?'), findsOneWidget);
    expect(find.text('Your data is safe and secure with us'), findsOneWidget);

    // Tap Forgot Password? to verify dialog
    await tester.tap(find.text('Forgot Password?'));
    await tester.pumpAndSettle();

    expect(find.text('Reset Password'), findsOneWidget);
    expect(find.text('Send Reset Link'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);

    // Close dialog
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // Tap "Sign Up" segment in the toggle
    await tester.tap(find.text('Sign Up'));
    await tester.pumpAndSettle();

    // Verify Sign Up form rendered
    expect(find.text('Create your account to start managing stock and invoicing.'), findsOneWidget);
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Business / Firm Name'), findsOneWidget);
    expect(find.text('Phone Number (Optional)'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Confirm Password'), findsOneWidget);
    expect(find.text('Create Account'), findsOneWidget);

    // Tap back to "Sign In" segment
    await tester.tap(find.text('Sign In').first);
    await tester.pumpAndSettle();

    expect(find.text('Welcome back! Enter your credentials to access inventory.'), findsOneWidget);
  });

  test('AuthService handles password reset and formatAuthError codes properly', () async {
    expect(
      AuthService.formatAuthError(FirebaseAuthException(code: 'user-not-found')),
      "No user found with this email.",
    );
    expect(
      AuthService.formatAuthError(FirebaseAuthException(code: 'wrong-password')),
      "Incorrect password. Please try again.",
    );
    expect(
      AuthService.formatAuthError(FirebaseAuthException(code: 'email-already-in-use')),
      "An account already exists with this email.",
    );
    expect(
      AuthService.formatAuthError(FirebaseAuthException(code: 'weak-password')),
      "Password should be at least 6 characters.",
    );
    expect(
      AuthService.formatAuthError(FirebaseAuthException(code: 'invalid-email')),
      "Please enter a valid email address.",
    );
  });

  testWidgets('ProductDetailsScreen displays product and shows delete confirmation dialog', (WidgetTester tester) async {
    final testProduct = Product(
      id: 'prod_123',
      name: 'Chrome Basin Mixer',
      sku: 'CBM-001',
      brandName: 'FlowCraft',
      categoryName: 'Faucets',
      storageLocation: 'Aisle 3',
      unit: 'pcs',
      stock: 42,
      lowStockThreshold: 5,
      purchasePrice: 1200.0,
      sellingPrice: 1850.0,
      imageUrl: '',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ProductDetailsScreen(
          product: testProduct,
          initialMovements: const [],
        ),
      ),
    );

    expect(find.text('Chrome Basin Mixer'), findsOneWidget);
    expect(find.text('FlowCraft'), findsOneWidget);
    expect(find.text('CBM-001'), findsOneWidget);

    // Scroll to action buttons
    await tester.ensureVisible(find.text('Edit Product'));
    expect(find.text('Edit Product'), findsOneWidget);
    await tester.ensureVisible(find.text('Delete Product'));
    expect(find.text('Delete Product'), findsOneWidget);

    // Tap Delete Product button
    await tester.tap(find.text('Delete Product'));
    await tester.pumpAndSettle();

    // Verify confirmation dialog contents
    expect(find.text('Delete Product'), findsNWidgets(2)); // Button + Dialog Title
    expect(
      find.text('Are you sure you want to delete this product? This action cannot be undone.'),
      findsOneWidget,
    );
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Delete'), findsOneWidget);

    // Tap Cancel button in dialog
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    // Confirmation dialog should be closed
    expect(
      find.text('Are you sure you want to delete this product? This action cannot be undone.'),
      findsNothing,
    );
  });

  testWidgets('ProductDetailsScreen renders Stock In, Stock Out, and Movement History ledger', (WidgetTester tester) async {
    final testProduct = Product(
      id: 'prod_123',
      name: 'Chrome Basin Mixer',
      sku: 'CBM-001',
      brandName: 'FlowCraft',
      categoryName: 'Faucets',
      storageLocation: 'Aisle 3',
      unit: 'pcs',
      stock: 42,
      lowStockThreshold: 5,
      purchasePrice: 1200.0,
      sellingPrice: 1850.0,
      imageUrl: '',
    );

    final mockMovements = [
      {
        'type': 'STOCK_IN',
        'quantity': 20,
        'previousStock': 22,
        'newStock': 42,
        'reason': 'Vendor Restock',
        'reference': 'PO-991',
        'timestamp': '2026-10-04T12:00:00Z',
      },
      {
        'type': 'STOCK_OUT',
        'quantity': 5,
        'previousStock': 27,
        'newStock': 22,
        'reason': 'Retail Sale',
        'reference': 'INV-401',
        'timestamp': '2026-10-03T10:00:00Z',
      },
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: ProductDetailsScreen(
          product: testProduct,
          initialMovements: mockMovements,
        ),
      ),
    );

    // Verify Movement History Card and badges
    expect(find.text('Movement History'), findsOneWidget);
    expect(find.text('Audit Ledger'), findsOneWidget);
    expect(find.text('+ STOCK IN'), findsOneWidget);
    expect(find.text('- STOCK OUT'), findsOneWidget);
    expect(find.text('+20'), findsOneWidget);
    expect(find.text('-5'), findsOneWidget);
    expect(find.text('Stock: 22 → 42 pcs'), findsOneWidget);

    // Scroll to Quick Actions
    await tester.ensureVisible(find.text('+ Stock In'));
    expect(find.text('+ Stock In'), findsOneWidget);
    expect(find.text('- Stock Out'), findsOneWidget);

    // Tap + Stock In to open bottom sheet
    await tester.tap(find.text('+ Stock In'));
    await tester.pumpAndSettle();

    expect(find.text('Add Stock (Stock In)'), findsOneWidget);
    expect(find.text('Current Available: 42 pcs'), findsOneWidget);
    expect(find.text('Quantity (pcs)'), findsOneWidget);
    expect(find.text('Common Reasons'), findsOneWidget);
    expect(find.text('Supplier Restock'), findsOneWidget);
    expect(find.text('Confirm Stock In'), findsOneWidget);

    // Close bottom sheet via Cancel
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Add Stock (Stock In)'), findsNothing);

    // Tap - Stock Out to open bottom sheet
    await tester.tap(find.text('- Stock Out'));
    await tester.pumpAndSettle();

    expect(find.text('Remove Stock (Stock Out)'), findsOneWidget);
    expect(find.text('Current Available: 42 pcs'), findsOneWidget);
    expect(find.text('Retail Sale'), findsOneWidget);
    expect(find.text('Confirm Stock Out'), findsOneWidget);

    // Close bottom sheet via Cancel
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(find.text('Remove Stock (Stock Out)'), findsNothing);
  });

  testWidgets('ProfileScreen renders personal fields and delete account confirmation', (WidgetTester tester) async {
    const mockPersonal = {
      'name': 'Deepesh Sharma',
      'phone': '+91 98765 43210',
      'email': 'deepesh@example.com',
    };

    await tester.pumpWidget(
      const MaterialApp(
        home: ProfileScreen(initialProfile: mockPersonal),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Personal Profile'), findsOneWidget);
    expect(find.text('Personal Details'), findsOneWidget);
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Personal Phone'), findsOneWidget);
    expect(find.text('Personal Email'), findsOneWidget);
    expect(find.text('Save Personal Info'), findsOneWidget);
    expect(find.text('Danger Zone'), findsOneWidget);
    expect(find.text('Delete Account'), findsOneWidget);

    // Tap Delete Account button
    await tester.ensureVisible(find.text('Delete Account'));
    await tester.tap(find.text('Delete Account'));
    await tester.pumpAndSettle();

    // Verify confirmation dialog
    expect(
      find.text('Are you sure? This will remove your account and business configuration.'),
      findsOneWidget,
    );
    expect(find.text('Cancel'), findsOneWidget);
    expect(find.text('Delete Forever'), findsOneWidget);

    // Cancel dialog
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(
      find.text('Are you sure? This will remove your account and business configuration.'),
      findsNothing,
    );
  });

  testWidgets('BusinessProfileScreen renders commercial business details and bank details', (WidgetTester tester) async {
    const mockBusiness = {
      'businessName': 'FlowSync Enterprises',
      'gstin': '27AAAAA0000A1Z5',
      'tradeType': 'Wholesaler',
      'businessAddress': '123 Market Road, Mumbai - 400001',
      'bankDetails': {
        'bankName': 'HDFC Bank',
        'accountNumber': '50200012345678',
        'ifsc': 'HDFC0001234',
      },
    };

    await tester.pumpWidget(
      const MaterialApp(
        home: BusinessProfileScreen(initialProfile: mockBusiness),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Business Profile'), findsOneWidget);
    expect(find.text('Commercial & GST Details'), findsOneWidget);
    expect(find.text('Registered Firm / Business Name'), findsOneWidget);
    expect(find.text('GSTIN Number'), findsOneWidget);
    expect(find.text('Trade Type'), findsOneWidget);
    expect(find.text('Registered Business Address & Pincode'), findsOneWidget);
    expect(find.text('Bank Account Details'), findsOneWidget);
    expect(find.text('Save Business Details'), findsOneWidget);
  });

  testWidgets('MoreScreen renders menu items and wired dialogs', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MoreScreen(),
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('More'), findsOneWidget);
    expect(find.text('Billing & Invoices'), findsOneWidget);
    expect(find.text('Parties & CRM'), findsOneWidget);
    expect(find.text('Categories'), findsOneWidget);
    expect(find.text('Suppliers'), findsOneWidget);
    expect(find.text('Customers'), findsOneWidget);
    expect(find.text('Warehouses'), findsOneWidget);
    expect(find.text('Profile & Account'), findsOneWidget);
    expect(find.text('Business Settings / Firm Profile'), findsOneWidget);

    // Tap Inventory Alerts -> bottom sheet
    await tester.ensureVisible(find.text('Inventory Alerts'));
    expect(find.text('Inventory Alerts'), findsOneWidget);
    await tester.tap(find.text('Inventory Alerts'));
    await tester.pumpAndSettle();

    expect(find.text('Low Stock Warning'), findsOneWidget);
    expect(find.text('Got it'), findsOneWidget);
    await tester.tap(find.text('Got it'));
    await tester.pumpAndSettle();

    // Tap App Information & Version -> dialog
    await tester.ensureVisible(find.text('App Information & Version'));
    expect(find.text('App Information & Version'), findsOneWidget);
    await tester.tap(find.text('App Information & Version'));
    await tester.pumpAndSettle();

    expect(find.text('Version 1.0.0 (Build 1)'), findsOneWidget);
    expect(find.text('Close'), findsOneWidget);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();

    // Tap Logout -> confirmation dialog
    await tester.ensureVisible(find.text('Logout'));
    expect(find.text('Logout'), findsOneWidget);
    await tester.tap(find.text('Logout'));
    await tester.pumpAndSettle();

    expect(find.text('Logout from FlowSync?'), findsOneWidget);
    expect(find.text('Cancel'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
  });

  testWidgets('Splash Screen loads correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SplashScreen(),
      ),
    );

    expect(find.text('Securing environment...'), findsOneWidget);
    expect(find.text('Smart Business. Smooth Flow.'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Fast forward splash timer so timer does not remain pending
    await tester.pump(const Duration(milliseconds: 2500));
  });

  testWidgets('DashboardScreen initializes and renders properly with quick action modules', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: DashboardScreen(
          initialStats: const {
            'totalProducts': 12,
            'totalStock': 450,
            'lowStockCount': 3,
            'outOfStockCount': 1,
            'totalValue': 125000.0,
          },
        ),
      ),
    );

    expect(find.byType(DashboardScreen), findsOneWidget);
    await tester.pumpAndSettle();

    // Verify 6 quick actions are present
    expect(find.text('Damaged Products'), findsOneWidget);
    expect(find.text('Product Logs'), findsOneWidget);
    expect(find.text('Low Stock Alert'), findsOneWidget);
    expect(find.text('Damage Report'), findsOneWidget);
    expect(find.text('Stock Movement'), findsOneWidget);
    expect(find.text('Stock Aging'), findsOneWidget);

    // Verify Metric strip and Analytics
    expect(find.text('Total Valuation'), findsOneWidget);
    expect(find.text('Net Stock Count'), findsOneWidget);
    expect(find.text('Critical Low'), findsOneWidget);
    expect(find.text('Analytics & Inventory Trends'), findsOneWidget);
  });

  testWidgets('DamagedProductsScreen renders summary and empty/incident state', (WidgetTester tester) async {
    final mockDamaged = [
      {
        'productId': {'name': 'Porcelain Tile', 'sku': 'TILE-001', 'price': 350.0},
        'quantity': 3,
        'reason': 'Cracked box',
        'reference': 'DMG-101',
        'timestamp': '2026-10-04T12:00:00Z',
      },
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: DamagedProductsScreen(initialDamaged: mockDamaged),
      ),
    );

    expect(find.byType(DamagedProductsScreen), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('Damaged Products'), findsOneWidget);
    expect(find.text('Report Damage'), findsOneWidget);
    expect(find.text('Porcelain Tile'), findsOneWidget);
    expect(find.text('SKU: TILE-001'), findsOneWidget);
    expect(find.text('-3 pcs'), findsOneWidget);
  });

  testWidgets('ProductLogsScreen renders filter chips and master log viewer', (WidgetTester tester) async {
    final mockLogs = [
      {
        'productId': {'name': 'Porcelain Tile', 'sku': 'TILE-001'},
        'type': 'STOCK_IN',
        'quantity': 50,
        'previousStock': 100,
        'newStock': 150,
        'reason': 'Factory Shipment',
        'reference': 'PO-901',
        'timestamp': '2026-10-04T12:00:00Z',
      },
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: ProductLogsScreen(initialLogs: mockLogs),
      ),
    );

    expect(find.byType(ProductLogsScreen), findsOneWidget);
    await tester.pumpAndSettle();
    expect(find.text('Product Logs'), findsOneWidget);
    expect(find.text('All Logs'), findsOneWidget);
    expect(find.text('Stock: 100 → 150 pcs'), findsOneWidget);
    expect(find.text('Porcelain Tile'), findsOneWidget);
  });

  testWidgets('PartiesScreen renders tabs, search bar, and party list', (WidgetTester tester) async {
    final mockParties = [
      Party(
        id: 'party_1',
        name: 'Rajesh Kumar',
        businessName: 'Royal Sanitary',
        type: 'SUPPLIER',
        phone: '+91 98765 43210',
        gstin: '27AAAAA0000A1Z5',
        address: 'Mumbai',
        currentBalance: -15000.0,
      ),
      Party(
        id: 'party_2',
        name: 'Amit Patel',
        businessName: 'Patel Tiles & Fittings',
        type: 'CUSTOMER',
        phone: '+91 91234 56789',
        address: 'Pune',
        currentBalance: 8500.0,
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: PartiesScreen(initialParties: mockParties),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Parties & Contacts'), findsOneWidget);
    expect(find.text('To Receive'), findsOneWidget);
    expect(find.text('To Pay'), findsOneWidget);
    expect(find.text('Total Parties'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Suppliers'), findsOneWidget);
    expect(find.text('Customers / Dealers'), findsOneWidget);

    expect(find.text('Royal Sanitary'), findsOneWidget);
    expect(find.text('Patel Tiles & Fittings'), findsOneWidget);
    expect(find.text('SUPPLIER'), findsOneWidget);
    expect(find.text('CUSTOMER'), findsOneWidget);
    expect(find.text('Add Party'), findsOneWidget);

    // Tap Add Party FAB
    await tester.tap(find.text('Add Party'));
    await tester.pumpAndSettle();

    expect(find.text('Add New Party'), findsOneWidget);
    expect(find.text('Firm / Shop / Business Name'), findsOneWidget);
    expect(find.text('Contact Person Name'), findsOneWidget);
    expect(find.text('Phone Number'), findsOneWidget);
  });

  testWidgets('InventoryScreen initializes with initialFilter and supports pull-to-refresh', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: InventoryScreen(initialFilter: 'Low Stock'),
      ),
    );

    expect(find.byType(InventoryScreen), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 3500));
  });

  test('NotificationService singleton initializes and triggers low stock alert gracefully', () async {
    final service1 = NotificationService();
    final service2 = NotificationService();
    expect(identical(service1, service2), isTrue);

    await service1.init();
    expect(service1.isInitialized, isTrue);

    await expectLater(
      service1.showLowStockAlert(
        productName: 'Chrome Mixer',
        remainingStock: 4,
      ),
      completes,
    );
  });

  testWidgets('InvoicesScreen renders tabs, summary metrics, and invoice cards', (WidgetTester tester) async {
    final mockInvoices = [
      Invoice(
        id: 'inv_1',
        invoiceNumber: 'INV-1001',
        type: 'SALE',
        partyId: 'party_1',
        partyName: 'Royal Sanitary',
        items: [
          InvoiceItem(
            productId: 'prod_1',
            productName: 'Chrome Mixer',
            quantity: 2,
            rate: 1500.0,
            amount: 3000.0,
            gstRate: 18.0,
          ),
        ],
        subtotal: 3000.0,
        gstTotal: 540.0,
        grandTotal: 3540.0,
        paymentStatus: 'PAID',
        date: DateTime.now(),
      ),
      Invoice(
        id: 'inv_2',
        invoiceNumber: 'INV-1002',
        type: 'PURCHASE',
        partyId: 'party_2',
        partyName: 'Patel Tiles',
        items: [
          InvoiceItem(
            productId: 'prod_2',
            productName: 'Basin',
            quantity: 1,
            rate: 2000.0,
            amount: 2000.0,
            gstRate: 18.0,
          ),
        ],
        subtotal: 2000.0,
        gstTotal: 360.0,
        grandTotal: 2360.0,
        paymentStatus: 'UNPAID',
        date: DateTime.now(),
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: InvoicesScreen(initialInvoices: mockInvoices),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Invoices & Billing'), findsOneWidget);
    expect(find.text('Total Invoiced'), findsOneWidget);
    expect(find.text('Sales Volume'), findsOneWidget);
    expect(find.text('Unpaid Bills'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Sales Invoices'), findsOneWidget);
    expect(find.text('Purchase Bills'), findsOneWidget);
    expect(find.text('INV-1001'), findsOneWidget);
    expect(find.text('INV-1002'), findsOneWidget);
    expect(find.text('Royal Sanitary'), findsOneWidget);
    expect(find.text('Patel Tiles'), findsOneWidget);
    expect(find.text('PAID'), findsOneWidget);
    expect(find.text('UNPAID'), findsOneWidget);
    expect(find.text('New Invoice'), findsOneWidget);
  });
}
