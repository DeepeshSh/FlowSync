import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'inventory_screen.dart';
import '/screens/purchase_screen.dart';
import 'sales_screen.dart';
import 'more_screen.dart';
// Stub placeholder classes for your custom imports (remove if these already exist in your files)

void main() {
  runApp(const FlowSyncApp());
}

class FlowSyncApp extends StatelessWidget {
  const FlowSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'FlowSync',
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: const Color(
          0xFFF8FAFC,
        ), // Brighter, cleaner backdrop
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;

  late final List<Widget> screens;

  @override
  void initState() {
    super.initState();
    screens = [
      const DashboardContentView(), // Injected your fully overhauled Dashboard screen content here
      const InventoryScreen(),
      const PurchaseScreen(),
      const SalesScreen(),
      const MoreScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF2F80FF),
          unselectedItemColor: Colors.grey[500],
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

// --- CLEANED & RESPONSIVE DASHBOARD LAYOUT CONTENT ---
class DashboardContentView extends StatelessWidget {
  const DashboardContentView({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTopMetricsGrid(),
                  const SizedBox(height: 28),
                  _buildSectionHeader(
                    "Warehouse Analytics",
                    showViewDetails: true,
                  ),
                  const SizedBox(height: 14),
                  _buildWarehouseAnalyticsGrid(),
                  const SizedBox(height: 28),
                  _buildDistributionAndAlertsSplit(),
                  const SizedBox(height: 28),
                  _buildSectionHeader("Quick Actions"),
                  const SizedBox(height: 14),
                  _buildQuickActionsGrid(),
                  const SizedBox(height: 28),
                  _buildSectionHeader("Recent Transactions", showViewAll: true),
                  const SizedBox(height: 14),
                  _buildRecentTransactionsSection(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE8F1FF), Color(0xFFF8FAFC)],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(Icons.menu, color: Colors.black87),
                onPressed: () {},
              ),
              const Text(
                'FlowSync',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2F80FF),
                ),
              ),
              Badge(
                label: const Text('3'),
                backgroundColor: Colors.red,
                child: IconButton(
                  icon: const Icon(
                    Icons.notifications_none_outlined,
                    color: Colors.black87,
                  ),
                  onPressed: () {},
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'Good Morning, Deepesh',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text('👋', style: TextStyle(fontSize: 20)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Raj Sanitary & Hardware',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTopMetricsGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.35, // Added padding depth inside boxes
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      children: [
        _buildMetricCard(
          "Today's Sales",
          "₹ 52,420",
          "+ 15.6%",
          "vs yesterday",
          Colors.blue,
          Icons.trending_up,
        ),
        _buildMetricCard(
          "Today's Purchases",
          "₹ 28,750",
          "+ 12.4%",
          "vs yesterday",
          Colors.green,
          Icons.shopping_cart_outlined,
        ),
        _buildMetricCard(
          "Today's Orders",
          "23",
          "+ 8.3%",
          "vs yesterday",
          Colors.orange,
          Icons.description_outlined,
        ),
        _buildMetricCard(
          "Pending Payments",
          "₹ 1,42,680",
          "- 6.7%",
          "from last week",
          Colors.red,
          Icons.account_balance_wallet_outlined,
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    String percentage,
    String label,
    Color color,
    IconData icon,
  ) {
    bool isPositive = !percentage.contains('-');
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 18),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              letterSpacing: -0.5,
            ),
          ),
          Row(
            children: [
              Icon(
                isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                size: 13,
                color: isPositive ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 2),
              Text(
                percentage,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isPositive ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey[500],
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWarehouseAnalyticsGrid() {
    return GridView.count(
      crossAxisCount:
          2, // Cut grid into 2x2 profile so labels can be perfectly read without truncation
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.6,
      crossAxisSpacing: 14,
      mainAxisSpacing: 14,
      children: [
        _buildWarehouseItem(
          "Stock Value",
          "₹ 18.6L",
          "Total Stock Value",
          Icons.home_outlined,
          Colors.blue,
        ),
        _buildWarehouseItemCircle(
          "Utilization",
          "72%",
          "Warehouse Capacity",
          Colors.green,
        ),
        _buildWarehouseItem(
          "Total Items",
          "1,245",
          "Products Stored",
          Icons.layers_outlined,
          Colors.purple,
        ),
        _buildWarehouseItem(
          "Avg. Stock Age",
          "45 Days",
          "Average across catalog",
          Icons.assignment_outlined,
          Colors.orange,
        ),
      ],
    );
  }

  Widget _buildWarehouseItem(
    String title,
    String val,
    String sub,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 6),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  val,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[400],
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarehouseItemCircle(
    String title,
    String val,
    String sub,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 6),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            height: 32,
            width: 32,
            child: CircularProgressIndicator(
              value: 0.72,
              strokeWidth: 4,
              backgroundColor: Colors.grey[100],
              color: color,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  val,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sub,
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.grey[400],
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDistributionAndAlertsSplit() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader(
                "Category Distribution",
                showViewDetails: true,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  SizedBox(
                    width: 90,
                    height: 90,
                    child: Stack(
                      children: [
                        PieChart(
                          PieChartData(
                            sectionsSpace: 2,
                            centerSpaceRadius: 30,
                            sections: [
                              PieChartSectionData(
                                color: Colors.blue,
                                value: 35,
                                radius: 14,
                                showTitle: false,
                              ),
                              PieChartSectionData(
                                color: Colors.teal,
                                value: 25,
                                radius: 14,
                                showTitle: false,
                              ),
                              PieChartSectionData(
                                color: Colors.purple,
                                value: 20,
                                radius: 14,
                                showTitle: false,
                              ),
                              PieChartSectionData(
                                color: Colors.orange,
                                value: 10,
                                radius: 14,
                                showTitle: false,
                              ),
                              PieChartSectionData(
                                color: Colors.grey,
                                value: 10,
                                radius: 14,
                                showTitle: false,
                              ),
                            ],
                          ),
                        ),
                        const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Total",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                              Text(
                                "1,245",
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      children: [
                        _buildLegendItem(
                          "Pipes & Fittings",
                          "35%",
                          Colors.blue,
                        ),
                        _buildLegendItem("Sanitaryware", "25%", Colors.teal),
                        _buildLegendItem("Hardware", "20%", Colors.purple),
                        _buildLegendItem(
                          "Bath Accessories",
                          "10%",
                          Colors.orange,
                        ),
                        _buildLegendItem("Others", "10%", Colors.grey),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionHeader("Low Stock Alerts", showViewAll: true),
              const SizedBox(height: 14),
              _buildAlertItem("PVC Pipe 4\"", "1 Units"),
              _buildAlertItem("Wash Basin White", "2 Units"),
              _buildAlertItem("Bib Cock Long Body", "4 Units"),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem(String label, String percent, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
          Text(
            percent,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem(String title, String count) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.red[50]?.withOpacity(0.6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Icon(
              Icons.image_not_supported_outlined,
              size: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "Stock Remaining: $count",
                  style: const TextStyle(fontSize: 11, color: Colors.red),
                ),
              ],
            ),
          ),
          const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 18),
        ],
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    return GridView.count(
      crossAxisCount:
          3, // Changed from 6 columns to 3 columns to stop cramped text icons
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        _buildActionItem("Add Sale", Icons.add_shopping_cart, Colors.blue),
        _buildActionItem(
          "Add Purchase",
          Icons.shopping_bag_outlined,
          Colors.green,
        ),
        _buildActionItem(
          "Add Product",
          Icons.all_inbox_outlined,
          Colors.purple,
        ),
        _buildActionItem("Add Customer", Icons.person_add_alt, Colors.orange),
        _buildActionItem(
          "Add Supplier",
          Icons.local_shipping_outlined,
          Colors.teal,
        ),
        _buildActionItem("Stock Adjust", Icons.tune, Colors.blueGrey),
      ],
    );
  }

  Widget _buildActionItem(String label, IconData icon, Color color) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 4),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentTransactionsSection() {
    return Column(
      children: [
        _buildTransactionBlock(
          "Recent Sales",
          Icons.shopping_cart,
          Colors.blue,
          [
            _buildTransactionItem(
              "S-INV-1025",
              "Rakesh Hardware",
              "₹ 8,450",
              "Today, 10:30 AM",
              Colors.green,
            ),
            _buildTransactionItem(
              "S-INV-1024",
              "Shri Ram Traders",
              "₹ 5,210",
              "Today, 09:15 AM",
              Colors.green,
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildTransactionBlock(
          "Recent Purchases",
          Icons.assignment_turned_in_outlined,
          Colors.blueGrey,
          [
            _buildTransactionItem(
              "P-INV-0542",
              "ABC Sanitary Traders",
              "₹ 12,450",
              "Today, 11:20 AM",
              Colors.blue,
            ),
            _buildTransactionItem(
              "P-INV-0541",
              "Khandelwal Hardware",
              "₹ 9,800",
              "Today, 10:05 AM",
              Colors.blue,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTransactionBlock(
    String title,
    IconData headerIcon,
    Color headerColor,
    List<Widget> items,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(headerIcon, size: 16, color: headerColor),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  color: headerColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Divider(height: 1),
          ),
          const SizedBox(height: 8),
          ...items,
        ],
      ),
    );
  }

  Widget _buildTransactionItem(
    String inv,
    String name,
    String amount,
    String time,
    Color iconColor,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(Icons.arrow_circle_right_outlined, color: iconColor, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      inv,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      amount,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    String title, {
    bool showViewDetails = false,
    bool showViewAll = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        if (showViewDetails)
          Text(
            'View Details ›',
            style: TextStyle(
              fontSize: 13,
              color: Colors.blue[700],
              fontWeight: FontWeight.bold,
            ),
          )
        else if (showViewAll)
          Text(
            'View All',
            style: TextStyle(
              fontSize: 13,
              color: Colors.blue[700],
              fontWeight: FontWeight.bold,
            ),
          ),
      ],
    );
  }
}
