import 'package:flutter/material.dart';
import '../models/purchase_model.dart';
import '../services/pdf_service.dart';

class PurchaseDetailsScreen extends StatelessWidget {
  final Purchase purchase;

  const PurchaseDetailsScreen({
    super.key,
    required this.purchase,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return const Color(0xFF10B981);
      case 'partially paid':
        return const Color(0xFF3B82F6);
      case 'pending':
        return const Color(0xFFF59E0B);
      case 'draft':
        return const Color(0xFF64748B);
      default:
        return const Color(0xFF64748B);
    }
  }

  Color _getStatusBgColor(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return const Color(0xFFECFDF5);
      case 'partially paid':
        return const Color(0xFFEFF6FF);
      case 'pending':
        return const Color(0xFFFFF7ED);
      case 'draft':
        return const Color(0xFFF1F5F9);
      default:
        return const Color(0xFFF1F5F9);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryDark = Color(0xFF1B2559);
    final String status = purchase.paymentStatus ?? "Pending";
    final Color statusColor = _getStatusColor(status);
    final Color statusBgColor = _getStatusBgColor(status);

    int productCount = 1;
    try {
      productCount = (purchase as dynamic).items.length;
    } catch (_) {}

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: primaryDark,
            size: 18,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Purchase Details",
          style: TextStyle(
            color: primaryDark,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- MAIN DETAILS CARD ---
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildInfoRow(
                    "PO Number",
                    purchase.purchaseNumber,
                    valueStyle: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF2563EB),
                      fontFamily: 'monospace',
                    ),
                  ),
                  const Divider(height: 24, color: Color(0xFFF1F5F9)),
                  _buildInfoRow(
                    "Supplier",
                    purchase.supplierName,
                  ),
                  const Divider(height: 24, color: Color(0xFFF1F5F9)),
                  _buildInfoRow(
                    "Total Items",
                    "$productCount Product(s)",
                  ),
                  const Divider(height: 24, color: Color(0xFFF1F5F9)),
                  // Payment Status Badge
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Payment Status",
                          style: TextStyle(
                            color: Color(0xFF64748B),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusBgColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: statusColor.withOpacity(0.2),
                            ),
                          ),
                          child: Text(
                            status,
                            style: TextStyle(
                              color: statusColor,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 24, color: Color(0xFFF1F5F9)),
                  _buildInfoRow(
                    "Purchase Date",
                    "${purchase.purchaseDate.day}/${purchase.purchaseDate.month}/${purchase.purchaseDate.year}",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // --- TOTAL AMOUNT DISPLAY CARD ---
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    "Total Purchase Outflow",
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "₹${purchase.totalAmount.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F9D94),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- ACTION BUTTONS ---
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        await PdfService.instance.previewPurchasePdf(purchase);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString()),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(
                      Icons.picture_as_pdf_outlined,
                      size: 20,
                    ),
                    label: const Text(
                      "View Purchase Order",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF143D7A),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      try {
                        final file = await PdfService.instance.generatePurchasePdf(purchase);
                        await PdfService.instance.sharePdf(file);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString()),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(
                      Icons.share_outlined,
                      size: 20,
                    ),
                    label: const Text(
                      "Share Purchase Order",
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF143D7A),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String title,
    String value, {
    TextStyle? valueStyle,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: valueStyle ??
              const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: Color(0xFF1B2559),
              ),
        ),
      ],
    );
  }
}