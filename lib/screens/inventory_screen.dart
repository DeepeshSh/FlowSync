import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';
import 'add_product_screen.dart';
import 'product_details_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  late Future<List<Product>> productsFuture;

  @override
  void initState() {
    super.initState();

    productsFuture = ProductService().getProducts();
  }

  void refreshProducts() {
    setState(() {
      productsFuture = ProductService().getProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inventory")),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,

            MaterialPageRoute(builder: (_) => const AddProductScreen()),
          );

          refreshProducts();
        },

        child: const Icon(Icons.add),
      ),

      body: FutureBuilder<List<Product>>(
        future: productsFuture,

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          }

          final products = snapshot.data ?? [];

          if (products.isEmpty) {
            return const Center(child: Text("No Products Found"));
          }

          return ListView.builder(
            itemCount: products.length,

            itemBuilder: (context, index) {
              final product = products[index];

              return Card(
                margin: const EdgeInsets.all(10),

                child: ListTile(
                  onTap: () async {
                    final result = await Navigator.push(
                      context,

                      MaterialPageRoute(
                        builder: (_) => ProductDetailsScreen(product: product),
                      ),
                    );

                    if (result == true) {
                      refreshProducts();
                    }
                  },

                  title: Text(product.name),

                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text("SKU: ${product.sku}"),

                      Text(
                        product.categoryName,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),

                  trailing: Text(product.stock.toString()),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
