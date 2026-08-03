import 'package:flutter/material.dart';
import 'dart:math' as math;

// Screen imports requested by your bottom navigation layout
import 'inventory_screen.dart';
import 'purchase_screen.dart';
import 'more_screen.dart';
import 'sales_screen.dart';

import '/models/app_user.dart';
import '/models/dashboard_summary.dart';
import '/services/auth_service.dart';
import '/services/dashboard_service.dart';

void main() => runApp(const FlowSyncApp());

class FlowSyncApp extends StatelessWidget {
  const FlowSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FlowSync',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(0xFFF4F7FC), // Soft, modern grey-blue background
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

// ---------- COLORS ----------
class AppColors {
  static const blue = Color(0xFF2F80FF);
  static const green = Color(0xFF1FAE6A);
  static const orange = Color(0xFFF5A623);
  static const red = Color(0xFFEF5A5A);
  static const purple = Color(0xFF8B6FF0);
  static const darkText = Color(0xFF1A1D29);
  static const greyText = Color(0xFF7A8293);
  static const cardBg = Colors.white;
}

// ---------- FORMATTING HELPERS ----------
// Indian-style digit grouping, e.g. 1,42,680 (matches the original mock's
// hardcoded "₹ 1,42,680" / "₹ 52,420" values).
String formatIndianCurrency(double value) {
  final isNegative = value < 0;
  final v = value.abs();
  final intPart = v.toStringAsFixed(0);

  String lastThree =
      intPart.length > 3 ? intPart.substring(intPart.length - 3) : intPart;
  String otherDigits =
      intPart.length > 3 ? intPart.substring(0, intPart.length - 3) : '';

  if (otherDigits.isNotEmpty) {
    otherDigits = otherDigits.replaceAllMapped(
      RegExp(r'\B(?=(\d{2})+(?!\d))'),
      (match) => ',',
    );
    lastThree = ',$lastThree';
  }

  return '${isNegative ? '-' : ''}₹ $otherDigits$lastThree';
}

// Plain thousands grouping for non-currency counts, e.g. 1,245 items.
String formatCount(num value) {
  final intPart = value.toStringAsFixed(0);
  return intPart.replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (match) => ',',
  );
}

String formatLakhs(double value) {
  return '₹ ${(value / 100000).toStringAsFixed(1)}L';
}

String formatPercentDelta(double changePercent) {
  return '${changePercent.abs().toStringAsFixed(1)}%';
}

String formatRelativeDateTime(DateTime dt) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final that = DateTime(dt.year, dt.month, dt.day);
  final diffDays = today.difference(that).inDays;

  final hour12 = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
  final minute = dt.minute.toString().padLeft(2, '0');
  final ampm = dt.hour >= 12 ? 'PM' : 'AM';
  final timeStr = '$hour12:$minute $ampm';

  if (diffDays == 0) return 'Today, $timeStr';
  if (diffDays == 1) return 'Yesterday';
  return '${dt.day}/${dt.month}/${dt.year}';
}

String greetingForNow() {
  final hour = DateTime.now().hour;
  if (hour < 12) return 'Good Morning';
  if (hour < 17) return 'Good Afternoon';
  return 'Good Evening';
}

// ---------- MAIN SCREEN (COORDINATOR WITH NAVIGATION) ----------
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;

  final List<Widget> screens = const [
    DashboardScreen(), // Backend-synced dashboard (Home)
    InventoryScreen(),
    PurchaseScreen(),
    SalesScreen(),
    MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppColors.blue,
          unselectedItemColor: Colors.grey[400],
          selectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          elevation: 0,
          onTap: (index) {
            setState(() {
              selectedIndex = index;
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_filled),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2),
              label: "Inventory",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.payments),
              label: "Purchase",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined),
              label: "Sell",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.more_horiz),
              label: "More",
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- SPACIOUS DASHBOARD SCREEN (HOME) ----------
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final DashboardService _dashboardService = DashboardService();
  final AuthService _authService = AuthService();

  DashboardSummary? _summary;
  AppUser? _user;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUser(); // fire-and-forget, header updates independently as it resolves
    _loadDashboard();
  }

  Future<void> _loadUser() async {
    final cached = await _authService.getCachedUser();
    if (cached != null && mounted) {
      setState(() => _user = cached);
    }
    final fresh = await _authService.fetchCurrentUser();
    if (fresh != null && mounted) {
      setState(() => _user = fresh);
    }
  }

  Future<void> _loadDashboard() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final summary = await _dashboardService.getDashboardSummary();
      if (!mounted) return;
      setState(() {
        _summary = summary;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading && _summary == null) {
      return const Scaffold(
        backgroundColor: Color(0xFFF4F7FC),
        body: Center(
          child: CircularProgressIndicator(color: AppColors.blue),
        ),
      );
    }

    if (_error != null && _summary == null) {
      return Scaffold(
        backgroundColor: const Color(0xFFF4F7FC),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_rounded,
                    size: 44, color: AppColors.greyText),
                const SizedBox(height: 12),
                Text(
                  "Couldn't load dashboard.\n$_error",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.greyText, fontSize: 13),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loadDashboard,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text("Retry"),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final summary = _summary!;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FC),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await Future.wait([_loadDashboard(), _loadUser()]);
          },
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeaderSection(user: _user),
                const SizedBox(height: 24),
                _StatsGrid(summary: summary),
                const SizedBox(height: 24),
                _SectionCard(
                  title: 'Warehouse Analytics',
                  actionLabel: 'View Details',
                  child: _WarehouseAnalytics(data: summary.warehouseAnalytics),
                ),
                const SizedBox(height: 24),
                _SectionCard(
                  title: 'Category Distribution',
                  actionLabel: 'View Details',
                  child: _CategoryDistribution(
                    categories: summary.categoryDistribution,
                    totalUnits: summary.totalStockUnits,
                  ),
                ),
                const SizedBox(height: 24),
                _SectionCard(
                  title: 'Low Stock Alerts',
                  actionLabel: 'View All',
                  child: _LowStockAlerts(alerts: summary.lowStockAlerts),
                ),
                const SizedBox(height: 24),
                const _SectionCard(
                  title: 'Quick Actions',
                  child: _QuickActions(),
                ),
                const SizedBox(height: 24),
                _SectionCard(
                  title: 'Recent Transactions',
                  actionLabel: 'View All',
                  child: _RecentTransactions(
                    sales: summary.recentSales,
                    purchases: summary.recentPurchases,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------- HEADER SECTION ----------
class _HeaderSection extends StatelessWidget {
  final AppUser? user;
  const _HeaderSection({required this.user});

  @override
  Widget build(BuildContext context) {
    final displayName =
        (user?.name.isNotEmpty ?? false) ? user!.name : 'there';
    final businessName = user?.businessName ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE8F0FF), Color(0xFFF4F7FC)],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _RoundIconButton(
                icon: Icons.menu,
                onTap: () {},
              ),
              RichText(
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                  ),
                  children: [
                    TextSpan(
                        text: 'Flow', style: TextStyle(color: AppColors.darkText)),
                    TextSpan(
                        text: 'Sync', style: TextStyle(color: AppColors.blue)),
                  ],
                ),
              ),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  _RoundIconButton(icon: Icons.notifications_none, onTap: () {}),
                  Positioned(
                    right: -2,
                    top: -2,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: AppColors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                      child: const Text(
                        '3',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 28),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${greetingForNow()}, $displayName',
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkText,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Text('👋', style: TextStyle(fontSize: 22)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      businessName.isNotEmpty ? businessName : 'Your Business',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.greyText,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    )
                  ],
                ),
                child: const Icon(Icons.store_mall_directory_outlined,
                    size: 32, color: AppColors.blue),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 0.5,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: AppColors.darkText, size: 22),
        ),
      ),
    );
  }
}

// ---------- STATS GRID ----------
class _StatData {
  final String title;
  final String value;
  final String delta;
  final bool isUp;
  final String subtitle;
  final IconData icon;
  final Color color;
  const _StatData(this.title, this.value, this.delta, this.isUp,
      this.subtitle, this.icon, this.color);
}

class _StatsGrid extends StatelessWidget {
  final DashboardSummary summary;
  const _StatsGrid({required this.summary});

  @override
  Widget build(BuildContext context) {
    final stats = [
      _StatData(
        "Today's Sales",
        formatIndianCurrency(summary.todaysSales.value),
        formatPercentDelta(summary.todaysSales.changePercent),
        summary.todaysSales.isUp,
        'vs yesterday',
        Icons.trending_up,
        AppColors.blue,
      ),
      _StatData(
        "Today's Purchases",
        formatIndianCurrency(summary.todaysPurchases.value),
        formatPercentDelta(summary.todaysPurchases.changePercent),
        summary.todaysPurchases.isUp,
        'vs yesterday',
        Icons.shopping_cart,
        AppColors.green,
      ),
      _StatData(
        "Today's Orders",
        summary.todaysOrders.value.toStringAsFixed(0),
        formatPercentDelta(summary.todaysOrders.changePercent),
        summary.todaysOrders.isUp,
        'vs yesterday',
        Icons.assignment,
        AppColors.orange,
      ),
      _StatData(
        'Pending Payments',
        formatIndianCurrency(summary.pendingPayments.value),
        formatPercentDelta(summary.pendingPayments.changePercent),
        summary.pendingPayments.isUp,
        'from last week',
        Icons.account_balance_wallet,
        AppColors.red,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: stats.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.35, // Ensures beautiful proportions for content inside cards
        ),
        itemBuilder: (context, i) => _StatCard(data: stats[i]),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final _StatData data;
  const _StatCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 16,
              offset: const Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(data.icon, color: data.color, size: 20),
          ),
          const Spacer(),
          Text(data.title,
              style: const TextStyle(
                  fontSize: 13, color: AppColors.greyText, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(data.value,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText,
                  letterSpacing: -0.5)),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                data.isUp ? Icons.arrow_upward : Icons.arrow_downward,
                size: 13,
                color: data.isUp ? AppColors.green : AppColors.red,
              ),
              const SizedBox(width: 3),
              Text(
                data.delta,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: data.isUp ? AppColors.green : AppColors.red,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  data.subtitle,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 11, color: AppColors.greyText),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------- GENERIC SPACIOUS SECTION CARD ----------
class _SectionCard extends StatelessWidget {
  final String title;
  final String? actionLabel;
  final Widget child;
  final EdgeInsets padding;

  const _SectionCard({
    required this.title,
    this.actionLabel,
    required this.child,
    this.padding = const EdgeInsets.all(20),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 16,
                offset: const Offset(0, 6)),
          ],
        ),
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: AppColors.darkText)),
                if (actionLabel != null)
                  GestureDetector(
                    onTap: () {},
                    child: Row(
                      children: [
                        Text(actionLabel!,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.blue)),
                        const SizedBox(width: 2),
                        const Icon(Icons.chevron_right,
                            size: 16, color: AppColors.blue),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),
            child,
          ],
        ),
      ),
    );
  }
}

// ---------- WAREHOUSE ANALYTICS ----------
class _WarehouseAnalytics extends StatelessWidget {
  final WarehouseAnalyticsData data;
  const _WarehouseAnalytics({required this.data});

  @override
  Widget build(BuildContext context) {
    // Organised into a spacious 2x2 layout instead of a cramped row of 4 columns
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildItem(
          icon: Icons.home_work_outlined,
          iconBg: AppColors.blue.withOpacity(0.12),
          iconColor: AppColors.blue,
          title: 'Stock Value',
          value: formatLakhs(data.stockValue),
          subtitle: 'Total Stock Value',
        ),
        _buildItem(
          icon: Icons.pie_chart_outline,
          iconBg: AppColors.green.withOpacity(0.12),
          iconColor: AppColors.green,
          title: 'Utilization',
          value: '${data.utilizationPercent.toStringAsFixed(0)}%',
          progress: (data.utilizationPercent / 100).clamp(0.0, 1.0),
          subtitle: 'Warehouse Capacity',
        ),
        _buildItem(
          icon: Icons.inventory_2_outlined,
          iconBg: AppColors.purple.withOpacity(0.12),
          iconColor: AppColors.purple,
          title: 'Total Items',
          value: formatCount(data.totalItems),
          subtitle: 'Products Stored',
        ),
        _buildItem(
          icon: Icons.assignment_outlined,
          iconBg: AppColors.orange.withOpacity(0.12),
          iconColor: AppColors.orange,
          title: 'Avg. Stock Age',
          value: '${data.avgStockAgeDays} Days',
          subtitle: 'Average Catalog Age',
        ),
      ],
    );
  }

  Widget _buildItem({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
    double? progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(title,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 12, color: AppColors.greyText, fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.darkText)),
          const SizedBox(height: 4),
          if (progress != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 4,
                backgroundColor: const Color(0xFFE6E9F0),
                valueColor: const AlwaysStoppedAnimation(AppColors.green),
              ),
            )
          else
            Text(subtitle,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 11, color: AppColors.greyText)),
        ],
      ),
    );
  }
}

// ---------- CATEGORY DISTRIBUTION (PIE) ----------
class _CategoryData {
  final String label;
  final double percent;
  final Color color;
  const _CategoryData(this.label, this.percent, this.color);
}

class _CategoryDistribution extends StatelessWidget {
  final List<CategorySlice> categories;
  final int totalUnits;
  const _CategoryDistribution({required this.categories, required this.totalUnits});

  static const _palette = [
    AppColors.blue,
    AppColors.green,
    AppColors.purple,
    AppColors.orange,
    Color(0xFF9CA3AF),
  ];

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'No stock data yet.',
          style: TextStyle(color: AppColors.greyText, fontSize: 13),
        ),
      );
    }

    final slices = <_CategoryData>[
      for (var i = 0; i < categories.length; i++)
        _CategoryData(
          categories[i].label,
          categories[i].percent,
          _palette[i % _palette.length],
        ),
    ];

    return Row(
      children: [
        SizedBox(
          width: 120,
          height: 120,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                size: const Size(120, 120),
                painter: _DonutPainter(slices),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Total',
                      style: TextStyle(
                          fontSize: 11, color: AppColors.greyText, fontWeight: FontWeight.w500)),
                  Text(formatCount(totalUnits),
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkText)),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(width: 24),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: slices
                .map((c) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                                color: c.color, shape: BoxShape.circle),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(c.label,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.darkText,
                                    fontWeight: FontWeight.w500)),
                          ),
                          Text('${c.percent.toStringAsFixed(0)}%',
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkText)),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  final List<_CategoryData> categories;
  _DonutPainter(this.categories);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    const strokeWidth = 16.0;
    double startAngle = -math.pi / 2;
    for (final c in categories) {
      final sweep = (c.percent / 100) * 2 * math.pi;
      final paint = Paint()
        ..color = c.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round; // Rounded endpoints look elegant
      canvas.drawArc(
        rect.deflate(strokeWidth / 2),
        startAngle,
        sweep,
        false,
        paint,
      );
      startAngle += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// ---------- LOW STOCK ALERTS ----------
class _LowStockAlerts extends StatelessWidget {
  final List<LowStockAlertItem> alerts;
  const _LowStockAlerts({required this.alerts});

  @override
  Widget build(BuildContext context) {
    if (alerts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'Nothing running low right now 🎉',
          style: TextStyle(color: AppColors.greyText, fontSize: 13),
        ),
      );
    }

    // Show top 3 to match the original card's density; "View All" is the
    // affordance for the rest.
    final visible = alerts.take(3).toList();

    return Column(
      children: visible
          .map((a) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.red.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.red.withOpacity(0.1)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.inventory_2_outlined,
                          color: AppColors.darkText, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(a.name,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkText)),
                          const SizedBox(height: 3),
                          RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.greyText),
                              children: [
                                const TextSpan(text: 'Current Stock: '),
                                TextSpan(
                                  text: '${a.stock} Units',
                                  style: const TextStyle(
                                      color: AppColors.red,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.warning_rounded,
                        color: AppColors.red, size: 22),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

// ---------- QUICK ACTIONS ----------
// Static shortcuts — not backend data, left exactly as in the original.
class _QuickAction {
  final IconData icon;
  final String label;
  final Color color;
  const _QuickAction(this.icon, this.label, this.color);
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  static const actions = [
    _QuickAction(Icons.shopping_cart_outlined, 'Add Sale', AppColors.blue),
    _QuickAction(Icons.add_shopping_cart, 'Add Purchase', AppColors.green),
    _QuickAction(Icons.inventory_2_outlined, 'Add Product', AppColors.purple),
    _QuickAction(Icons.person_add_alt_outlined, 'Add Customer', AppColors.orange),
    _QuickAction(Icons.local_shipping_outlined, 'Add Supplier', AppColors.green),
    _QuickAction(Icons.assignment_outlined, 'Stock Adjust', AppColors.blue),
  ];

  @override
  Widget build(BuildContext context) {
    // 3 columns layout with proportional size values prevents labels from wrapping poorly
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.05,
      ),
      itemBuilder: (context, i) {
        final a = actions[i];
        return Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: a.color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(a.icon, color: a.color, size: 22),
              ),
              const SizedBox(height: 8),
              Text(
                a.label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkText),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ---------- RECENT TRANSACTIONS ----------
class _Transaction {
  final String id;
  final String name;
  final String amount;
  final String time;
  const _Transaction(this.id, this.name, this.amount, this.time);
}

class _RecentTransactions extends StatelessWidget {
  final List<RecentTxn> sales;
  final List<RecentTxn> purchases;
  const _RecentTransactions({required this.sales, required this.purchases});

  @override
  Widget build(BuildContext context) {
    final saleItems = sales
        .map((t) => _Transaction(
              t.id,
              t.name,
              formatIndianCurrency(t.amount),
              formatRelativeDateTime(t.date),
            ))
        .toList();
    final purchaseItems = purchases
        .map((t) => _Transaction(
              t.id,
              t.name,
              formatIndianCurrency(t.amount),
              formatRelativeDateTime(t.date),
            ))
        .toList();

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 600;
        final salesCol = _TransactionColumn(
          title: 'Recent Sales',
          icon: Icons.shopping_cart_outlined,
          color: AppColors.blue,
          items: saleItems,
          itemIcon: Icons.shopping_cart_outlined,
          itemIconBg: AppColors.green.withOpacity(0.1),
          itemIconColor: AppColors.green,
        );
        final purchaseCol = _TransactionColumn(
          title: 'Recent Purchases',
          icon: Icons.local_shipping_outlined,
          color: AppColors.darkText,
          items: purchaseItems,
          itemIcon: Icons.local_shipping_outlined,
          itemIconBg: AppColors.blue.withOpacity(0.1),
          itemIconColor: AppColors.blue,
        );
        if (isNarrow) {
          return Column(
            children: [
              salesCol,
              const SizedBox(height: 24),
              purchaseCol,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: salesCol),
            const SizedBox(width: 20),
            Expanded(child: purchaseCol),
          ],
        );
      },
    );
  }
}

class _TransactionColumn extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final List<_Transaction> items;
  final IconData itemIcon;
  final Color itemIconBg;
  final Color itemIconColor;

  const _TransactionColumn({
    required this.title,
    required this.icon,
    required this.color,
    required this.items,
    required this.itemIcon,
    required this.itemIconBg,
    required this.itemIconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF4F7FC),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 8),
              Text(title,
                  style: TextStyle(
                      fontSize: 13, fontWeight: FontWeight.bold, color: color)),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (items.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text('No transactions yet.',
                style: TextStyle(color: AppColors.greyText, fontSize: 12)),
          )
        else
          ...items.map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: itemIconBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(itemIcon, size: 16, color: itemIconColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(t.id,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.darkText)),
                          const SizedBox(height: 2),
                          Text(t.name,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 12, color: AppColors.greyText, fontWeight: FontWeight.w500)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(t.amount,
                            style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                                color: AppColors.darkText)),
                        const SizedBox(height: 2),
                        Text(t.time,
                            style: const TextStyle(
                                fontSize: 11, color: AppColors.green, fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
              )),
      ],
    );
  }
}
