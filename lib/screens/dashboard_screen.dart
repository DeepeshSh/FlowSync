import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../models/dashboard_summary.dart';
import '../models/product_model.dart';
import '../models/purchase_model.dart';
import '../models/sale_model.dart';
import '../services/auth_service.dart';
import '../services/dashboard_service.dart';
import '../services/notification_service.dart';
import '../services/product_service.dart';
import '../services/purchase_service.dart';
import '../services/sale_service.dart';
import '../services/warehouse_service.dart';
import '../utils/app_theme.dart';
import 'add_product_screen.dart';
import 'damage_report.dart';
import 'damaged_products_screen.dart';
import 'invoices_screen.dart';
import 'low_stock_products_screen.dart';
import 'product_logs_screen.dart';
import 'stock_aging.dart';
import 'stock_movement.dart';

// ---------- TABULAR NUMBER HELPERS ----------
String formatIndianCurrency(double value) {
  final isNegative = value < 0;
  final v = value.abs();
  final intPart = v.toStringAsFixed(0);

  String lastThree = intPart.length > 3
      ? intPart.substring(intPart.length - 3)
      : intPart;
  String otherDigits = intPart.length > 3
      ? intPart.substring(0, intPart.length - 3)
      : '';

  if (otherDigits.isNotEmpty) {
    otherDigits = otherDigits.replaceAllMapped(
      RegExp(r'\B(?=(\d{2})+(?!\d))'),
      (match) => ',',
    );
    lastThree = ',$lastThree';
  }

  return '${isNegative ? '-' : ''}₹ $otherDigits$lastThree';
}

String formatCount(num value) {
  final intPart = value.toStringAsFixed(0);
  return intPart.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => ',',
  );
}

class DashboardScreen extends StatefulWidget {
  final DashboardSummary? initialSummary;
  final Map<String, dynamic>? initialStats;

  const DashboardScreen({
    super.key,
    this.initialSummary,
    this.initialStats,
  });

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardService _dashboardService = DashboardService();
  final AuthService _authService = AuthService();
  final ProductService _productService = ProductService();
  final SaleService _saleService = SaleService();
  final PurchaseService _purchaseService = PurchaseService();
  final WarehouseService _warehouseService = WarehouseService();

  DashboardSummary? _summary;
  AppUser? _user;
  List<Product> _products = [];
  List<Sale> _sales = [];
  List<Purchase> _purchases = [];
  List<dynamic> _warehouses = [];

  Map<String, dynamic> _inventoryStats = {
    'totalProducts': 0,
    'totalStock': 0,
    'lowStockCount': 0,
    'totalValue': 0.0,
  };

  bool _isLoading = true;
  String? _error;
  bool _hasTriggeredLowStockNotification = false;

  // Experimental Graph Switchers
  String _selectedGraphMetric = 'Sales vs Purchase';
  String _selectedTimeFrame = 'Last 7 Days';

  @override
  void initState() {
    super.initState();
    _initDashboard();
  }

  Future<void> _initDashboard() async {
    final cachedUser = await _authService.getCachedUser();
    if (mounted && cachedUser != null) {
      setState(() {
        _user = cachedUser;
      });
    }
    await _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      final results = await Future.wait([
        _dashboardService.getDashboardSummary(),
        _authService.fetchCurrentUser(),
        _productService.getInventoryStats(),
        _productService.getProducts(),
        _saleService.getSales(),
        _purchaseService.getPurchases(),
        _warehouseService.getWarehouses(),
      ]).timeout(const Duration(seconds: 6));

      if (!mounted) return;

      final stats = results[2] as Map<String, dynamic>;
      final lowStockCount = (stats['lowStockCount'] as num?)?.toInt() ?? 0;

      if (lowStockCount > 0 && !_hasTriggeredLowStockNotification) {
        _hasTriggeredLowStockNotification = true;
        NotificationService().showLowStockAlert(
          productName: '$lowStockCount items near minimum threshold',
          remainingStock: lowStockCount,
        );
      }

      setState(() {
        _summary = results[0] as DashboardSummary;
        _user = results[1] as AppUser?;
        _inventoryStats = stats;
        _products = results[3] as List<Product>;
        _sales = results[4] as List<Sale>;
        _purchases = results[5] as List<Purchase>;
        _warehouses = results[6] as List<dynamic>;
        _isLoading = false;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = "Could not synchronize ERP metrics: $e";
      });
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  double get _todaysSalesAmount {
    return _sales
        .where((s) => _isToday(s.saleDate))
        .fold(0.0, (sum, s) => sum + s.totalAmount);
  }

  double get _todaysPurchasesAmount {
    return _purchases
        .where((p) => _isToday(p.purchaseDate))
        .fold(0.0, (sum, p) => sum + (p.totalAmount > 0 ? p.totalAmount : p.balanceDue + p.advancePayment));
  }

  int get _todaysStockOutCount {
    return _sales
        .where((s) => _isToday(s.saleDate))
        .fold(0, (sum, s) => sum + s.items.fold(0, (iSum, item) => iSum + item.quantity));
  }

  int get _todaysStockInCount {
    return _purchases
        .where((p) => _isToday(p.purchaseDate))
        .fold(0, (sum, p) {
          int count = 0;
          try {
            count = (p as dynamic).items?.fold(0, (iSum, item) => iSum + (item.quantity as int)) ?? 0;
          } catch (_) {
            count = 1;
          }
          return sum + count;
        });
  }

  @override
  Widget build(BuildContext context) {
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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 100),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderSection(),
                _buildCurrentState(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ================= EXACT INVENTORY-ALIGNED HEADER =================
  Widget _buildHeaderSection() {
    final String businessTitle = (_user?.businessName != null && _user!.businessName.trim().isNotEmpty)
        ? _user!.businessName.trim()
        : ((_user?.name != null && _user!.name.trim().isNotEmpty)
            ? _user!.name.trim()
            : "FlowSync ERP");

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (Navigator.canPop(context)) ...[
            IconButton(
              icon: const Icon(Icons.arrow_back, size: 22, color: AppColors.primary),
              constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  businessTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  "Manage all your operational metrics\nacross all networks",
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Image.asset(
            'lib/assets/images/dashboard_screen_header.png',
            height: 80,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.dashboard_outlined, color: Color(0xFF0F294A), size: 28),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentState() {
    if (_isLoading && _summary == null && _products.isEmpty) {
      return _buildSkeletonShimmer();
    }

    if (_error != null && _products.isEmpty) {
      return _buildErrorState();
    }

    return _buildPopulatedDashboard();
  }

  Widget _buildSkeletonShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _skeletonBox(height: 64)),
              const SizedBox(width: 8),
              Expanded(child: _skeletonBox(height: 64)),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: _skeletonBox(height: 64)),
              const SizedBox(width: 8),
              Expanded(child: _skeletonBox(height: 64)),
            ],
          ),
          const SizedBox(height: 16),
          _skeletonBox(height: 220),
          const SizedBox(height: 16),
          _skeletonBox(height: 180),
        ],
      ),
    );
  }

  Widget _skeletonBox({required double height}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: const Color(0xFFE2E8F0).withOpacity(0.6),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off_outlined, size: 48, color: Color(0xFFEF4444)),
            const SizedBox(height: 16),
            const Text(
              "Operational Synchronization Failed",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
            ),
            const SizedBox(height: 8),
            Text(
              _error ?? "Unable to connect to live ERP services.",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                setState(() => _isLoading = true);
                _loadDashboardData();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F294A),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.refresh, size: 18, color: Colors.white),
              label: const Text("Retry Connection", style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPopulatedDashboard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCleanTopOperationalStrip(),
          const SizedBox(height: 16),
          _buildExperimentalGraphSection(),
          const SizedBox(height: 18),
          _buildCategoryPieChartSection(),
          const SizedBox(height: 18),
          _buildLiveWarehouseUtilizationSection(),
          const SizedBox(height: 18),
          _buildLiveRecentTransactionsSection(),
          const SizedBox(height: 18),
          _buildCoreOperationsHeader(),
          const SizedBox(height: 8),
          _buildCoreOperationsList(),
          const SizedBox(height: 18),
          _buildBillingManagementSection(),
        ],
      ),
    );
  }

  // ================= 1. CLEAN TOP CHIPS =================
  Widget _buildCleanTopOperationalStrip() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _buildCleanMetricTile(
                title: "Today's Stock In",
                value: "${formatCount(_todaysStockInCount)} pcs",
                icon: Icons.south_west_rounded,
                accentColor: const Color(0xFF0F294A),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildCleanMetricTile(
                title: "Today's Stock Out",
                value: "${formatCount(_todaysStockOutCount)} pcs",
                icon: Icons.north_east_rounded,
                accentColor: const Color(0xFF10B981),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildCleanMetricTile(
                title: "Today's Purchase",
                value: formatIndianCurrency(_todaysPurchasesAmount),
                icon: Icons.account_balance_wallet_outlined,
                accentColor: const Color(0xFFF59E0B),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildCleanMetricTile(
                title: "Today's Sales",
                value: formatIndianCurrency(_todaysSalesAmount),
                icon: Icons.currency_rupee_rounded,
                accentColor: const Color(0xFF00B287),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCleanMetricTile({
    required String title,
    required String value,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x03000000),
            spreadRadius: 1,
            blurRadius: 6,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: accentColor, size: 18),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0F172A),
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ================= 2. TESTING FEATURE: INTERACTIVE GRAPHS =================
  Widget _buildExperimentalGraphSection() {
    final List<double> salesPoints = _generateTrendData(isSale: true);
    final List<double> purchasePoints = _generateTrendData(isSale: false);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x03000000),
            spreadRadius: 1,
            blurRadius: 6,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Analytics",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                flex: 6,
                child: Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedGraphMetric,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Color(0xFF64748B)),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedGraphMetric = val);
                      },
                      items: const [
                        DropdownMenuItem(value: 'Sales Graph', child: Text("Sales Graph")),
                        DropdownMenuItem(value: 'Purchase Graph', child: Text("Purchase Graph")),
                        DropdownMenuItem(value: 'Sales vs Purchase', child: Text("Sales vs Purchase")),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 4,
                child: Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedTimeFrame,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: Color(0xFF64748B)),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedTimeFrame = val);
                      },
                      items: const [
                        DropdownMenuItem(value: 'Today', child: Text("Today")),
                        DropdownMenuItem(value: 'Last 7 Days', child: Text("7 Days")),
                        DropdownMenuItem(value: 'This Month', child: Text("Month")),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          SizedBox(
            height: 150,
            width: double.infinity,
            child: CustomPaint(
              painter: _DynamicTrendChartPainter(
                salesData: (_selectedGraphMetric == 'Sales Graph' || _selectedGraphMetric == 'Sales vs Purchase')
                    ? salesPoints
                    : [],
                purchaseData: (_selectedGraphMetric == 'Purchase Graph' || _selectedGraphMetric == 'Sales vs Purchase')
                    ? purchasePoints
                    : [],
              ),
            ),
          ),
          const SizedBox(height: 12),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_selectedGraphMetric == 'Sales Graph' || _selectedGraphMetric == 'Sales vs Purchase') ...[
                Row(
                  children: [
                    Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFF00B287), shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    const Text("Sales Outflow", style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(width: 16),
              ],
              if (_selectedGraphMetric == 'Purchase Graph' || _selectedGraphMetric == 'Sales vs Purchase') ...[
                Row(
                  children: [
                    Container(width: 10, height: 10, decoration: const BoxDecoration(color: Color(0xFF0F294A), shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    const Text("Purchase Inflow", style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  List<double> _generateTrendData({required bool isSale}) {
    final int pointsCount = _selectedTimeFrame == 'Today' ? 6 : (_selectedTimeFrame == 'Last 7 Days' ? 7 : 12);
    final List<double> result = List.filled(pointsCount, 0.0);
    final now = DateTime.now();

    if (isSale) {
      for (final sale in _sales) {
        final diff = now.difference(sale.saleDate).inDays;
        if (diff >= 0 && diff < pointsCount) {
          result[pointsCount - 1 - diff] += sale.totalAmount;
        }
      }
    } else {
      for (final purchase in _purchases) {
        final diff = now.difference(purchase.purchaseDate).inDays;
        final amt = purchase.totalAmount > 0 ? purchase.totalAmount : purchase.balanceDue + purchase.advancePayment;
        if (diff >= 0 && diff < pointsCount) {
          result[pointsCount - 1 - diff] += amt;
        }
      }
    }

    if (result.every((val) => val == 0.0)) {
      return isSale ? [10, 25, 18, 40, 30, 55, 45] : [15, 18, 30, 22, 45, 38, 50];
    }
    return result;
  }

  // ================= 3. CATEGORY PIE CHART + BOTTOM READABLE LEGEND =================
  Widget _buildCategoryPieChartSection() {
    final Map<String, double> catValuation = {};
    for (final p in _products) {
      final val = p.stock * p.sellingPrice;
      catValuation[p.categoryName] = (catValuation[p.categoryName] ?? 0.0) + val;
    }

    final totalVal = catValuation.values.fold(0.0, (s, v) => s + v);
    final sorted = catValuation.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final displaySlices = sorted.take(4).toList();

    final colors = [
      const Color(0xFF0F294A),
      const Color(0xFF00B287),
      const Color(0xFF3B82F6),
      const Color(0xFFF59E0B),
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x03000000),
            spreadRadius: 1,
            blurRadius: 6,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Category Stock Valuation",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
                "${_products.length} Products Analyzed",
                style: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
              ),
            ],
          ),
          const SizedBox(height: 18),

          Center(
            child: SizedBox(
              width: 140,
              height: 140,
              child: CustomPaint(
                painter: _PieChartPainter(
                  values: displaySlices.map((e) => e.value).toList(),
                  colors: colors,
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          const SizedBox(height: 14),

          displaySlices.isEmpty
              ? const Center(
                  child: Text("No category data recorded.", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 13)),
                )
              : Column(
                  children: displaySlices.asMap().entries.map((entry) {
                    final i = entry.key;
                    final e = entry.value;
                    final pct = totalVal > 0 ? (e.value / totalVal * 100).toStringAsFixed(0) : "0";

                    return Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFF1F5F9)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: colors[i % colors.length],
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              e.key,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                          ),
                          Text(
                            "$pct%  •  ${formatIndianCurrency(e.value)}",
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'monospace',
                              color: Color(0xFF0F294A),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ],
      ),
    );
  }

  // ================= 4. LIVE WAREHOUSE UTILIZATION =================
  Widget _buildLiveWarehouseUtilizationSection() {
    final Map<String, int> warehouseItemCount = {};
    for (final p in _products) {
      final loc = p.storageLocation.trim().isNotEmpty ? p.storageLocation : "General Depot";
      warehouseItemCount[loc] = (warehouseItemCount[loc] ?? 0) + p.stock;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Warehouse Stock Allocation",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            Text(
              "${_warehouses.length} Active Hubs",
              style: const TextStyle(fontSize: 11.5, color: Color(0xFF94A3B8)),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x03000000),
                spreadRadius: 1,
                blurRadius: 6,
                offset: Offset(0, 2),
              )
            ],
          ),
          child: _warehouses.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Center(child: Text("No registered warehouses in node.", style: TextStyle(color: Color(0xFF64748B)))),
                )
              : Column(
                  children: _warehouses.map((wh) {
                    String name = "Primary Warehouse";
                    String code = "WH-01";
                    int cap = 1000;

                    try {
                      name = (wh as dynamic).name?.toString() ?? "Primary Warehouse";
                    } catch (_) {}
                    try {
                      code = (wh as dynamic).code?.toString() ?? "WH-01";
                    } catch (_) {}
                    try {
                      final dynamic rawCap = (wh as dynamic).capacity;
                      if (rawCap is num) cap = rawCap.toInt();
                    } catch (_) {
                      cap = 1000;
                    }
                    if (cap <= 0) cap = 1000;

                    final stored = warehouseItemCount[name] ?? warehouseItemCount[code] ?? 0;
                    final pct = (stored / cap).clamp(0.0, 1.0);

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.warehouse_outlined, size: 16, color: Color(0xFF0F294A)),
                                  const SizedBox(width: 8),
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1E293B),
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                "$stored / $cap pcs",
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: 'monospace',
                                  color: Color(0xFF0F294A),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(3),
                            child: LinearProgressIndicator(
                              value: pct,
                              minHeight: 6,
                              backgroundColor: const Color(0xFFF1F5F9),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                pct > 0.85 ? const Color(0xFFEA580C) : const Color(0xFF0F294A),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }

  // ================= 5. LIVE RECENT TRANSACTIONS =================
  Widget _buildLiveRecentTransactionsSection() {
    final List<Map<String, dynamic>> combined = [];

    for (final s in _sales) {
      combined.add({
        'title': s.customerName.toUpperCase(),
        'no': s.saleNumber,
        'amount': s.totalAmount,
        'date': s.saleDate,
        'isSale': true,
        'status': s.paymentStatus.toUpperCase(),
      });
    }

    for (final p in _purchases) {
      final amt = p.totalAmount > 0 ? p.totalAmount : p.balanceDue + p.advancePayment;
      combined.add({
        'title': p.supplierName.toUpperCase(),
        'no': p.purchaseNumber,
        'amount': amt,
        'date': p.purchaseDate,
        'isSale': false,
        'status': p.paymentStatus.toUpperCase(),
      });
    }

    combined.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
    final recentFour = combined.take(4).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Recent Orders & Invoices",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0F172A),
              ),
            ),
            InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InvoicesScreen()),
              ),
              child: const Text(
                "View All",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00B287),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
            boxShadow: const [
              BoxShadow(
                color: Color(0x03000000),
                spreadRadius: 1,
                blurRadius: 6,
                offset: Offset(0, 2),
              )
            ],
          ),
          child: recentFour.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(
                    child: Text("No live transactions found in ERP ledger.", style: TextStyle(color: Color(0xFF64748B), fontSize: 13)),
                  ),
                )
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: recentFour.length,
                  separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFFF1F5F9)),
                  itemBuilder: (context, index) {
                    final order = recentFour[index];
                    final bool isSale = order['isSale'] as bool;
                    final double amount = order['amount'] as double;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSale ? const Color(0xFFECFDF5) : const Color(0xFFE8EEF5),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              isSale ? Icons.arrow_outward_rounded : Icons.south_west_rounded,
                              size: 16,
                              color: isSale ? const Color(0xFF10B981) : const Color(0xFF0F294A),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  order['title'] as String,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E293B),
                                  ),
                                ),
                                Text(
                                  order['no'] as String,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: Color(0xFF64748B),
                                    fontFamily: 'monospace',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                formatIndianCurrency(amount),
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                  color: isSale ? const Color(0xFF00B287) : const Color(0xFF0F294A),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF1F5F9),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  order['status'] as String,
                                  style: const TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF64748B),
                                  ),
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
  }

  // ================= 6. CORE OPERATIONS =================
  Widget _buildCoreOperationsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: const [
        Text(
          "Core Operations & Audits",
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
        Text(
          "6 Modules",
          style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
        ),
      ],
    );
  }

  Widget _buildCoreOperationsList() {
    final int lowStock =
        (_inventoryStats['lowStockCount'] as num?)?.toInt() ?? 0;

    final List<Map<String, dynamic>> operations = [
      {
        'title': 'Damaged Products',
        'subtitle': 'Review broken & written-off items',
        'badge': 'Audit',
        'icon': Icons.broken_image_outlined,
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DamagedProductsScreen()),
            ),
      },
      {
        'title': 'Product Logs',
        'subtitle': 'Master audit movement ledger',
        'badge': 'Ledger',
        'icon': Icons.receipt_long_outlined,
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProductLogsScreen()),
            ),
      },
      {
        'title': 'Low Stock Alert',
        'subtitle': 'Items near depletion threshold',
        'badge': '$lowStock items',
        'icon': Icons.warning_amber_rounded,
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const LowStockProductsScreen(),
              ),
            ),
      },
      {
        'title': 'Damage Report',
        'subtitle': 'Log new damage incident or breakage',
        'badge': 'Incident',
        'icon': Icons.assignment_late_outlined,
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const DamageReportScreen()),
            ),
      },
      {
        'title': 'Stock Movement',
        'subtitle': 'Record transfers, restocks & adjustments',
        'badge': 'Move',
        'icon': Icons.sync_alt_rounded,
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StockMovementScreen()),
            ),
      },
      {
        'title': 'Stock Aging',
        'subtitle': 'Dead stock & slow-moving capital report',
        'badge': 'Aging',
        'icon': Icons.hourglass_bottom_rounded,
        'onTap': () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const StockAgingScreen()),
            ),
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x03000000),
            spreadRadius: 1,
            blurRadius: 6,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: operations.length,
        separatorBuilder: (context, index) =>
            const Divider(height: 1, color: Color(0xFFF1F5F9)),
        itemBuilder: (context, index) {
          final item = operations[index];
          return InkWell(
            onTap: item['onTap'] as VoidCallback,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 48),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    Icon(
                      item['icon'] as IconData,
                      size: 20,
                      color: const Color(0xFF0F294A),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item['title'] as String,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          Text(
                            item['subtitle'] as String,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                            color: const Color(0xFFE2E8F0), width: 1.0),
                      ),
                      child: Text(
                        item['badge'] as String,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.chevron_right,
                        size: 18, color: Color(0xFF94A3B8)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ================= 7. BILLING & INVOICING ENGINE =================
  Widget _buildBillingManagementSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.0),
        boxShadow: const [
          BoxShadow(
            color: Color(0x03000000),
            spreadRadius: 1,
            blurRadius: 6,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Billing & Invoicing Engine",
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const InvoicesScreen()),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.all(4),
                  child: Text(
                    "All Invoices",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F294A),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const InvoicesScreen()),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                  icon: const Icon(Icons.receipt_long_outlined, size: 16, color: Color(0xFF0F294A)),
                  label: const Text(
                    "Manage Bills",
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600, color: Color(0xFF0F294A)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AddProductScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F294A),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                  icon: const Icon(Icons.add, size: 16, color: Colors.white),
                  label: const Text(
                    "Add Product",
                    style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ================= CUSTOM VECTOR CHART PAINTERS =================
class _DynamicTrendChartPainter extends CustomPainter {
  final List<double> salesData;
  final List<double> purchaseData;

  _DynamicTrendChartPainter({required this.salesData, required this.purchaseData});

  @override
  void paint(Canvas canvas, Size size) {
    final double maxVal = math.max(
      salesData.isNotEmpty ? salesData.reduce(math.max) : 10.0,
      purchaseData.isNotEmpty ? purchaseData.reduce(math.max) : 10.0,
    );

    final Paint gridPaint = Paint()
      ..color = const Color(0xFFF1F5F9)
      ..strokeWidth = 1;

    for (int i = 0; i <= 3; i++) {
      final y = size.height * (i / 3);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (purchaseData.isNotEmpty) {
      _drawLine(canvas, size, purchaseData, maxVal, const Color(0xFF0F294A));
    }
    if (salesData.isNotEmpty) {
      _drawLine(canvas, size, salesData, maxVal, const Color(0xFF00B287));
    }
  }

  void _drawLine(Canvas canvas, Size size, List<double> data, double maxVal, Color color) {
    final Paint linePaint = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final Path path = Path();
    final stepX = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y = size.height - ((data[i] / (maxVal == 0 ? 1 : maxVal)) * (size.height - 15)) - 8;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
      canvas.drawCircle(Offset(x, y), 3.5, Paint()..color = color);
      canvas.drawCircle(Offset(x, y), 1.8, Paint()..color = Colors.white);
    }

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant _DynamicTrendChartPainter oldDelegate) => true;
}

class _PieChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;

  _PieChartPainter({required this.values, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final double total = values.fold(0.0, (s, v) => s + v);
    if (total == 0) {
      canvas.drawCircle(
        Offset(size.width / 2, size.height / 2),
        size.width / 2,
        Paint()..color = const Color(0xFFF1F5F9),
      );
      return;
    }

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    double startAngle = -math.pi / 2;

    for (int i = 0; i < values.length; i++) {
      final sweepAngle = (values[i] / total) * 2 * math.pi;
      final paint = Paint()
        ..color = colors[i % colors.length]
        ..style = PaintingStyle.fill;

      canvas.drawArc(rect, startAngle, sweepAngle, true, paint);
      startAngle += sweepAngle;
    }

    // Inner cutout to create donut design
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width * 0.34,
      Paint()..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(covariant _PieChartPainter oldDelegate) => true;
}