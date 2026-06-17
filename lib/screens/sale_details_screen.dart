import 'package:flutter/material.dart';

import '../models/sale_model.dart';

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
                    "Items",
                    sale.itemCount
                        .toString(),
                  ),

                  const Divider(),

                  _buildInfoRow(
                    "Payment Status",
                    sale.paymentStatus,
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

            SizedBox(
              width:
                  double.infinity,

              height: 55,

              child: ElevatedButton.icon(
                onPressed: () {

                  // Future:
                  // Edit Sale
                },

                icon: const Icon(
                  Icons.edit,
                ),

                label: const Text(
                  "Edit Sale",
                ),

                style:
                    ElevatedButton
                        .styleFrom(
                  backgroundColor:
                      const Color(
                    0xFF2F80FF,
                  ),

                  foregroundColor:
                      Colors.white,
                ),
              ),
            ),
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