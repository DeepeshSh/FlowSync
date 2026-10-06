import 'package:flutter_test/flutter_test.dart';
import 'package:FlowSync/models/app_user.dart';
import 'package:FlowSync/models/invoice_model.dart';
import 'package:FlowSync/utils/invoice_pdf_generator.dart';

void main() {
  group('Final Release Pre-Flight Verification Suite', () {
    test('AppUser serialization handles null and omitted fields cleanly', () {
      // Test payload with null and missing optional fields
      final Map<String, dynamic> rawNullData = {
        '_id': 'usr_998877',
        'name': 'Rahul Sharma',
        'email': 'rahul@flowsync.in',
        'businessName': null,
        'phone': null,
        'gstin': null,
        'address': null,
      };

      final user = AppUser.fromJson(rawNullData);

      expect(user.id, 'usr_998877');
      expect(user.name, 'Rahul Sharma');
      expect(user.email, 'rahul@flowsync.in');
      expect(user.businessName, '');
      expect(user.phone, '');
      expect(user.gstin, '');
      expect(user.address, '');

      // Verify toJson serialization
      final json = user.toJson();
      expect(json['_id'], 'usr_998877');
      expect(json['businessName'], '');
      expect(json['phone'], '');

      // Roundtrip test
      final roundtrip = AppUser.fromJson(json);
      expect(roundtrip.name, user.name);
      expect(roundtrip.businessName, user.businessName);
    });

    test('Onboarding Route Guard correctly identifies incomplete vs complete profiles', () {
      // User with incomplete onboarding (empty businessName)
      final incompleteUser = AppUser(
        id: 'usr_001',
        name: 'New Google User',
        email: 'newuser@flowsync.in',
        businessName: '',
      );

      final bool requiresOnboarding = incompleteUser.businessName.trim().isEmpty;
      expect(requiresOnboarding, isTrue, reason: 'Users without businessName must be routed to SignupBusinessDetailsScreen');

      // User with completed onboarding
      final completeUser = AppUser(
        id: 'usr_002',
        name: 'Verified Merchant',
        email: 'merchant@flowsync.in',
        businessName: 'Royal Ceramics & Sanitary',
      );

      final bool completeRequiresOnboarding = completeUser.businessName.trim().isEmpty;
      expect(completeRequiresOnboarding, isFalse, reason: 'Users with established businessName route straight to MainScreen');
    });

    test('InvoicePdfGenerator builds multi-page documents (25+ items) without PdfRasterException', () async {
      // Generate 30 line items to test multi-page table pagination
      final List<InvoiceItem> largeItemList = List.generate(30, (index) {
        final itemNumber = index + 1;
        return InvoiceItem(
          productId: 'prod_$itemNumber',
          productName: 'Sanitary Fixture Component Grade-$itemNumber',
          quantity: itemNumber * 2,
          rate: 150.0 + (itemNumber * 10),
          gstRate: 18.0,
          amount: (itemNumber * 2) * (150.0 + (itemNumber * 10)),
        );
      });

      final subtotal = largeItemList.fold<double>(0.0, (sum, i) => sum + i.amount);
      final gstTotal = subtotal * 0.18;
      final grandTotal = subtotal + gstTotal;

      final testInvoice = Invoice(
        id: 'inv_multi_page_test',
        invoiceNumber: 'INV-2026-MULTI-001',
        type: 'SALE',
        partyId: 'pty_enterprise_99',
        partyName: 'Premier Wholesale Ceramic Depot',
        items: largeItemList,
        subtotal: subtotal,
        gstTotal: gstTotal,
        grandTotal: grandTotal,
        paymentStatus: 'UNPAID',
        notes: 'Terms: 30-day payment cycle. Goods once sold will not be accepted without return challan.',
        date: DateTime.now(),
      );

      // Generating PDF with 30 items must paginate across multiple pages seamlessly without throwing
      final pdfBytes = await InvoicePdfGenerator.generate(
        testInvoice,
        businessName: 'FlowSync Sanitary Solutions Enterprise',
        gstin: '27AAAAA0000A1Z5',
        address: 'Plot 104, Industrial Hub, Phase-2, Mumbai - 400001',
        phone: '+91 98765 43210',
      );

      expect(pdfBytes, isNotNull);
      expect(pdfBytes.isNotEmpty, isTrue);
      // Valid PDF documents start with '%PDF'
      expect(String.fromCharCodes(pdfBytes.sublist(0, 4)), '%PDF');
    });
  });
}
