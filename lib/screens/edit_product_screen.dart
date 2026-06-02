import 'package:flutter/material.dart';
import '../services/product_service.dart';
import '../models/product_model.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;

  const EditProductScreen({
    super.key,
    required this.product,
  });

  @override
  State<EditProductScreen> createState() =>
      _EditProductScreenState();
}

class _EditProductScreenState
    extends State<EditProductScreen> {

  final nameController =
      TextEditingController();

  final skuController =
      TextEditingController();

  final purchaseController =
      TextEditingController();

  final sellingController =
      TextEditingController();

  final stockController =
      TextEditingController();

  @override
  void initState() {
    super.initState();

    nameController.text =
        widget.product.name;

    skuController.text =
        widget.product.sku;

    stockController.text =
        widget.product.stock.toString();

    purchaseController.text =
        widget.product.purchasePrice.toString();

    sellingController.text =
        widget.product.sellingPrice.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Edit Product",
        ),
      ),

      body: Padding(
        padding:
            const EdgeInsets.all(16),

        child: SingleChildScrollView(
          child: Column(
            children: [

              TextField(
                controller:
                    nameController,
                decoration:
                    const InputDecoration(
                  labelText:
                      "Product Name",
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller:
                    skuController,
                decoration:
                    const InputDecoration(
                  labelText: "SKU",
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller:
                    purchaseController,
                keyboardType:
                    TextInputType.number,
                decoration:
                    const InputDecoration(
                  labelText:
                      "Purchase Price",
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller:
                    sellingController,
                keyboardType:
                    TextInputType.number,
                decoration:
                    const InputDecoration(
                  labelText:
                      "Selling Price",
                ),
              ),

              const SizedBox(height: 10),

              TextField(
                controller:
                    stockController,
                keyboardType:
                    TextInputType.number,
                decoration:
                    const InputDecoration(
                  labelText: "Stock",
                ),
              ),

              const SizedBox(height: 20),

              SizedBox(
  width: double.infinity,
  child: ElevatedButton(
    onPressed: () async {

      print("ID = ${widget.product.id}");
      print("NAME = ${nameController.text}");
      print("SKU = ${skuController.text}");

      await ProductService().updateProduct(
        id: widget.product.id,
        name: nameController.text,
        sku: skuController.text,
        stock: int.parse(stockController.text),
        purchasePrice:
            double.parse(purchaseController.text),
        sellingPrice:
            double.parse(sellingController.text),
      );

      if (context.mounted) {
      Navigator.pop(
  context,
  true,
);
      }
    },
    child: const Text(
      "UPDATE PRODUCT",
    ),
  ),
),
            ],
          ),
        ),
      ),
    );
  }
}