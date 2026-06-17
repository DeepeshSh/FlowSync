import 'package:flutter/material.dart';
import 'inventory_screen.dart';
import 'purchase_screen.dart';
import 'more_screen.dart';
import 'sales_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int selectedIndex = 0;

 final List<Widget> screens = const [

  Center(
    child: Text(
      "Home Screen",
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    ),
  ),

  InventoryScreen(),

  PurchaseScreen(),

  SalesScreen(),

  MoreScreen(),
];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[selectedIndex],

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,

        type: BottomNavigationBarType.fixed,

        selectedItemColor: const Color(0xFF2F80FF),

        unselectedItemColor: Colors.grey,

        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
        },

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
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
            icon: Icon(Icons.menu),
            label: "Sell",
          ),

          BottomNavigationBarItem(
    icon: Icon(Icons.more_horiz),
    label: "More",
  ),
        ],
      ),
    );
  }
}