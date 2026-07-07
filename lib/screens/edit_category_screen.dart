import 'package:flutter/material.dart';

import '../models/category_model.dart';
import '../services/category_service.dart';

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
    
    // Safety check matching unit options array to prevent any assertion fallback crash
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
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
      prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 20),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
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
      // Re-map localized states safely onto object signatures
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
    const Color textPrimary = Color(0xFF0F172A);
    const Color textMuted = Color(0xFF64748B);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Theme Gradient Flow Background
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFE2EAF2),
                    Color(0xFFF1F5F9),
                    Colors.white,
                  ],
                  stops: [0.0, 0.25, 0.6],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                // Title Navigation Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 16, 10),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.maybePop(context),
                        child: const Padding(
                          padding: EdgeInsets.all(4.0),
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            color: textPrimary,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Edit Category",
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: textPrimary,
                                letterSpacing: -0.5,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              "Modify configurations and specifications",
                              style: TextStyle(color: textMuted, fontSize: 12.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Category Details",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textPrimary),
                        ),
                        const SizedBox(height: 12),

                        // Category Name Field
                        TextField(
                          controller: categoryNameController,
                          style: const TextStyle(color: textPrimary, fontWeight: FontWeight.w500),
                          decoration: fieldDecoration("Category Name *", Icons.folder_outlined),
                        ),
                        const SizedBox(height: 16),

                        // Parent Category Dropdown
                        DropdownButtonFormField<String>(
                          value: categories.any((c) => c.id == selectedParentCategory) ? selectedParentCategory : null,
                          dropdownColor: Colors.white,
                          style: const TextStyle(color: textPrimary, fontWeight: FontWeight.w500),
                          decoration: fieldDecoration("Parent Category", Icons.account_tree_outlined),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text("None (Primary)", style: TextStyle(color: textMuted)),
                            ),
                            ...categories
                                .where((c) => c.id != widget.category.id)
                                .map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
                          ],
                          onChanged: (val) => setState(() => selectedParentCategory = val),
                        ),
                        const SizedBox(height: 16),

                        // Unit of Measurement Dropdown
                        DropdownButtonFormField<String>(
                          value: selectedUnit,
                          dropdownColor: Colors.white,
                          style: const TextStyle(color: textPrimary, fontWeight: FontWeight.w500),
                          decoration: fieldDecoration("Unit of Measurement", Icons.square_foot_rounded),
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text("Select Unit", style: TextStyle(color: textMuted)),
                            ),
                            ...availableUnits.map((u) => DropdownMenuItem(value: u, child: Text(u))),
                          ],
                          onChanged: (val) => setState(() => selectedUnit = val),
                        ),
                        const SizedBox(height: 20),

                        const Text(
                          "Compliance Settings",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textPrimary),
                        ),
                        const SizedBox(height: 8),

                        // Switch Selectors for Premium Look
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            children: [
                              SwitchListTile(
                                value: isFragile,
                                title: const Text("Fragile Cargo", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: textPrimary)),
                                subtitle: const Text("Handle item batches with caution care parameters", style: TextStyle(fontSize: 12)),
                                activeColor: const Color(0xFF3B82F6),
                                onChanged: (val) => setState(() => isFragile = val),
                              ),
                              const Divider(height: 1, color: Color(0xFFF1F5F9)),
                              SwitchListTile(
                                value: isReturnable,
                                title: const Text("Returnable Category", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14, color: textPrimary)),
                                subtitle: const Text("Allows item configurations to process refund returns", style: TextStyle(fontSize: 12)),
                                activeColor: const Color(0xFF3B82F6),
                                onChanged: (val) => setState(() => isReturnable = val),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        const Text(
                          "Additional Remarks",
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textPrimary),
                        ),
                        const SizedBox(height: 12),

                        // Description Notes Text Input
                        TextField(
                          controller: notesController,
                          maxLines: 4,
                          style: const TextStyle(color: textPrimary),
                          decoration: fieldDecoration("Write notes or details here...", Icons.description_outlined),
                        ),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),

                // Absolute Placed Actions Footer Row
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(top: BorderSide(color: const Color(0xFFE2E8F0))),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : handleUpdateCategory,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF10B981),
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                            )
                          : const Text(
                              "Save Changes",
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}