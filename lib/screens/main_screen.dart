import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/app_theme.dart';

// Screen imports
import 'dashboard_screen.dart';
import 'inventory_screen.dart';
import 'purchase_screen.dart';
import 'more_screen.dart';
import 'sales_screen.dart';

export 'dashboard_screen.dart';

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
        scaffoldBackgroundColor: AppColors.scaffoldBackground,
        useMaterial3: true,
      ),
      home: const MainScreen(),
    );
  }
}

// ---------- FORMATTING HELPERS ----------
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

// ---------- MAIN SCREEN (NAVIGATION COORDINATOR) ----------
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;
  DateTime? _lastPressedAt;

  final List<Widget> screens = const [
    DashboardScreen(),
    InventoryScreen(),
    PurchaseScreen(),
    SalesScreen(),
    MoreScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;

        if (selectedIndex != 0) {
          setState(() => selectedIndex = 0);
          return;
        }

        final now = DateTime.now();
        if (_lastPressedAt == null ||
            now.difference(_lastPressedAt!) > const Duration(seconds: 2)) {
          _lastPressedAt = now;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Press back again to exit FlowSync'),
              duration: Duration(seconds: 2),
            ),
          );
        } else {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: IndexedStack(index: selectedIndex, children: screens),
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: BottomNavigationBar(
            currentIndex: selectedIndex,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: AppColors.primary,
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
      ),
    );
  }
}