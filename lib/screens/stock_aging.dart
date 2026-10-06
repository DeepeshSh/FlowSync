import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';
import '../utils/app_theme.dart';
import '../widgets/custom_app_bar.dart';

class AgingItem {
  final Product product;
  final int daysInStorage;
  final DateTime? lastSoldDate;
  final int? daysSinceLastSale;
  final String statusCategory;
  final double tiedUpCapital;

  AgingItem({
    required this.product,
    required this.daysInStorage,
    this.lastSoldDate,
    this.daysSinceLastSale,
    required this.statusCategory,
    required this.tiedUpCapital,
  });
}

class StockAgingScreen extends StatefulWidget {
  const StockAgingScreen({super.key});

  @override
  State<StockAgingScreen> createState() => _StockAgingScreenState();
}

class _StockAgingScreenState extends State<StockAgingScreen> {
  final ProductService _productService = ProductService();
  final TextEditingController _searchController = TextEditingController();

  bool _isLoading = true;
  String _selectedFilter = "All";

  List<AgingItem> _allAgingItems = [];
  List<AgingItem> _filteredAgingItems = [];

  double _totalIdleValue = 0.0;
  int _deadStockCount = 0;
  int _avgAgeDays = 0;

  @override
  void initState() {
    super.initState();
    _loadAgingData();
    _searchController.addListener(_applyFilters);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadAgingData() async {
    try {
      setState(() => _isLoading = true);

      final products = await _productService.getProducts();

      Map<String, DateTime> lastSoldMap = {};
      try {
        final Dio dio = ApiConfig.dio;
        final response = await dio.get("${ApiConfig.baseUrl}/sales");
        final dynamic rawSales = response.data;
        List salesList = [];

        if (rawSales is Map && rawSales.containsKey("data")) {
          salesList = rawSales["data"] ?? [];
        } else if (rawSales is List) {
          salesList = rawSales;
        }

        for (var sale in salesList) {
          if (sale is Map<String, dynamic>) {
            final saleDateStr = sale["saleDate"]?.toString() ?? sale["createdAt"]?.toString();
            if (saleDateStr == null) continue;
            final saleDate = DateTime.tryParse(saleDateStr);
            if (saleDate == null) continue;

            final items = sale["items"] as List? ?? [];
            for (var item in items) {
              if (item is Map<String, dynamic>) {
                final pId = item["productId"]?.toString();
                if (pId != null) {
                  if (!lastSoldMap.containsKey(pId) || saleDate.isAfter(lastSoldMap[pId]!)) {
                    lastSoldMap[pId] = saleDate;
                  }
                }
              }
            }
          }
        }
      } catch (e) {
        debugPrint("Sales cross-reference notice: $e");
      }

      final now = DateTime.now();
      List<AgingItem> computedItems = [];
      double accumIdleValue = 0.0;
      int accumDeadCount = 0;
      int totalDaysSum = 0;

      for (var product in products) {
        DateTime purchaseDate = now;
        if (product.purchaseDate.isNotEmpty) {
          purchaseDate = DateTime.tryParse(product.purchaseDate) ?? now;
        }
        final daysInStorage = now.difference(purchaseDate).inDays.clamp(0, 9999);
        totalDaysSum += daysInStorage;

        DateTime? lastSold = lastSoldMap[product.id];
        int? daysSinceSale;
        if (lastSold != null) {
          daysSinceSale = now.difference(lastSold).inDays.clamp(0, 9999);
        }

        String category = "Active";
        if (daysInStorage >= 90 || (daysSinceSale != null && daysSinceSale >= 60)) {
          category = "Dead";
          accumDeadCount++;
          accumIdleValue += (product.stock * product.purchasePrice);
        } else if (daysInStorage >= 61 || (daysSinceSale != null && daysSinceSale >= 45)) {
          category = "Slow";
          accumIdleValue += (product.stock * product.purchasePrice);
        } else if (daysInStorage >= 31) {
          category = "Moderate";
        } else {
          category = "Active";
        }

        computedItems.add(
          AgingItem(
            product: product,
            daysInStorage: daysInStorage,
            lastSoldDate: lastSold,
            daysSinceLastSale: daysSinceSale,
            statusCategory: category,
            tiedUpCapital: product.stock * product.purchasePrice,
          ),
        );
      }

      computedItems.sort((a, b) => b.daysInStorage.compareTo(a.daysInStorage));

      if (mounted) {
        setState(() {
          _allAgingItems = computedItems;
          _filteredAgingItems = List.from(computedItems);
          _totalIdleValue = accumIdleValue;
          _deadStockCount = accumDeadCount;
          _avgAgeDays = products.isNotEmpty ? (totalDaysSum / products.length).round() : 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to load aging analysis: $e"),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _applyFilters() {
    final query = _searchController.text.toLowerCase().trim();
    setState(() {
      _filteredAgingItems = _allAgingItems.where((item) {
        final matchesSearch = item.product.name.toLowerCase().contains(query) ||
            item.product.sku.toLowerCase().contains(query) ||
            item.product.storageLocation.toLowerCase().contains(query);

        final matchesFilter = _selectedFilter == "All" || item.statusCategory == _selectedFilter;

        return matchesSearch && matchesFilter;
      }).toList();
    });
  }

  String _formatCurrency(double amount) {
    if (amount >= 100000) {
      return "₹${(amount / 100000).toStringAsFixed(1)}L";
    }
    return "₹${amount.toStringAsFixed(0)}";
  }

  Map<String, dynamic> _getStatusBadgeStyle(String category) {
    switch (category) {
      case "Dead":
        return {
          'label': 'Dead Stock',
          'bgColor': const Color(0xFFFEF2F2),
          'borderColor': const Color(0xFFFECACA),
          'textColor': AppColors.error,
        };
      case "Slow":
        return {
          'label': 'Slow Moving',
          'bgColor': const Color(0xFFFFFBEB),
          'borderColor': const Color(0xFFFDE68A),
          'textColor': const Color(0xFFD97706),
        };
      case "Moderate":
        return {
          'label': 'Moderate Age',
          'bgColor': const Color(0xFFE8EEF5),
          'borderColor': const Color(0xFFBFDBFE),
          'textColor': AppColors.primary,
        };
      case "Active":
      default:
        return {
          'label': 'Active Stock',
          'bgColor': const Color(0xFFECFDF5),
          'borderColor': const Color(0xFFA7F3D0),
          'textColor': const Color(0xFF10B981),
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: "Stock Aging",
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: AppColors.textPrimary),
            tooltip: "Refresh",
            onPressed: _loadAgingData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : RefreshIndicator(
              onRefresh: _loadAgingData,
              color: AppColors.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryCard(),
                    const SizedBox(height: 12),
                    _buildFilterChips(),
                    const SizedBox(height: 12),
                    _buildSearchBar(),
                    const SizedBox(height: 14),
                    _filteredAgingItems.isEmpty
                        ? _buildEmptyState()
                        : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _filteredAgingItems.length,
                            separatorBuilder: (context, index) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              return _buildAgingCard(_filteredAgingItems[index]);
                            },
                          ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Idle Capital",
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatCurrency(_totalIdleValue),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
          ),
          Container(width: 1, height: 28, color: AppColors.cardBorder),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Dead Lines",
                    style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "$_deadStockCount items",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD97706),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(width: 1, height: 28, color: AppColors.cardBorder),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text(
                  "Avg Age",
                  style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                ),
                const SizedBox(height: 4),
                Text(
                  "$_avgAgeDays days",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    final filters = [
      {"label": "All", "key": "All"},
      {"label": "Dead (90d+)", "key": "Dead"},
      {"label": "Slow (60d+)", "key": "Slow"},
      {"label": "Moderate (30d+)", "key": "Moderate"},
      {"label": "Active (<30d)", "key": "Active"},
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: filters.map((f) {
          final isSelected = _selectedFilter == f["key"];

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(f["label"]!),
              selected: isSelected,
              selectedColor: AppColors.primary,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.textSecondary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: isSelected ? AppColors.primary : AppColors.cardBorder,
                ),
              ),
              showCheckmark: false,
              onSelected: (_) {
                setState(() {
                  _selectedFilter = f["key"]!;
                  _applyFilters();
                });
              },
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: "Search stock by name, SKU, or rack...",
        hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
        prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textSecondary, size: 18),
        suffixIcon: _searchController.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear, size: 18, color: AppColors.textSecondary),
                onPressed: () {
                  _searchController.clear();
                  _applyFilters();
                },
              )
            : null,
        filled: true,
        fillColor: Colors.white,
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.cardBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
        ),
      ),
    );
  }

  Widget _buildAgingCard(AgingItem item) {
    final badgeStyle = _getStatusBadgeStyle(item.statusCategory);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.product.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      "SKU: ${item.product.sku} • Location: ${item.product.storageLocation.isNotEmpty ? item.product.storageLocation : 'Rack N/A'}",
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: badgeStyle['bgColor'] as Color,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: badgeStyle['borderColor'] as Color),
                ),
                child: Text(
                  badgeStyle['label'] as String,
                  style: TextStyle(
                    color: badgeStyle['textColor'] as Color,
                    fontWeight: FontWeight.bold,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.cardBorder),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Current Stock", style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  const SizedBox(height: 2),
                  Text(
                    "${item.product.stock} ${item.product.unit.isNotEmpty ? item.product.unit : 'pcs'}",
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Tied-up Capital", style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  const SizedBox(height: 2),
                  Text(
                    _formatCurrency(item.tiedUpCapital),
                    style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.error),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text("Storage Age", style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  const SizedBox(height: 2),
                  Text(
                    "${item.daysInStorage} days",
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                      color: badgeStyle['textColor'] as Color,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                item.daysSinceLastSale != null
                    ? Icons.shopping_bag_outlined
                    : Icons.remove_shopping_cart_outlined,
                size: 13,
                color: item.daysSinceLastSale != null ? AppColors.textMuted : AppColors.error,
              ),
              const SizedBox(width: 4),
              Text(
                item.daysSinceLastSale != null
                    ? "Last sold: ${item.daysSinceLastSale} days ago"
                    : "No recorded sales — Idle Occupant",
                style: TextStyle(
                  fontSize: 11.5,
                  color: item.daysSinceLastSale != null ? AppColors.textMuted : AppColors.error,
                  fontWeight: item.daysSinceLastSale != null ? FontWeight.normal : FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.inventory_2_outlined, size: 40, color: AppColors.textMuted),
          SizedBox(height: 10),
          Text(
            "No aging stock matches criteria",
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}