import 'package:flutter/material.dart';

import '../models/category_model.dart';
import '../models/product_model.dart';
import '../services/category_service.dart';
import '../services/product_service.dart';
import 'add_categories_screen.dart';
import 'edit_category_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  List<Category> categories = [];
  List<Category> filteredCategories = [];
  List<Product> allProducts = [];
  bool isLoading = true;
  final TextEditingController searchController = TextEditingController();
  final ProductService _productService = ProductService();
  int totalProducts = 0;

  @override
  void initState() {
    super.initState();
    loadCategories();
  }

  Future<void> loadCategories() async {
    try {
      final categoriesData = await CategoryService().getCategories();
      final productsData = await _productService.getProducts();

      if (!mounted) return;
      setState(() {
        categories = categoriesData;
        filteredCategories = categoriesData;
        allProducts = productsData;
        totalProducts = productsData.length;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  void searchCategories(String query) {
    setState(() {
      filteredCategories = categories.where((category) {
        return category.name.toLowerCase().contains(query.toLowerCase());
      }).toList();
    });
  }

  int getCategoryItemCount(Category category) {
    return allProducts.where((p) {
      return p.categoryName.toLowerCase() == category.name.toLowerCase() ||
          p.categoryName.toLowerCase() == category.id.toLowerCase();
    }).length;
  }

  void _showCategoryProductsSheet(BuildContext context, Category category) {
    final categoryProducts = allProducts.where((p) {
      return p.categoryName.toLowerCase() == category.name.toLowerCase() ||
          p.categoryName.toLowerCase() == category.id.toLowerCase();
    }).toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.7,
          minChildSize: 0.4,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.folder_rounded, color: Color(0xFF3B82F6)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "${category.name} — Products",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0F172A),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: categoryProducts.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inventory_2_outlined,
                                  size: 48, color: Colors.grey.shade300),
                              const SizedBox(height: 8),
                              const Text(
                                "No products linked to this category yet",
                                style: TextStyle(color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        )
                      : ListView.separated(
                          controller: scrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: categoryProducts.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (context, index) {
                            final product = categoryProducts[index];
                            return Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF8FAFC),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 44,
                                    height: 44,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: const Color(0xFFE2E8F0)),
                                    ),
                                    child: product.imageUrl.isNotEmpty
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.network(
                                              product.imageUrl,
                                              fit: BoxFit.cover,
                                              errorBuilder: (_, __, ___) => const Icon(
                                                Icons.inventory_2_outlined,
                                                color: Color(0xFF3B82F6),
                                              ),
                                            ),
                                          )
                                        : const Icon(
                                            Icons.inventory_2_outlined,
                                            color: Color(0xFF3B82F6),
                                          ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFF0F172A),
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          "SKU: ${product.sku} | Unit: ${product.unit}",
                                          style: const TextStyle(
                                            color: Color(0xFF64748B),
                                            fontSize: 12,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        "${product.stock} Pcs",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: product.stock <= product.lowStockThreshold
                                              ? Colors.orange
                                              : const Color(0xFF10B981),
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "₹${product.sellingPrice.toStringAsFixed(0)}",
                                        style: const TextStyle(
                                          color: Color(0xFF3B82F6),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFDBEAFE)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Total Categories Element
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 2),
                const Text(
                  "Categories",
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  categories.length.toString(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Container(
            width: 1,
            height: 65,
            color: const Color(0xFFDBEAFE),
          ),

          // Total Items Element
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 2),
                const Text(
                  "Total Items",
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w600),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  totalProducts.toString(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCategoryCard(Category category) {
    const Color textPrimary = Color(0xFF0F172A);
    const Color textMuted = Color(0xFF64748B);
    final tiedItemsCount = getCategoryItemCount(category);

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _showCategoryProductsSheet(context, category),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.015),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFDBEAFE)),
              ),
              child: const Icon(
                Icons.folder_rounded,
                color: Color(0xFF3B82F6),
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    category.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    category.notes.isEmpty ? "No descriptions added" : category.notes,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13,
                      color: textMuted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.layers_rounded, size: 13, color: Color(0xFF64748B)),
                        const SizedBox(width: 6),
                        Text(
                          "$tiedItemsCount Items Tied",
                          style: const TextStyle(
                            color: Color(0xFF475569),
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => showActionSelectionMenu(category),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.more_horiz_rounded,
                  color: Color(0xFF94A3B8),
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showActionSelectionMenu(Category category) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const Text(
                  "Choose an option below to manage this category",
                  style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    child: const Icon(Icons.inventory_2_outlined, color: Colors.blue, size: 20),
                  ),
                  title: const Text("View Linked Products", style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.pop(context);
                    _showCategoryProductsSheet(context, category);
                  },
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.withOpacity(0.1),
                    child: const Icon(Icons.edit_outlined, color: Colors.blue, size: 20),
                  ),
                  title: const Text("Edit Details", style: TextStyle(fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => EditCategoryScreen(category: category)),
                    ).then((_) => loadCategories());
                  },
                ),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.red.withOpacity(0.1),
                    child: const Icon(Icons.delete_outline_rounded, color: Colors.red, size: 20),
                  ),
                  title: const Text("Remove Category", style: TextStyle(color: Colors.red, fontWeight: FontWeight.w600)),
                  onTap: () {
                    Navigator.pop(context);
                    showDeleteConfirmation(category);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void showDeleteConfirmation(Category category) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(10)),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Confirm Deletion",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                ),
                const SizedBox(height: 10),
                Text(
                  "Are you sure you want to completely delete the \"${category.name}\" category?",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Cancel", style: TextStyle(color: Color(0xFF64748B))),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        ),
                        onPressed: () async {
                          Navigator.pop(context);
                          setState(() => isLoading = true);
                          await CategoryService().deleteCategory(category.id);
                          loadCategories();
                        },
                        child: const Text("Delete", style: TextStyle(color: Colors.white)),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color textPrimary = Color(0xFF0F172A);
    const Color textMuted = Color(0xFF64748B);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
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
                  stops: [0.0, 0.35, 0.7],
                ),
              ),
            ),
          ),
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                  child: RefreshIndicator(
                    onRefresh: loadCategories,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 16, 16, 0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
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
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: const [
                                      Text(
                                        "Categories",
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w800,
                                          color: textPrimary,
                                          letterSpacing: -0.5,
                                        ),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        "Manage product lines & specifications",
                                        style: TextStyle(color: textMuted, fontSize: 12.5),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: buildHeaderCard(),
                          ),
                          const SizedBox(height: 20),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: TextField(
                              controller: searchController,
                              onChanged: searchCategories,
                              decoration: InputDecoration(
                                hintText: "Search your category list...",
                                hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B)),
                                filled: true,
                                fillColor: Colors.white,
                                contentPadding: const EdgeInsets.symmetric(vertical: 14),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(14),
                                  borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          filteredCategories.isEmpty
                              ? Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 60.0),
                                  child: Center(
                                    child: Column(
                                      children: const [
                                        Icon(Icons.folder_open_outlined, size: 48, color: Color(0xFF94A3B8)),
                                        SizedBox(height: 12),
                                        Text(
                                          "No Categories Found",
                                          style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  padding: const EdgeInsets.only(left: 20, right: 20, bottom: 100),
                                  itemCount: filteredCategories.length,
                                  itemBuilder: (context, index) {
                                    return buildCategoryCard(filteredCategories[index]);
                                  },
                                ),
                        ],
                      ),
                    ),
                  ),
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF10B981),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddCategoriesScreen()),
          );
          loadCategories();
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Add Category",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 0.3),
        ),
      ),
    );
  }
}