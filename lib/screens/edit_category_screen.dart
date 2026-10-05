import 'package:flutter/material.dart';

import '../models/category_model.dart';
import '../services/category_service.dart';
import '../utils/app_theme.dart';
import '../widgets/custom_app_bar.dart';

class EditCategoryScreen extends StatefulWidget {
  final Category category;

  const EditCategoryScreen({
    super.key,
    required this.category,
  });

  @override
  State<EditCategoryScreen> createState() => _EditCategoryScreenState();
}

class _EditCategoryScreenState extends State<EditCategoryScreen> {
  final CategoryService categoryService = CategoryService();

  late TextEditingController categoryNameController;
  late TextEditingController notesController;

  List<Category> categories = [];

  String? selectedParentCategory;
  String? selectedUnit;

  bool isFragile = false;
  bool isReturnable = false;
  bool isLoading = false;

  final List<String> availableUnits = [
    "Piece (pcs)",
    "Box",
    "Packet",
    "Meter",
    "Feet",
    "Kg",
    "Liter",
    "Set",
  ];

  @override
  void initState() {
    super.initState();

    categoryNameController = TextEditingController(text: widget.category.name);
    notesController = TextEditingController(text: widget.category.notes);

    selectedParentCategory = widget.category.parentCategoryId;

    if (availableUnits.contains(widget.category.unit)) {
      selectedUnit = widget.category.unit;
    } else {
      selectedUnit = null;
    }

    isFragile = widget.category.isFragile;
    isReturnable = widget.category.isReturnable;

    loadCategories();
  }

  Future<void> loadCategories() async {
    try {
      final data = await categoryService.getCategories();
      if (mounted) {
        setState(() {
          categories = data;
        });
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  InputDecoration fieldDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
      prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 18),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.cardBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
      ),
    );
  }

  Future<void> handleUpdateCategory() async {
    if (categoryNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Category name cannot be left empty.")),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      Category updatedCategory = Category(
        id: widget.category.id,
        name: categoryNameController.text.trim(),
        notes: notesController.text.trim(),
        parentCategoryId: selectedParentCategory,
        unit: selectedUnit ?? '',
        isFragile: isFragile,
        isReturnable: isReturnable,
      );

      await categoryService.updateCategory(updatedCategory);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Category updated successfully!")),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to update category: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  void dispose() {
    categoryNameController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: "Edit Category",
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Category Details",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: categoryNameController,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: fieldDecoration("Category Name *", Icons.folder_outlined),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: categories.any((c) => c.id == selectedParentCategory) ? selectedParentCategory : null,
                    dropdownColor: Colors.white,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: fieldDecoration("Parent Category", Icons.account_tree_outlined),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text("None (Primary)", style: TextStyle(color: AppColors.textMuted)),
                      ),
                      ...categories
                          .where((c) => c.id != widget.category.id)
                          .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
                    ],
                    onChanged: (val) => setState(() => selectedParentCategory = val),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: selectedUnit,
                    dropdownColor: Colors.white,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: fieldDecoration("Unit of Measurement", Icons.square_foot_rounded),
                    items: [
                      const DropdownMenuItem(
                        value: null,
                        child: Text("Select Unit", style: TextStyle(color: AppColors.textMuted)),
                      ),
                      ...availableUnits.map((u) => DropdownMenuItem(value: u, child: Text(u))),
                    ],
                    onChanged: (val) => setState(() => selectedUnit = val),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Compliance Settings",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Column(
                      children: [
                        SwitchListTile(
                          value: isFragile,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                          title: const Text(
                            "Fragile Cargo",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13.5,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          subtitle: const Text(
                            "Handle item batches with caution care parameters",
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          activeColor: AppColors.primary,
                          onChanged: (val) => setState(() => isFragile = val),
                        ),
                        const Divider(height: 1, color: AppColors.cardBorder),
                        SwitchListTile(
                          value: isReturnable,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                          title: const Text(
                            "Returnable Category",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13.5,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          subtitle: const Text(
                            "Allows item configurations to process refund returns",
                            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                          ),
                          activeColor: AppColors.primary,
                          onChanged: (val) => setState(() => isReturnable = val),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Additional Remarks",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: notesController,
                    maxLines: 3,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                    ),
                    decoration: fieldDecoration("Write notes or details here...", Icons.description_outlined),
                  ),
                ],
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.cardBorder)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: isLoading ? null : handleUpdateCategory,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text(
                        "Save Changes",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}