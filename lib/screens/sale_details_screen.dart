import 'package:flutter/material.dart';

import '../models/sale_model.dart';
import '../services/pdf_service.dart';
class SaleDetailsScreen extends StatelessWidget {
  final Sale sale;

  const SaleDetailsScreen({
    super.key,
    required this.sale,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F7FC),

      appBar: AppBar(
        title: const Text(
          "Sale Details",
        ),

        centerTitle: true,

        backgroundColor:
            Colors.white,

        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            Container(
              padding:
                  const EdgeInsets.all(
                20,
              ),

              decoration:
                  BoxDecoration(
                color: Colors.white,

                borderRadius:
                    BorderRadius.circular(
                  20,
                ),

                boxShadow: const [
                  BoxShadow(
                    color:
                        Colors.black12,
                    blurRadius: 8,
                  ),
                ],
              ),

              child: Column(
                children: [

                  _buildInfoRow(
                    "Invoice Number",
                    sale.saleNumber,
                  ),

                  const Divider(),

                  _buildInfoRow(
                    "Customer",
                    sale.customerName,
                  ),

                  const Divider(),

_buildInfoRow(
  "Phone",
  sale.phone,
),

const Divider(),

_buildInfoRow(
  "Email",
  sale.email,
),

                  const Divider(),

                  _buildInfoRow(
  "Total Products",
  "${sale.items.length} Item(s)",
),

                  const Divider(),

                  _buildInfoRow(
                    "Payment Status",
                    sale.paymentStatus,
                  ),

const Divider(),

_buildInfoRow(
  "Balance Due",
  "₹${sale.balanceDue.toStringAsFixed(2)}",
),
                  const Divider(),

                  _buildInfoRow(
                    "Date",
                    "${sale.saleDate.day}/${sale.saleDate.month}/${sale.saleDate.year}",
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            Container(
              width:
                  double.infinity,

              padding:
                  const EdgeInsets.all(
                20,
              ),

              decoration:
                  BoxDecoration(
                color: Colors.white,

                borderRadius:
                    BorderRadius.circular(
                  20,
                ),

                boxShadow: const [
                  BoxShadow(
                    color:
                        Colors.black12,
                    blurRadius: 8,
                  ),
                ],
              ),

              child: Column(
                children: [

                  const Text(
                    "Total Amount",
                    style: TextStyle(
                      color:
                          Colors.grey,
                      fontSize: 16,
                    ),
                  ),

                  const SizedBox(
                    height: 10,
                  ),

                  Text(
                    "₹${sale.totalAmount.toStringAsFixed(2)}",

                    style:
                        const TextStyle(
                      fontSize: 32,

                      fontWeight:
                          FontWeight.bold,

                      color:
                          Colors.green,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            Column(
  children: [

    SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton.icon(
        onPressed: () async {
          try {
            await PdfService.instance
                .previewSalesPdf(sale);
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(
                SnackBar(
                  content: Text(
                    e.toString(),
                  ),
                ),
              );
            }
          }
        },

        icon: const Icon(
          Icons.picture_as_pdf,
        ),

        label: const Text(
          "View Invoice",
        ),

        style: ElevatedButton.styleFrom(
          backgroundColor:
              const Color(0xFF2F80FF),

          foregroundColor:
              Colors.white,
        ),
      ),
    ),

    const SizedBox(height: 12),

    SizedBox(
      width: double.infinity,
      height: 55,
      child: OutlinedButton.icon(
        onPressed: () async {
          try {
            final file =
                await PdfService.instance
                    .generateSalesPdf(
              sale,
            );

            await PdfService.instance
                .sharePdf(file);
          } catch (e) {
            if (context.mounted) {
              ScaffoldMessenger.of(context)
                  .showSnackBar(
                SnackBar(
                  content: Text(
                    e.toString(),
                  ),
                ),
              );
            }
          }
        },

        icon: const Icon(
          Icons.share,
        ),

        label: const Text(
          "Share Invoice",
        ),
      ),
    ),

    const SizedBox(height: 12),

    SizedBox(
      width: double.infinity,
      height: 55,
      child: TextButton.icon(
        onPressed: () {

          // Future edit screen
        },

        icon: const Icon(
          Icons.edit,
        ),

        label: const Text(
          "Edit Sale",
        ),
      ),
    ),
  ],
)
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    String title,
    String value,
  ) {
    return Padding(
      padding:
          const EdgeInsets.symmetric(
        vertical: 10,
      ),

      child: Row(
        mainAxisAlignment:
            MainAxisAlignment
                .spaceBetween,

        children: [

          Text(
            title,

            style:
                const TextStyle(
              color:
                  Colors.grey,

              fontSize: 15,
            ),
          ),

          Text(
            value,

            style:
                const TextStyle(
              fontWeight:
                  FontWeight.bold,

              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}