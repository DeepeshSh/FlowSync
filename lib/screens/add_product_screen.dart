import 'package:flutter/material.dart';
import '../services/product_service.dart';
import '../models/category_model.dart';
import '../services/category_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() =>
      _AddProductScreenState();
}

class _AddProductScreenState
    extends State<AddProductScreen> {

Future<void> showAddCategoryDialog() async {

  final nameController =
      TextEditingController();

  final descriptionController =
      TextEditingController();

  await showDialog(

    context: context,

    builder: (context) {

      return AlertDialog(

        title: const Text(
          "Create Category",
        ),

        content: Column(
          mainAxisSize:
              MainAxisSize.min,

          children: [

            TextField(
              controller:
                  nameController,

              decoration:
                  const InputDecoration(
                labelText:
                    "Category Name",
              ),
            ),

            TextField(
              controller:
                  descriptionController,

              decoration:
                  const InputDecoration(
                labelText:
                    "Description",
              ),
            ),
          ],
        ),

        actions: [

          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },

            child:
                const Text("Cancel"),
          ),

          ElevatedButton(
            onPressed: () async {

              await CategoryService()
                  .createCategory(

                name:
                    nameController.text,

                description:
                    descriptionController.text,
              );

              await loadCategories();

              Navigator.pop(context);
            },

            child:
                const Text("Save"),
          ),
        ],
      );
    },
  );
}
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

  List<Category> categories = [];

  String? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future<void> loadCategories() async {

    categories =
        await CategoryService()
            .getCategories();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text(
          "Add Product",
        ),
      ),

      body: SingleChildScrollView(

        padding:
            const EdgeInsets.all(16),

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

            DropdownButtonFormField<String>(

              value:
                  selectedCategoryId,

              decoration:
                  const InputDecoration(
                labelText:
                    "Category",
              ),

              items:
                  categories.map(
                (category) {

                  return DropdownMenuItem(
                    value:
                        category.id,

                    child: Text(
                      category.name,
                    ),
                  );
                },
              ).toList(),

              onChanged: (value) {

                setState(() {

                  selectedCategoryId =
                      value;
                });
              },
            ),
        
TextButton.icon(
  onPressed: () {
    showAddCategoryDialog();
  },

  icon: const Icon(Icons.add),

  label: const Text(
    "Create New Category",
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

                  if (selectedCategoryId ==
                      null) {

                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(

                      const SnackBar(
                        content: Text(
                          "Select Category",
                        ),
                      ),
                    );

                    return;
                  }

                  await ProductService()
                      .addProduct(

                    name:
                        nameController.text,

                    sku:
                        skuController.text,

                    stock:
                        int.parse(
                      stockController.text,
                    ),

                    purchasePrice:
                        double.parse(
                      purchaseController.text,
                    ),

                    sellingPrice:
                        double.parse(
                      sellingController.text,
                    ),

                    category:
                        selectedCategoryId!,
                  );

                  if (context.mounted) {
                    Navigator.pop(
                      context,
                    );
                  }
                },

                child: const Text(
                  "SAVE PRODUCT",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}