import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../models/variant_model.dart';

class AddEditVariantScreen extends StatefulWidget {
  final Product product;
  final Variant? variant;

  const AddEditVariantScreen({
    super.key,
    required this.product,
    this.variant,
  });

  @override
  State<AddEditVariantScreen> createState() =>
      _AddEditVariantScreenState();
}

class _AddEditVariantScreenState
    extends State<AddEditVariantScreen> {

  final _formKey = GlobalKey<FormState>();

  final variantNameController =
      TextEditingController();

  final skuController =
      TextEditingController();

  final barcodeController =
      TextEditingController();

  final storageController =
      TextEditingController();

  final stockController =
      TextEditingController();

  final purchaseController =
      TextEditingController();

  final sellingController =
      TextEditingController();

  final mrpController =
      TextEditingController();

  final gstController =
      TextEditingController();

  final lowStockController =
      TextEditingController();

  bool isActive = true;

  @override
  void initState() {
    super.initState();

    if (widget.variant != null) {

      final v = widget.variant!;

      variantNameController.text =
          v.variantName;

      skuController.text =
          v.sku;

      barcodeController.text =
          v.barcode;

      storageController.text =
          v.storageLocation;

      stockController.text =
          v.stock.toString();

      purchaseController.text =
          v.purchasePrice.toString();

      sellingController.text =
          v.sellingPrice.toString();

      mrpController.text =
          v.mrp.toString();

      gstController.text =
          v.gstPercentage.toString();

      lowStockController.text =
          v.lowStockThreshold.toString();

      isActive = v.isActive;
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text(
          widget.variant == null
              ? "Add Variant"
              : "Edit Variant",
        ),
      ),

      body: Form(

        key: _formKey,

        child: ListView(

          padding:
              const EdgeInsets.all(20),

          children: [

            TextFormField(
              controller:
                  variantNameController,
              decoration:
                  const InputDecoration(
                labelText:
                    "Variant Name",
              ),
            ),

            const SizedBox(height: 15),

            TextFormField(
              controller: skuController,
              decoration:
                  const InputDecoration(
                labelText: "SKU",
              ),
            ),

            const SizedBox(height: 15),

            TextFormField(
              controller:
                  barcodeController,
              decoration:
                  const InputDecoration(
                labelText: "Barcode",
              ),
            ),

            const SizedBox(height: 15),

            TextFormField(
              controller:
                  storageController,
              decoration:
                  const InputDecoration(
                labelText:
                    "Storage Location",
              ),
            ),

            const SizedBox(height: 15),

            TextFormField(
              controller:
                  stockController,
              keyboardType:
                  TextInputType.number,
              decoration:
                  const InputDecoration(
                labelText: "Stock",
              ),
            ),

            const SizedBox(height: 15),

            TextFormField(
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

            const SizedBox(height: 15),

            TextFormField(
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

            const SizedBox(height: 15),

            TextFormField(
              controller:
                  mrpController,
              keyboardType:
                  TextInputType.number,
              decoration:
                  const InputDecoration(
                labelText: "MRP",
              ),
            ),

            const SizedBox(height: 15),

            TextFormField(
              controller:
                  gstController,
              keyboardType:
                  TextInputType.number,
              decoration:
                  const InputDecoration(
                labelText:
                    "GST %",
              ),
            ),

            const SizedBox(height: 15),

            TextFormField(
              controller:
                  lowStockController,
              keyboardType:
                  TextInputType.number,
              decoration:
                  const InputDecoration(
                labelText:
                    "Low Stock Alert",
              ),
            ),

            const SizedBox(height: 20),

            SwitchListTile(
              value: isActive,
              title:
                  const Text("Active"),
              onChanged: (value) {
                setState(() {
                  isActive = value;
                });
              },
            ),

            const SizedBox(height: 30),

            ElevatedButton(
              onPressed: () {

                // TODO
                // Call createVariant()
                // or updateVariant()

              },
              child: Text(
                widget.variant == null
                    ? "Create Variant"
                    : "Update Variant",
              ),
            ),

          ],
        ),
      ),
    );
  }
}