import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../models/category_model.dart';

import '../services/product_service.dart';
import '../services/category_service.dart';

import 'add_product_screen.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  List<Product> allProducts = [];

  List<Product> filteredProducts = [];

  List<Category> categories = [];

  bool isLoading = true;

  int expandedIndex = -1;

  String selectedCategory = "All";

  String selectedTab = "All Products";

  final searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    loadData();
  }

  Future<void> loadData() async {
    try {
      final products = await ProductService().getProducts();

      final categoryList = await CategoryService().getCategories();

      setState(() {
        allProducts = products;

        filteredProducts = products;

        categories = categoryList;

        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> refreshProducts() async {
    final products = await ProductService().getProducts();

    setState(() {
      allProducts = products;

      filterProducts();
    });
  }

  void filterProducts() {
    List<Product> temp = List.from(allProducts);

    if (selectedCategory != "All") {
      temp = temp.where((product) {
        return product.categoryName == selectedCategory;
      }).toList();
    }

    if (selectedTab == "Low Stock") {
      temp = temp.where((product) {
        return product.stock <= product.lowStockThreshold;
      }).toList();
    }

    if (searchController.text.isNotEmpty) {
      temp = temp.where((product) {
        return product.name.toLowerCase().contains(
              searchController.text.toLowerCase(),
            ) ||
            product.sku.toLowerCase().contains(
              searchController.text.toLowerCase(),
            );
      }).toList();
    }

    setState(() {
      filteredProducts = temp;
    });
  }

  int get totalProducts => allProducts.length;

  int get totalStock {
    return allProducts.fold(0, (sum, item) => sum + item.stock);
  }

  int get lowStockProducts {
    return allProducts.where((item) {
      return item.stock <= item.lowStockThreshold;
    }).length;
  }

  double get inventoryValue {
    return allProducts.fold(
      0,
      (sum, item) => sum + (item.purchasePrice * item.stock),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FC),

      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2F80FF),

        child: const Icon(Icons.add, color: Colors.white),

        onPressed: () async {
          await Navigator.push(
            context,

            MaterialPageRoute(builder: (_) => const AddProductScreen()),
          );

          refreshProducts();
        },
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  // HEADER
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),

                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,

                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: const [
                            Text(
                              "Inventory",

                              style: TextStyle(
                                fontSize: 28,

                                fontWeight: FontWeight.bold,

                                color: Color(0xFF1B2559),
                              ),
                            ),

                            SizedBox(height: 4),

                            Text(
                              "Manage your products",

                              style: TextStyle(
                                color: Colors.grey,

                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),

                        Container(
                          width: 50,
                          height: 50,

                          decoration: BoxDecoration(
                            color: Colors.white,

                            borderRadius: BorderRadius.circular(16),

                            boxShadow: const [
                              BoxShadow(color: Colors.black12, blurRadius: 10),
                            ],
                          ),

                          child: const Icon(
                            Icons.inventory_2,

                            color: Color(0xFF2F80FF),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // STATS
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),

                    child: Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            "Products",

                            totalProducts.toString(),

                            Icons.inventory_2,

                            const Color(0xFF2F80FF),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: _buildStatCard(
                            "Low Stock",

                            lowStockProducts.toString(),

                            Icons.warning_amber,

                            Colors.orange,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),

                    child: Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            "Stock",

                            totalStock.toString(),

                            Icons.warehouse,

                            Colors.green,
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: _buildStatCard(
                            "Value",

                            "₹${inventoryValue.toStringAsFixed(0)}",

                            Icons.currency_rupee,

                            Colors.purple,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // FILTERS
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),

                    child: Row(
                      children: [
                        Expanded(
                          child: _buildTopFilter(
                            "All Products",

                            selectedTab == "All Products",

                            () {
                              setState(() {
                                selectedTab = "All Products";

                                selectedCategory = "All";
                              });

                              filterProducts();
                            },
                          ),
                        ),

                        Expanded(
                          child: _buildTopFilter(
                            "Low Stock",

                            selectedTab == "Low Stock",

                            () {
                              setState(() {
                                selectedTab = "Low Stock";
                              });

                              filterProducts();
                            },
                          ),
                        ),
                        Expanded(
                          child: _buildTopFilter(
                            "Categories",

                            selectedTab == "Categories",

                            () async {
                              final selected =
                                  await showModalBottomSheet<String>(
                                    context: context,

                                    builder: (context) {
                                      return ListView(
                                        children: categories.map((category) {
                                          return ListTile(
                                            title: Text(category.name),

                                            onTap: () {
                                              Navigator.pop(
                                                context,

                                                category.name,
                                              );
                                            },
                                          );
                                        }).toList(),
                                      );
                                    },
                                  );

                              if (selected != null) {
                                setState(() {
                                  selectedTab = "Categories";

                                  selectedCategory = selected;
                                });

                                filterProducts();
                              }
                            },
                          ),
                        ),

                        Expanded(
                          child: _buildTopFilter(
                            "Brands",

                            selectedTab == "Brands",

                            () {
                              setState(() {
                                selectedTab = "Brands";
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 15),

                  // SEARCH
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),

                    child: TextField(
                      controller: searchController,

                      onChanged: (value) {
                        filterProducts();
                      },

                      decoration: InputDecoration(
                        hintText: "Search products...",

                        prefixIcon: const Icon(Icons.search),

                        filled: true,

                        fillColor: Colors.white,

                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),

                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // PRODUCT LIST
                  Expanded(
                    child: filteredProducts.isEmpty
                        ? const Center(child: Text("No Products Found"))
                        : ListView.builder(
                            padding: const EdgeInsets.only(
                              left: 20,
                              right: 20,
                              bottom: 100,
                            ),

                            itemCount: filteredProducts.length,

                            itemBuilder: (context, index) {
                              final product = filteredProducts[index];

                              final bool lowStock =
                                  product.stock <= product.lowStockThreshold;

                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    expandedIndex = expandedIndex == index
                                        ? -1
                                        : index;
                                  });
                                },

                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),

                                  margin: const EdgeInsets.only(bottom: 16),

                                  decoration: BoxDecoration(
                                    color: Colors.white,

                                    borderRadius: BorderRadius.circular(24),

                                    boxShadow: const [
                                      BoxShadow(
                                        color: Colors.black12,

                                        blurRadius: 10,

                                        offset: Offset(0, 4),
                                      ),
                                    ],
                                  ),

                                  child: Column(
                                    children: [
                                      // TOP CARD
                                      Padding(
                                        padding: const EdgeInsets.all(16),

                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,

                                          children: [
                                            // PRODUCT IMAGE
                                            Container(
                                              width: 75,

                                              height: 75,

                                              decoration: BoxDecoration(
                                                color: const Color(0xFFEAF2FF),

                                                borderRadius:
                                                    BorderRadius.circular(16),
                                              ),

                                              child: const Icon(
                                                Icons.inventory_2,

                                                size: 35,

                                                color: Color(0xFF2F80FF),
                                              ),
                                            ),

                                            const SizedBox(width: 14),

                                            // PRODUCT INFO
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,

                                                children: [
                                                  Text(
                                                    product.name,

                                                    style: const TextStyle(
                                                      fontSize: 17,

                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),

                                                  const SizedBox(height: 4),

                                                  Text(
                                                    "${product.categoryName} • ${product.brandName}",

                                                    style: const TextStyle(
                                                      color: Colors.grey,
                                                    ),
                                                  ),

                                                  const SizedBox(height: 8),

                                                  Container(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 8,

                                                          vertical: 4,
                                                        ),

                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                        0xFFEAE4FF,
                                                      ),

                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            8,
                                                          ),
                                                    ),

                                                    child: Text(
                                                      product.sku,

                                                      style: const TextStyle(
                                                        color: Color(
                                                          0xFF6C4DFF,
                                                        ),

                                                        fontWeight:
                                                            FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),

                                                  const SizedBox(height: 6),

                                                  Text(
                                                    product.storageLocation,

                                                    style: const TextStyle(
                                                      color: Colors.grey,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),

                                            // STOCK PANEL
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.end,

                                              children: [
                                                const Text(
                                                  "Stock",

                                                  style: TextStyle(
                                                    color: Colors.grey,
                                                  ),
                                                ),

                                                Text(
                                                  product.stock.toString(),

                                                  style: TextStyle(
                                                    fontSize: 28,

                                                    fontWeight: FontWeight.bold,

                                                    color: lowStock
                                                        ? Colors.orange
                                                        : const Color(
                                                            0xFF6C4DFF,
                                                          ),
                                                  ),
                                                ),

                                                Text(product.unit),

                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 10,

                                                        vertical: 4,
                                                      ),

                                                  decoration: BoxDecoration(
                                                    color: lowStock
                                                        ? Colors.orange.shade50
                                                        : Colors.green.shade50,

                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          20,
                                                        ),
                                                  ),

                                                  child: Text(
                                                    lowStock
                                                        ? "Low Stock"
                                                        : "In Stock",

                                                    style: TextStyle(
                                                      color: lowStock
                                                          ? Colors.orange
                                                          : Colors.green,

                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),

                                      AnimatedCrossFade(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),

                                        crossFadeState: expandedIndex == index
                                            ? CrossFadeState.showSecond
                                            : CrossFadeState.showFirst,

                                        firstChild: const SizedBox(),
                                        secondChild: Container(
                                          width: double.infinity,

                                          padding: const EdgeInsets.all(16),

                                          decoration: const BoxDecoration(
                                            border: Border(
                                              top: BorderSide(
                                                color: Color(0xFFE5E7EB),
                                              ),
                                            ),
                                          ),

                                          child: Column(
                                            children: [
                                              _detailRow("SKU", product.sku),

                                              _detailRow(
                                                "Brand",
                                                product.brandName,
                                              ),

                                              _detailRow(
                                                "Category",
                                                product.categoryName,
                                              ),

                                              _detailRow("Unit", product.unit),

                                              _detailRow(
                                                "Location",
                                                product.storageLocation,
                                              ),

                                              _detailRow(
                                                "Low Stock Alert",
                                                product.lowStockThreshold
                                                    .toString(),
                                              ),

                                              _detailRow(
                                                "Purchase Price",
                                                "₹${product.purchasePrice}",
                                              ),

                                              _detailRow(
                                                "Selling Price",
                                                "₹${product.sellingPrice}",
                                              ),

                                              const SizedBox(height: 16),

                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: ElevatedButton.icon(
                                                      onPressed: () {},

                                                      icon: const Icon(
                                                        Icons.edit,
                                                      ),

                                                      label: const Text("Edit"),

                                                      style:
                                                          ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                const Color(
                                                                  0xFF2F80FF,
                                                                ),

                                                            foregroundColor:
                                                                Colors.white,
                                                          ),
                                                    ),
                                                  ),

                                                  const SizedBox(width: 10),

                                                  Expanded(
                                                    child: ElevatedButton.icon(
                                                      onPressed: () {},

                                                      icon: const Icon(
                                                        Icons.delete,
                                                      ),

                                                      label: const Text(
                                                        "Delete",
                                                      ),

                                                      style:
                                                          ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                                Colors.red,

                                                            foregroundColor:
                                                                Colors.white,
                                                          ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _detailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),

          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildTopFilter(String title, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        padding: const EdgeInsets.only(bottom: 12),

        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: selected ? const Color(0xFF6C4DFF) : Colors.transparent,

              width: 3,
            ),
          ),
        ),

        child: Text(
          title,

          textAlign: TextAlign.center,

          style: TextStyle(
            color: selected ? const Color.fromARGB(255, 77, 139, 255) : Colors.black87,

            fontWeight: selected ? FontWeight.bold : FontWeight.w500,

            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(20),

        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),

            decoration: BoxDecoration(
              color: color.withOpacity(0.12),

              borderRadius: BorderRadius.circular(12),
            ),

            child: Icon(icon, color: color, size: 18),
          ),

          const SizedBox(height: 12),

          Text(
            value,

            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 4),

          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        ],
      ),
    );
  }
}
