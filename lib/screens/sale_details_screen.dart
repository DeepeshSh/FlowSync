import 'package:flutter/material.dart';

import '../models/sale_model.dart';
import '../services/pdf_service.dart';
import '../utils/app_theme.dart';
import '../widgets/custom_app_bar.dart';

class SaleDetailsScreen extends StatelessWidget {
  final Sale sale;

  const SaleDetailsScreen({
    super.key,
    required this.sale,
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
    final String status = sale.paymentStatus.isNotEmpty ? sale.paymentStatus : "Pending";
    final statusStyle = _getStatusStyle(status);
    final dateStr =
        "${sale.saleDate.day.toString().padLeft(2, '0')}/${sale.saleDate.month.toString().padLeft(2, '0')}/${sale.saleDate.year}";

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: "Sale Details"),
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
                    "Invoice Number",
                    sale.saleNumber,
                    valueStyle: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: AppColors.textPrimary,
                      fontFamily: 'monospace',
                    ),
                  ),
                  const Divider(height: 20, color: AppColors.cardBorder),
                  _buildInfoRow(
                    "Customer",
                    sale.customerName,
                  ),
                  if (sale.phone.isNotEmpty) ...[
                    const Divider(height: 20, color: AppColors.cardBorder),
                    _buildInfoRow(
                      "Phone",
                      sale.phone,
                    ),
                  ],
                  if (sale.email.isNotEmpty) ...[
                    const Divider(height: 20, color: AppColors.cardBorder),
                    _buildInfoRow(
                      "Email",
                      sale.email,
                    ),
                  ],
                  const Divider(height: 20, color: AppColors.cardBorder),
                  _buildInfoRow(
                    "Total Products",
                    "${sale.items.length} Item(s)",
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
                  if (sale.balanceDue > 0) ...[
                    const Divider(height: 20, color: AppColors.cardBorder),
                    _buildInfoRow(
                      "Balance Due",
                      "₹${sale.balanceDue.toStringAsFixed(2)}",
                      valueStyle: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                        color: Color(0xFFD97706),
                      ),
                    ),
                  ],
                  const Divider(height: 20, color: AppColors.cardBorder),
                  _buildInfoRow(
                    "Date",
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
                    "Total Sale Value",
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "₹${sale.totalAmount.toStringAsFixed(2)}",
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
                        await PdfService.instance.previewSalesPdf(sale);
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
                      "View Invoice",
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
                        final file = await PdfService.instance.generateSalesPdf(sale);
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
                      "Share Invoice",
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