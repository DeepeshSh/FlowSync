import 'package:flutter/material.dart';
import 'manage_variants_screen.dart';
import 'add_product_screen.dart';
import '../services/product_service.dart';
import '../models/product_model.dart';
import 'edit_product_screen.dart';

// ==========================================================================
// DB/API DATA CONTRACT OBJECT MODE CONFIGURATIONS
// ==========================================================================

class ProductVariant {
  final String id;
  final String name;
  int stock;

  ProductVariant({
    required this.id,
    required this.name,
    required this.stock,
  });

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    return ProductVariant(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      stock: json['stock'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'stock': stock,
  };
}

class InventoryItem {
  final String id;
  final String name;
  final String sku;
  final String category;
  final String brand;
  final String rack;
  final String imageUrl;
  final double buyPrice;
  final double sellPrice;
  final List<ProductVariant> variants;

  InventoryItem({
    required this.id,
    required this.name,
    required this.sku,
    required this.category,
    required this.brand,
    required this.rack,
    required this.imageUrl,
    required this.buyPrice,
    required this.sellPrice,
    required this.variants,
  });

  int get totalStock => variants.isNotEmpty 
      ? variants.fold(0, (sum, item) => sum + item.stock)
      : 0;
      
  bool get isLowStock => totalStock < 15;

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    String getNestedName(dynamic field, String fallback) {
      if (field is Map) return field['name']?.toString() ?? fallback;
      return field?.toString() ?? fallback;
    }

    int baseStock = json['stock'] ?? 0;
    List<ProductVariant> parseVariants = [];
    
    if (json['variants'] != null && (json['variants'] as List).isNotEmpty) {
      parseVariants = (json['variants'] as List)
          .map((v) => ProductVariant.fromJson(v))
          .toList();
    } else {
      parseVariants = [
        ProductVariant(id: 'default', name: 'Standard Item', stock: baseStock)
      ];
    }

    return InventoryItem(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      sku: json['sku'] ?? 'N/A',
      category: getNestedName(json['category'], 'General'),
      brand: json['brandName'] ?? json['brand'] ?? 'N/A',
      rack: json['storageLocation'] ?? json['rack'] ?? 'Main-Zone',
      imageUrl: json['imageUrl'] ?? json['image_url'] ?? '',
      buyPrice: (json['purchasePrice'] as num?)?.toDouble() ?? (json['buy_price'] as num?)?.toDouble() ?? 0.0,
      sellPrice: (json['sellingPrice'] as num?)?.toDouble() ?? (json['sell_price'] as num?)?.toDouble() ?? 0.0,
      variants: parseVariants,
    );
  }
}

// ==========================================================================
// CORE STATEFUL APP GRAPHICS RENDER ENGINE SCREEN
// ==========================================================================

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final ProductService _productService = ProductService();
  List<InventoryItem> _items = [];
  bool _isLoading = true;
  String _selectedFilter = 'All';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchLiveBackendData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchLiveBackendData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final List<Product> products = await _productService.getProducts();
      if (!mounted) return;

      setState(() {
        _items = products.map((product) {
          return InventoryItem(
            id: product.id,
            name: product.name,
            sku: product.sku,
            category: product.categoryName,
            brand: product.brandName,
            rack: product.storageLocation,
            imageUrl: product.imageUrl,
            buyPrice: product.purchasePrice,
            sellPrice: product.sellingPrice,
            variants: [
              ProductVariant(
                id: "default",
                name: "Standard",
                stock: product.stock,
              ),
            ],
          );
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  int get totalProducts => _items.length;
  double get totalStockValue => _items.fold(0.0, (sum, item) => sum + (item.totalStock * item.sellPrice));
  int get lowStockItemsCount => _items.where((item) => item.isLowStock).length;
  int get calculatedUniqueWarehouses => _items.map((e) => e.rack.split('-').first).toSet().length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Premium Fading Layout Background Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFE2EAF2), // Rich premium slate tint at top
                    Color(0xFFF1F5F9), // Fades down smoothly
                    Colors.white,      // Pure clean asset focal baseline
                  ],
                  stops: [0.0, 0.35, 0.7],
                ),
              ),
            ),
          ),

          // 2. Ambient Flow Accents (To make screen look premium across other areas)
          Positioned(
            right: -60,
            top: 360,
            child: Container(
              width: 200,
              height: 200,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0x0C3B82F6), Colors.transparent],
                ),
              ),
            ),
          ),

          // 3. Main Screen Interactive Frame
          _isLoading
              ? const Center(child: CircularProgressIndicator(color: Color(0xFF2563EB)))
              : SafeArea(
                  child: RefreshIndicator(
                    onRefresh: _fetchLiveBackendData,
                    color: const Color(0xFF2563EB),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeaderSection(),
                          _buildSummaryCard2x2Grid(),
                          _buildFilterRowSection(),
                          _buildDynamicProductList(),
                          const SizedBox(height: 120), 
                        ],
                      ),
                    ),
                  ),
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddProductScreen()),
          );
          if (!mounted) return;
          if (result == true || result == null) {
            _fetchLiveBackendData();
          }
        },
        backgroundColor: const Color(0xFF2563EB),
        elevation: 3,
        icon: const Icon(Icons.add, color: Colors.white, size: 22),
        label: const Text(
          "Add Product",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
  return Padding(
    // Controlled padding around the header area
    padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
    child: Row(
      // Vertically centers all three components perfectly inline with each other
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. Perfectly Aligned Back Button Arrow
        GestureDetector(
          onTap: () => Navigator.maybePop(context),
          child: const Padding(
            padding: EdgeInsets.all(4.0), // Expands touch target without shifting position
            child: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF0F172A),
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 16),

        // 2. Core Typography Content Block
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Inventory",
                style: TextStyle(
                  fontSize: 24, // Slightly balanced down from 26 to match vertical symmetry
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF0F172A),
                  letterSpacing: -0.5,
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Manage products & stock across all warehouses",
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12.5,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),

        // 3. Parallel Image & Background Container
        SizedBox(
          width: 120, 
          height: 95, 
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Main Abstract Organic Soft Blue Shape Backdrop
              Positioned(
                right: -5,
                top: 8,
                child: Container(
                  width: 105, 
                  height: 85, 
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE).withOpacity(0.75), 
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(50),
                      topRight: Radius.circular(40),
                      bottomLeft: Radius.circular(45),
                      bottomRight: Radius.circular(55),
                    ),
                  ),
                ),
              ),
              
              // Secondary background accent blob
              Positioned(
                right: 45,
                top: 0,
                child: Container(
                  width: 38, 
                  height: 34, 
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F9FF).withOpacity(0.7),
                    shape: BoxShape.circle,
                  ),
                ),
              ),

              // Main Illustration Image Asset Layer
              Positioned(
                bottom: 0,
                right: -5,
                child: Image.asset(
                  "lib/assets/images/inventory_header.png",
                  width: 110,  
                  height: 90, 
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) {
                    return Container(
                      width: 72,
                      height: 72,
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.warehouse_outlined,
                        size: 36,
                        color: Color(0xFF0F172A),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
  Widget _buildSummaryCard2x2Grid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.2,
        children: [
          _buildMetricItem('$totalProducts', 'Total Products', const Color(0xFFEFF6FF), const Color(0xFF2563EB), Icons.inventory_2_outlined),
          _buildMetricItem('₹${(totalStockValue / 100000).toStringAsFixed(1)}L', 'Total Stock Value', const Color(0xFFECFDF5), const Color(0xFF10B981), Icons.currency_rupee),
          _buildMetricItem('$lowStockItemsCount', 'Low Stock Items', const Color(0xFFFFF7ED), const Color(0xFFF97316), Icons.warning_amber_rounded),
          _buildMetricItem('$calculatedUniqueWarehouses', 'Warehouses', const Color(0xFFF5F3FF), const Color(0xFF8B5CF6), Icons.storefront_outlined),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String value, String title, Color bg, Color tint, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 20, backgroundColor: bg, child: Icon(icon, size: 20, color: tint)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A))),
                const SizedBox(height: 1),
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500)),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildFilterRowSection() {
    final filters = ['All', 'Low Stock', 'Categories', 'Brands'];
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 46,
                  decoration: BoxDecoration(
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() {}),
                    decoration: InputDecoration(
                      hintText: 'Search products, SKU...',
                      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                      prefixIcon: const Icon(Icons.search, color: Color(0xFF94A3B8), size: 18),
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: EdgeInsets.zero,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                height: 46,
                width: 46,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFE2E8F0))),
                child: const Icon(Icons.filter_list, color: Color(0xFF2563EB), size: 20),
              )
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: filters.map((tab) {
              bool isSelected = _selectedFilter == tab;
              return Expanded(
                child: InkWell(
                  onTap: () => setState(() => _selectedFilter = tab),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: isSelected ? const Color(0xFF2563EB) : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: isSelected ? Colors.transparent : const Color(0xFFE2E8F0)),
                    ),
                    child: Text(
                      tab,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: isSelected ? Colors.white : const Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              );
            }).toList(),
          )
        ],
      ),
    );
  }

  Widget _buildDynamicProductList() {
    List<InventoryItem> filteredItems = _items;
    
    if (_selectedFilter == 'Low Stock') {
      filteredItems = filteredItems.where((e) => e.isLowStock).toList();
    }
    
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      filteredItems = filteredItems.where((e) => 
        e.name.toLowerCase().contains(query) || 
        e.sku.toLowerCase().contains(query)
      ).toList();
    }

    if (filteredItems.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: Text("No items found matching criteria.", style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.w500)),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredItems.length,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemBuilder: (context, idx) {
        final item = filteredItems[idx];

        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white, 
            borderRadius: BorderRadius.circular(16), 
            border: Border.all(color: const Color(0xFFF1F5F9)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10, offset: const Offset(0, 4))],
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: item.imageUrl.isEmpty
                        ? Container(
                            width: 80,
                            height: 80,
                            color: const Color(0xFFF1F5F9),
                            child: const Icon(Icons.inventory_2_outlined, color: Color(0xFF94A3B8)),
                          )
                        : Image.network(
                            item.imageUrl,
                            width: 80, 
                            height: 80, 
                            fit: BoxFit.cover, 
                            errorBuilder: (_, __, ___) => Container(
                              color: const Color(0xFFF1F5F9), 
                              width: 80, 
                              height: 80, 
                              child: const Icon(Icons.image_not_supported_outlined, color: Color(0xFF94A3B8)),
                            ),
                          ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF0F172A), letterSpacing: -0.3)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(4)),
                          child: Text('SKU: ${item.sku}', style: const TextStyle(color: Color(0xFF2563EB), fontSize: 10, fontWeight: FontWeight.bold)),
                        ),
                        const SizedBox(height: 6),
                        Text('Category: ${item.category} • Brand: ${item.brand}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w500)),
                        const SizedBox(height: 2),
                        Text('Location: ${item.rack} 📍', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text('Stock', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11, fontWeight: FontWeight.w500)),
                      const SizedBox(height: 2),
                      Text('${item.totalStock} PCS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: item.isLowStock ? const Color(0xFFEF4444) : const Color(0xFF0F172A))),
                      if (item.isLowStock)
                        Container(
                          margin: const EdgeInsets.only(top: 6),
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFFFFF7ED), borderRadius: BorderRadius.circular(4)),
                          child: const Text('Low Stock', style: TextStyle(color: Color(0xFFEA580C), fontSize: 9, fontWeight: FontWeight.bold)),
                        )
                    ],
                  )
                ],
              ),
              const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(color: Color(0xFFF1F5F9), height: 1)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Buy Price', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 2),
                          Text('₹${item.buyPrice.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                      const SizedBox(width: 24),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Sell Price', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 10, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 2),
                          Text('₹${item.sellPrice.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 14)),
                        ],
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ManageVariantsScreen(
                            product: Product(
                              id: item.id,
                              name: item.name,
                              sku: item.sku,
                              brandName: item.brand,
                              unit: "Piece",
                              storageLocation: item.rack,
                              stock: item.totalStock,
                              lowStockThreshold: 5,
                              purchasePrice: item.buyPrice,
                              sellingPrice: item.sellPrice,
                              categoryName: item.category,
                              imageUrl: item.imageUrl,
                            ),
                          ),
                        ),
                      );
                      if (result == true) {
                        _fetchLiveBackendData();
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(8)),
                      child: Row(
                        children: [
                          const Icon(Icons.layers_outlined, color: Color(0xFF2563EB), size: 14),
                          const SizedBox(width: 6),
                          Text('Variants (${item.variants.length})', style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      icon: const Icon(Icons.edit_outlined, size: 14, color: Color(0xFF64748B)),
                      label: const Text('Edit', style: TextStyle(color: Color(0xFF475569), fontSize: 13, fontWeight: FontWeight.w600)),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditProductScreen(
                              product: Product(
                                id: item.id,
                                name: item.name,
                                sku: item.sku,
                                brandName: item.brand,
                                unit: "Piece",
                                storageLocation: item.rack,
                                stock: item.totalStock,
                                lowStockThreshold: 5,
                                purchasePrice: item.buyPrice,
                                sellingPrice: item.sellPrice,
                                categoryName: item.category,
                                imageUrl: item.imageUrl,
                              ),
                            ),
                          ),
                        );
                        if (result == true) {
                          _fetchLiveBackendData();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFFEE2E2)),
                        backgroundColor: const Color(0xFFFEF2F2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                      icon: const Icon(Icons.delete_outline, size: 14, color: Color(0xFFEF4444)),
                      label: const Text('Delete', style: TextStyle(color: Color(0xFFEF4444), fontSize: 13, fontWeight: FontWeight.w600)),
                      onPressed: () async {
                        try {
                          await _productService.deleteProduct(item.id);
                          if (!mounted) return;
                          _fetchLiveBackendData();
                        } catch (e) {
                          if (!mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to delete: $e'), backgroundColor: const Color(0xFFEF4444)),
                          );
                        }
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}