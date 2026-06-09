import 'package:flutter/material.dart';
import '../services/product_service.dart';
import '../models/category_model.dart';
import '../services/category_service.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final nameController = TextEditingController();

  final skuController = TextEditingController();

  final brandController = TextEditingController();

  final purchaseController = TextEditingController();

  final sellingController = TextEditingController();

  final stockController = TextEditingController();

  final storageController = TextEditingController();

  final unitController = TextEditingController();

  final thresholdController = TextEditingController(text: "10");

  final supplierNameController = TextEditingController();

  final amountPaidController = TextEditingController();

  File? selectedImage;

  final ImagePicker picker = ImagePicker();

  List<Category> categories = [];

  String? selectedCategoryId;

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future<void> pickImage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        selectedImage = File(image.path);
      });
    }
  }

  Future<void> loadCategories() async {
    categories = await CategoryService().getCategories();

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> showAddCategoryDialog() async {
    final nameController = TextEditingController();

    final descriptionController = TextEditingController();
  }

  Future<void> saveProduct() async {
    if (selectedCategoryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Please select category")));

      return;
    }

    await ProductService().addProduct(
      name: nameController.text,

      sku: skuController.text,

      stock: int.parse(stockController.text),

      purchasePrice: double.parse(purchaseController.text),

      sellingPrice: double.parse(sellingController.text),

      category: selectedCategoryId!,

      brandName: brandController.text,

      storageLocation: storageController.text,

      unit: unitController.text,

      lowStockThreshold: int.parse(thresholdController.text),

      imageUrl: "",
    );

    if (mounted) {
      Navigator.pop(context);
    }
  }

  Widget sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(24),

        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2F80FF),
            ),
          ),

          const SizedBox(height: 20),

          child,
        ],
      ),
    );
  }

  Widget buildBasicInfoCard() {
    return sectionCard(
      title: "Basic Information",

      child: Column(
        children: [
          TextField(
            controller: nameController,

            decoration: InputDecoration(
              labelText: "Product Name",

              hintText: "Enter product name",

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),

          const SizedBox(height: 16),

          DropdownButtonFormField<String>(
            value: selectedCategoryId,

            decoration: InputDecoration(
              labelText: "Category",

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),

            items: categories.map((category) {
              return DropdownMenuItem(
                value: category.id,

                child: Text(category.name),
              );
            }).toList(),

            onChanged: (value) {
              setState(() {
                selectedCategoryId = value;
              });
            },
          ),

          const SizedBox(height: 8),

          TextField(
            controller: brandController,

            decoration: InputDecoration(
              labelText: "Brand",

              hintText: "Enter brand name",

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),

          const SizedBox(height: 16),

          TextField(
            controller: skuController,

            decoration: InputDecoration(
              labelText: "Product Code / SKU",

              hintText: "Enter SKU",

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),

          const SizedBox(height: 16),

          TextField(
            controller: skuController,

            decoration: InputDecoration(
              labelText: "HSN / SAC code",

              hintText: "HSN / SAC code",

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildStockInfoCard() {
    return sectionCard(
      title: "Stock Information",

      child: Column(
        children: [
          TextField(
            controller: stockController,

            keyboardType: TextInputType.number,

            decoration: InputDecoration(
              labelText: "Quantity",

              hintText: "Enter quantity",

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),

          const SizedBox(height: 16),

          TextField(
            controller: unitController,

            decoration: InputDecoration(
              labelText: "Unit",

              hintText: "pcs",

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),

          const SizedBox(height: 16),

          TextField(
            controller: unitController,

            decoration: InputDecoration(
              labelText: "Dimensions",

              hintText: "Length Bredth Height",

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),

          const SizedBox(height: 16),

          TextField(
            controller: unitController,

            decoration: InputDecoration(
              labelText: "Fragility",

              hintText: "Sensitivity of the product",

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 16),

          TextField(
            controller: thresholdController,

            keyboardType: TextInputType.number,

            decoration: InputDecoration(
              labelText: "Minimum Stock Level",

              hintText: "Low stock alert",

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),

          const SizedBox(height: 16),

          TextField(
            controller: storageController,

            decoration: InputDecoration(
              labelText: "Rack / Shelf Location",

              hintText: "Rack A-1",

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildPricingCard() {
    return sectionCard(
      title: "Pricing Information",

      child: Column(
        children: [
          TextField(
            controller: purchaseController,

            keyboardType: TextInputType.number,

            decoration: InputDecoration(
              labelText: "Purchase Price",

              hintText: "Enter purchase price",

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),

          const SizedBox(height: 16),

          TextField(
            controller: sellingController,

            keyboardType: TextInputType.number,

            decoration: InputDecoration(
              labelText: "Selling Price",

              hintText: "Enter selling price",

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildSupllierCard() {
    return sectionCard(
      title: "Supllier Information",

      child: Column(
        children: [
          TextField(
            controller: purchaseController,

            keyboardType: TextInputType.number,

            decoration: InputDecoration(
              labelText: "Supplier Name",

              hintText: "Enter purchase price",

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),

          const SizedBox(height: 16),

          TextField(
            controller: sellingController,

            keyboardType: TextInputType.number,

            decoration: InputDecoration(
              labelText: "Amount Paid",

              hintText: "Amount",

              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildImageCard() {
    return sectionCard(
      title: "Product Image",

      child: GestureDetector(
        onTap: pickImage,

        child: Container(
          height: 140,

          width: double.infinity,

          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFF2F80FF)),

            borderRadius: BorderRadius.circular(16),
          ),

          child: selectedImage == null
              ? const Column(
                  mainAxisAlignment: MainAxisAlignment.center,

                  children: [
                    Icon(
                      Icons.cloud_upload_outlined,
                      size: 42,
                      color: Color(0xFF2F80FF),
                    ),

                    SizedBox(height: 12),

                    Text(
                      "Upload Product Image",
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),

                    SizedBox(height: 4),

                    Text(
                      "JPG, PNG up to 5 MB",
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(16),

                  child: Image.file(
                    selectedImage!,
                    width: double.infinity,
                    height: 140,
                    fit: BoxFit.cover,
                  ),
                ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FC),

      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F7FC),

        surfaceTintColor: Colors.transparent,

        elevation: 0,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),

          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              "Add Product",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),

            SizedBox(height: 2),

            Text(
              "Fill the details to add a new product",
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [
            buildBasicInfoCard(),

            const SizedBox(height: 16),

            buildStockInfoCard(),

            const SizedBox(height: 16),

            buildPricingCard(),

            const SizedBox(height: 16),

            buildSupllierCard(),

            const SizedBox(height: 16),

            buildImageCard(),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },

                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 55),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),

                    child: const Text("Cancel"),
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: ElevatedButton(
                    onPressed: saveProduct,

                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F80FF),

                      minimumSize: const Size(double.infinity, 55),

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),

                    child: const Text(
                      "Save Product",

                      style: TextStyle(
                        color: Colors.white,

                        fontWeight: FontWeight.bold,

                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
