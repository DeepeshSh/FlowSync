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
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFE5ECF4),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00B287)),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE5ECF4), Color(0xFFF1F5F9), Color(0xFFFFFFFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0.0, 0.35, 1.0],
          ),
        ),
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: _fetchLiveBackendData,
            color: const Color(0xFF2563EB),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        icon: const Icon(Icons.add, color: Colors.white, size: 20),
        label: const Text(
          "Add Product",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }

  // ================= EXQUISITE HEADER SECTION =================
  Widget _buildHeaderSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () => Navigator.maybePop(context),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF0F172A),
              size: 18,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Inventory",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A)),
                ),
                SizedBox(height: 6),
                Text(
                  "Manage products & stock across\n all warehouses",
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 15,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            height: 102,
            width: 102,
            child: Image.asset(
              "lib/assets/images/inventory_header.png",
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) => Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.inventory_2_outlined, color: Color(0xFF2563EB), size: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= SYNCED STAT CARDS GRID =================
  Widget _buildSummaryCard2x2Grid() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        childAspectRatio: 2.1,
        children: [
          _buildMetricItem('$totalProducts', 'Total Products', const Color(0xFF2563EB), Icons.inventory_2_outlined),
          _buildMetricItem('₹${(totalStockValue / 100000).toStringAsFixed(1)}L', 'Total Stock Value', const Color(0xFF10B981), Icons.currency_rupee),
          _buildMetricItem('$lowStockItemsCount', 'Low Stock Items', const Color(0xFFF97316), Icons.warning_amber_rounded),
          _buildMetricItem('$calculatedUniqueWarehouses', 'Warehouses', const Color(0xFF8B5CF6), Icons.storefront_outlined),
        ],
      ),
    );
  }

  Widget _buildMetricItem(String value, String title, Color tint, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0x99E2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: tint.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: tint, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  // ================= SEARCH + FILTER ROW =================
  Widget _buildFilterRowSection() {
    final filters = ['All', 'Low Stock', 'Categories', 'Brands'];
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x05000000),
                        spreadRadius: 1,
                        blurRadius: 8,
                        offset: Offset(0, 2),
                      )
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (v) => setState(() {}),
                    decoration: const InputDecoration(
                      hintText: 'Search products, SKU...',
                      hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                      prefixIcon: Icon(Icons.search, color: Color(0xFF94A3B8), size: 22),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 15),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                height: 52,
                width: 52,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
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
                      borderRadius: BorderRadius.circular(10),
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
          ),
          // Added correct padding/gap spacing context layout alignment below the horizontal chips
          const SizedBox(height: 20), 
        ],
      ),
    );
  }

  // ================= PRODUCT LIST ITEMS =================
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
        return _ProductCardItem(
          item: item,
          productService: _productService,
          onRefresh: _fetchLiveBackendData,
        );
      },
    );
  }
}

// ==========================================================================
// EXPANDABLE INDIVIDUAL PRODUCT CARD ITEM
// ==========================================================================

class _ProductCardItem extends StatefulWidget {
  final InventoryItem item;
  final ProductService productService;
  final VoidCallback onRefresh;

  const _ProductCardItem({
    required this.item,
    required this.productService,
    required this.onRefresh,
  });

  @override
  State<_ProductCardItem> createState() => _ProductCardItemState();
}

class _ProductCardItemState extends State<_ProductCardItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isExpanded = !_isExpanded;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _isExpanded ? const Color(0xFF2563EB).withOpacity(0.4) : const Color(0xFFF1F5F9),
            width: _isExpanded ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: _isExpanded ? const Color(0x0A2563EB) : const Color(0x03000000),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: widget.item.imageUrl.isEmpty
                      ? Container(
                          width: 44,
                          height: 44,
                          color: const Color(0xFFF1F5F9),
                          child: const Icon(Icons.inventory_2_outlined, color: Color(0xFF94A3B8), size: 20),
                        )
                      : Image.network(
                          widget.item.imageUrl,
                          width: 44,
                          height: 44,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: const Color(0xFFF1F5F9),
                            width: 44,
                            height: 44,
                            child: const Icon(Icons.image_not_supported_outlined, color: Color(0xFF94A3B8), size: 20),
                          ),
                        ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.item.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1E293B)),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(4)),
                        child: Text('SKU: ${widget.item.sku}', style: const TextStyle(color: Color(0xFF3B82F6), fontSize: 11, fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(height: 6),
                      Text('${widget.item.category} • ${widget.item.brand}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                      const SizedBox(height: 2),
                      Text('Location: ${widget.item.rack}', style: const TextStyle(color: Color(0xFF64748B), fontSize: 12)),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text('Stock', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                    const SizedBox(height: 4),
                    Text(
                      '${widget.item.totalStock} PCS',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: widget.item.isLowStock ? const Color(0xFFEF4444) : const Color(0xFF0F172A),
                      ),
                    ),
                    if (widget.item.isLowStock)
                      Container(
                        margin: const EdgeInsets.only(top: 4),
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: const Color(0xFFFFF7ED), borderRadius: BorderRadius.circular(6)),
                        child: const Text('Low Stock', style: TextStyle(color: Color(0xFFEA580C), fontSize: 11, fontWeight: FontWeight.bold)),
                      )
                  ],
                )
              ],
            ),
            const SizedBox(height: 14),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Buy Price', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                        const SizedBox(height: 2),
                        Text('₹${widget.item.buyPrice.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF00B287), fontWeight: FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                    const SizedBox(width: 24),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Sell Price', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                        const SizedBox(height: 2),
                        Text('₹${widget.item.sellPrice.toStringAsFixed(2)}', style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 16)),
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
                            id: widget.item.id,
                            name: widget.item.name,
                            sku: widget.item.sku,
                            brandName: widget.item.brand,
                            unit: "Piece",
                            storageLocation: widget.item.rack,
                            stock: widget.item.totalStock,
                            lowStockThreshold: 5,
                            purchasePrice: widget.item.buyPrice,
                            sellingPrice: widget.item.sellPrice,
                            categoryName: widget.item.category,
                            imageUrl: widget.item.imageUrl,
                          ),
                        ),
                      ),
                    );
                    if (result == true) {
                      widget.onRefresh();
                    }
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(color: const Color(0xFFF8FAFC), borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      children: [
                        const Icon(Icons.layers_outlined, size: 14, color: Color(0xFF64748B)),
                        const SizedBox(width: 4),
                        Text('${widget.item.variants.length} Variants', style: const TextStyle(color: Color(0xFF1E293B), fontSize: 12, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            // Expandable segment holding the primary edit/delete action sheet triggers
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                children: [
                  const SizedBox(height: 14),
                  const Divider(color: Color(0xFFF1F5F9), height: 1),
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
                                    id: widget.item.id,
                                    name: widget.item.name,
                                    sku: widget.item.sku,
                                    brandName: widget.item.brand,
                                    unit: "Piece",
                                    storageLocation: widget.item.rack,
                                    stock: widget.item.totalStock,
                                    lowStockThreshold: 5,
                                    purchasePrice: widget.item.buyPrice,
                                    sellingPrice: widget.item.sellPrice,
                                    categoryName: widget.item.category,
                                    imageUrl: widget.item.imageUrl,
                                  ),
                                ),
                              ),
                            );
                            if (result == true) {
                              widget.onRefresh();
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
                              await widget.productService.deleteProduct(widget.item.id);
                              widget.onRefresh();
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to delete: $e'), backgroundColor: const Color(0xFFEF4444)),
                              );
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 200),
            ),
          ],
        ),
      ),
    );
  }
}