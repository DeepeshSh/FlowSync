import 'package:flutter/material.dart';
import '../models/product_model.dart';
import 'edit_product_screen.dart';
import '../services/product_service.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Product product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Product Details")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              product.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            _detailTile("SKU", product.sku),

            _detailTile("Category", product.categoryName),

            _detailTile("Stock", product.stock.toString()),

            _detailTile("Purchase Price", "₹${product.purchasePrice}"),

            _detailTile("Selling Price", "₹${product.sellingPrice}"),

            const SizedBox(height: 30),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditProductScreen(product: product),
                    ),
                  );

                  if (context.mounted && result == true) {
                    Navigator.pop(context, true);
                  }
                },
                child: const Text("Edit Product"),
              ),
            ),

            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () async {
                  final confirm = await showDialog<bool>(
                    context: context,

                    builder: (context) {
                      return AlertDialog(
                        title: const Text("Delete Product"),

                        content: Text("Delete ${product.name}?"),

                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context, false);
                            },

                            child: const Text("Cancel"),
                          ),

                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),

                            onPressed: () {
                              Navigator.pop(context, true);
                            },

                            child: const Text("Delete"),
                          ),
                        ],
                      );
                    },
                  );

                  if (confirm != true) {
                    return;
                  }

                  await ProductService().deleteProduct(product.id);

                  if (context.mounted) {
                    Navigator.pop(context, true);
                  }
                },
                child: const Text("Delete Product"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailTile(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          Text(value),
        ],
      ),
    );
  }
}
