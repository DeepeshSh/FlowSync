import 'package:flutter/material.dart';
import '../models/warehouse_model.dart';
import '../models/product_model.dart';
import '../services/warehouse_service.dart';
import '../services/product_service.dart';
import 'add_warehouse_screen.dart';

class WarehouseScreen extends StatefulWidget {
  const WarehouseScreen({Key? key}) : super(key: key);

  @override
  State<WarehouseScreen> createState() => _WarehouseScreenState();
}

class _WarehouseScreenState extends State<WarehouseScreen> {
  final WarehouseService _service = WarehouseService();
  final ProductService _productService = ProductService();
  final TextEditingController _searchController = TextEditingController();

  late Future<List<Warehouse>> _warehouseListFuture;
  List<Warehouse> _allWarehouses = [];
  List<Warehouse> _filteredWarehouses = [];

  @override
  void initState() {
    super.initState();
    _refreshData();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _refreshData() {
    setState(() {
      _warehouseListFuture = _service.getWarehouses();
    });
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        _filteredWarehouses = List.from(_allWarehouses);
      } else {
        _filteredWarehouses = _allWarehouses.where((w) {
          return w.name.toLowerCase().contains(query) ||
              w.city.toLowerCase().contains(query) ||
              w.warehouseType.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  String _formatCurrency(double value) {
    if (value >= 100000) {
      return '${(value / 100000).toStringAsFixed(1)}L';
    }
    return value.toStringAsFixed(0);
  }

  void _showWarehouseProductsSheet(BuildContext context, Warehouse warehouse) {
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
                      const Icon(Icons.storefront, color: Color(0xFF2563EB)),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          "${warehouse.name} — Products",
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
                  child: FutureBuilder<List<Product>>(
                    future: _productService.getProducts(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return Center(
                          child: Text(
                            "Error loading products: ${snapshot.error}",
                            style: const TextStyle(color: Colors.red),
                          ),
                        );
                      }

                      final allProducts = snapshot.data ?? [];
                      // Filter products matching this warehouse ID or warehouse name
                      final warehouseProducts = allProducts.where((p) {
                        return p.warehouseId == warehouse.id ||
                            p.storageLocation.toLowerCase().contains(warehouse.name.toLowerCase());
                      }).toList();

                      if (warehouseProducts.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.inventory_2_outlined,
                                  size: 48, color: Colors.grey.shade300),
                              const SizedBox(height: 8),
                              const Text(
                                "No products linked to this warehouse yet",
                                style: TextStyle(color: Color(0xFF64748B)),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: warehouseProducts.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 10),
                        itemBuilder: (context, index) {
                          final product = warehouseProducts[index];
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
                                              color: Color(0xFF2563EB),
                                            ),
                                          ),
                                        )
                                      : const Icon(
                                          Icons.inventory_2_outlined,
                                          color: Color(0xFF2563EB),
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
                                        color: Color(0xFF2563EB),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: FutureBuilder<List<Warehouse>>(
          future: _warehouseListFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
                    const SizedBox(height: 10),
                    ElevatedButton(onPressed: _refreshData, child: const Text('Retry')),
                  ],
                ),
              );
            }

            _allWarehouses = snapshot.data ?? [];
            if (_searchController.text.isEmpty) {
              _filteredWarehouses = List.from(_allWarehouses);
            }

            int totalWarehousesCount = _allWarehouses.length;
            int totalStockUnitsCount = _allWarehouses.fold(0, (sum, item) => sum + item.totalStockUnits);

            return RefreshIndicator(
              onRefresh: () async => _refreshData(),
              child: CustomScrollView(
                slivers: [
                  // 1. App Header Title & Banner Graphic Area
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B), size: 20),
                                  onPressed: () => Navigator.maybePop(context),
                                ),
                              ),
                              const SizedBox(height: 12),
                              const SizedBox(
                                width: 180,
                                child: Text(
                                  'Warehouses',
                                  style: TextStyle(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF0F172A),
                                    letterSpacing: -0.5,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              const SizedBox(
                                width: 180,
                                child: Text(
                                  'Manage your stock locations',
                                  style: TextStyle(fontSize: 15, color: Color(0xFF64748B), height: 1.2),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                          ),
                          Positioned(
                            right: -10,
                            bottom: -10,
                            child: Image.asset(
                              'lib/assets/images/warehouse.png',
                              height: 140,
                              fit: BoxFit.contain,
                              errorBuilder: (context, error, stackTrace) {
                                return const Icon(Icons.store_mall_directory, size: 80, color: Color(0xFF2563EB));
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 2. High-Level Summary Stat Metrics
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 0),
                      child: Container(
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFEFF6FF),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.storefront_outlined, color: Color(0xFF2563EB), size: 22),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Total Warehouses',
                                            style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w500),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '$totalWarehousesCount',
                                            style: const TextStyle(color: Color(0xFF0F172A), fontSize: 18, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Container(
                              height: 40,
                              width: 1,
                              color: const Color(0xFFE2E8F0),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFECFDF5),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Icon(Icons.token_outlined, color: Color(0xFF10B981), size: 22),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Total Stock',
                                            style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w500),
                                          ),
                                          const SizedBox(height: 4),
                                          RichText(
                                            text: TextSpan(
                                              text: totalStockUnitsCount > 0
                                                  ? totalStockUnitsCount.toString().replaceAllMapped(
                                                        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
                                                        (Match m) => '${m[1]},',
                                                      )
                                                  : '0',
                                              style: const TextStyle(color: Color(0xFF0F172A), fontSize: 18, fontWeight: FontWeight.bold),
                                              children: const [
                                                TextSpan(text: ' Units', style: TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.normal)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // 3. Search Bar Input and Action Trigger Buttons
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFE2E8F0)),
                              ),
                              child: TextField(
                                controller: _searchController,
                                decoration: const InputDecoration(
                                  hintText: 'Search warehouse...',
                                  hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                                  prefixIcon: Icon(Icons.search, color: Color(0xFF94A3B8), size: 20),
                                  border: InputBorder.none,
                                  contentPadding: EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const AddWarehouseScreen()),
                              ).then((_) => _refreshData());
                            },
                            icon: const Icon(Icons.add, size: 18, color: Colors.white),
                            label: const Text('Add Warehouse', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2563EB),
                              elevation: 0,
                              minimumSize: const Size(140, 48),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // 4. Dynamic Iterating List Segment
                  _filteredWarehouses.isEmpty
                      ? const SliverToBoxAdapter(
                          child: Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 40.0),
                              child: Text('No warehouses found matching search criteria.', style: TextStyle(color: Colors.grey)),
                            ),
                          ),
                        )
                      : SliverList(
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              return _buildWarehouseCard(_filteredWarehouses[index]);
                            },
                            childCount: _filteredWarehouses.length,
                          ),
                        ),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWarehouseCard(Warehouse warehouse) {
    bool isPrimary = warehouse.warehouseType.toLowerCase() == 'primary';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), offset: const Offset(0, 4), blurRadius: 16),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isPrimary ? const Color(0xFFEFF6FF) : const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.house_siding_rounded,
                    color: isPrimary ? const Color(0xFF3B82F6) : const Color(0xFF10B981),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(warehouse.name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                          const SizedBox(width: 8),
                          if (isPrimary)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(color: const Color(0xFFDCFCE7), borderRadius: BorderRadius.circular(30)),
                              child: const Text('Primary', style: TextStyle(color: Color(0xFF16A34A), fontSize: 10, fontWeight: FontWeight.bold)),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 14, color: Color(0xFF94A3B8)),
                          const SizedBox(width: 4),
                          Text(
                            '${warehouse.city.isNotEmpty ? warehouse.city : "Unknown Location"}, India',
                            style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.more_vert, color: Color(0xFF94A3B8)),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // Internal Matrix: Products, Value, Stock counts
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildGridItem('Products', '${warehouse.productsCount}', Icons.inventory_2_outlined, const Color(0xFF3B82F6)),
                _buildGridItem('Stock Value', '₹${_formatCurrency(warehouse.stockValue)}', Icons.currency_rupee_rounded, const Color(0xFF10B981)),
                _buildGridItem('Stock', '${warehouse.totalStockUnits}\nUnits', Icons.token_outlined, const Color(0xFF8B5CF6)),
                _buildGridItem('Low Stock', '${warehouse.lowStockItems}\nItems', Icons.error_outline_rounded, const Color(0xFFF59E0B)),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // Link Button Redirect Actions
          InkWell(
            onTap: () => _showWarehouseProductsSheet(context, warehouse),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart_rounded, size: 16, color: Color(0xFF2563EB)),
                  SizedBox(width: 6),
                  Text('View Inventory', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 13)),
                  SizedBox(width: 4),
                  Icon(Icons.chevron_right_rounded, size: 16, color: Color(0xFF2563EB)),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildGridItem(String title, String value, IconData icon, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 12, color: Color(0xFF94A3B8), fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 2.0),
              child: Icon(icon, size: 13, color: color),
            ),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF1E293B), height: 1.2),
            ),
          ],
        ),
      ],
    );
  }
}