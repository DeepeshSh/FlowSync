import 'package:flutter/material.dart';

import '../models/purchase_model.dart';
import '../services/pdf_service.dart';
import '../utils/app_theme.dart';
import '../widgets/custom_app_bar.dart';

class PurchaseDetailsScreen extends StatelessWidget {
  final Purchase purchase;

  const PurchaseDetailsScreen({
    super.key,
    required this.purchase,
  });

  Map<String, dynamic> _getStatusStyle(String status) {
    switch (status.toLowerCase()) {
      case 'paid':
        return {
          'textColor': const Color(0xFF10B981),
          'bgColor': const Color(0xFFECFDF5),
          'borderColor': const Color(0xFFA7F3D0),
        };
      case 'partially paid':
      case 'partial':
        return {
          'textColor': const Color(0xFFD97706),
          'bgColor': const Color(0xFFFFFBEB),
          'borderColor': const Color(0xFFFDE68A),
        };
      case 'pending':
        return {
          'textColor': const Color(0xFFD97706),
          'bgColor': const Color(0xFFFFFBEB),
          'borderColor': const Color(0xFFFDE68A),
        };
      case 'draft':
      default:
        return {
          'textColor': AppColors.textSecondary,
          'bgColor': AppColors.background,
          'borderColor': AppColors.cardBorder,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final String status = purchase.paymentStatus.isNotEmpty ? purchase.paymentStatus : "Pending";
    final statusStyle = _getStatusStyle(status);

    int productCount = 1;
    try {
      productCount = (purchase as dynamic).items.length;
    } catch (_) {}

    final dateStr = "${purchase.purchaseDate.day.toString().padLeft(2, '0')}/${purchase.purchaseDate.month.toString().padLeft(2, '0')}/${purchase.purchaseDate.year}";

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: "Purchase Details"),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  _buildInfoRow(
                    "PO Number",
                    purchase.purchaseNumber,
                    valueStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppColors.textPrimary,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const Divider(height: 20, color: AppColors.cardBorder),
                  _buildInfoRow(
                    "Supplier",
                    purchase.supplierName,
                  ),
                  const Divider(height: 20, color: AppColors.cardBorder),
                  _buildInfoRow(
                    "Total Items",
                    "$productCount Product(s)",
                  ),
                  const Divider(height: 20, color: AppColors.cardBorder),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Payment Status",
                        style: TextStyle(
                          color: AppColors.textMuted,
                          fontSize: 12.5,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: statusStyle['bgColor'] as Color,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: statusStyle['borderColor'] as Color,
                          ),
                        ),
                        child: Text(
                          status,
                          style: TextStyle(
                            color: statusStyle['textColor'] as Color,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20, color: AppColors.cardBorder),
                  _buildInfoRow(
                    "Purchase Date",
                    dateStr,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.cardBorder),
              ),
              child: Column(
                children: [
                  const Text(
                    "Total Purchase Outflow",
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "₹${purchase.totalAmount.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 46,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        await PdfService.instance.previewPurchasePdf(purchase);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString()),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(
                      Icons.picture_as_pdf_outlined,
                      size: 18,
                    ),
                    label: const Text(
                      "View Purchase Order",
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 46,
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
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(
                      Icons.share_outlined,
                      size: 18,
                    ),
                    label: const Text(
                      "Share Purchase Order",
                      style: TextStyle(
                        fontSize: 13.5,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.cardBorder),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
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
            color: AppColors.textMuted,
            fontSize: 12.5,
          ),
        ),
        Text(
          value,
          style: valueStyle ??
              const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13.5,
                color: AppColors.textPrimary,
              ),
        ),
      ],
    );
  }
}