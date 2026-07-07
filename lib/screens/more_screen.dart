import 'package:flutter/material.dart';

import 'categories_screen.dart';
import 'suppliers_screen.dart';
import 'customers_screen.dart';
import 'warehouse_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const Color textPrimary = Color(0xFF0F172A);
    const Color textMuted = Color(0xFF64748B);
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Theme Continuous Flow Background Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFE2EAF2),
                    Color(0xFFF1F5F9),
                    Colors.white,
                  ],
                  stops: [0.0, 0.35, 0.7],
                ),
              ),
            ),
          ),

          // 2. Main Scrollable View Area
          Positioned.fill(
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(), // Clamps scrolling boundary edge-to-edge
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Unified App Header Row with Manual Status Bar Padding
                  Container(
                    width: double.infinity,
                    height: 110 + statusBarHeight,
                    padding: EdgeInsets.only(top: statusBarHeight),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Left: Back button + Text Column
                        Positioned(
                          left: 20,
                          bottom: 4, // Aligned lower to sit closer to the profile card
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.maybePop(context),
                                child: const Padding(
                                  padding: EdgeInsets.all(4.0),
                                  child: Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    color: textPrimary,
                                    size: 20,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    "More",
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                      color: textPrimary,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    "Manage your business & app",
                                    style: TextStyle(
                                      color: textMuted,
                                      fontSize: 12.5,
                                      height: 1.3,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // Right: Enlarged Assets resting directly down onto the profile card
                        Positioned(
                          right: 16,
                          bottom: 0,
                          child: SizedBox(
                            width: 150,
                            height: 110,
                            child: Stack(
                              alignment: Alignment.center,
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  right: 0,
                                  top: 15,
                                  child: Container(
                                    width: 120,
                                    height: 90,
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
                                Positioned(
                                  bottom: -10, // Rest perfectly on the top of the card layer
                                  right: -5,
                                  child: Image.asset(
                                    "lib/assets/images/homeimage (2).png",
                                    width: 165, // Increased size
                                    height: 135,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => const SizedBox(),
                                  ),
                                ),
                                Positioned(
                                  bottom: 35,
                                  right: 90,
                                  child: Image.asset(
                                    "lib/assets/images/paper_plane.png",
                                    width: 58, // Increased size
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => const SizedBox(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10), // Decreased distance down to the card layout

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      children: [
                        // Profile Information Card Segment
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.02),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 68,
                                height: 68,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF3B82F6),
                                      Color(0xFF1D4ED8),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: const Center(
                                  child: Text(
                                    "DS",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      "Deepesh Shrivastava",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    const Text(
                                      "FlowSync Traders",
                                      style: TextStyle(
                                        color: textMuted,
                                        fontSize: 13,
                                      ),
                                    ),
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFECFDF5),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: const [
                                          Icon(
                                            Icons.workspace_premium_rounded,
                                            size: 14,
                                            color: Color(0xFF10B981),
                                          ),
                                          SizedBox(width: 4),
                                          Text(
                                            "Owner",
                                            style: TextStyle(
                                              color: Color(0xFF047857),
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded, color: textMuted),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // --- Business Menu Area ---
                        Align(
                          alignment: Alignment.centerLeft,
                          child: const Padding(
                            padding: EdgeInsets.only(left: 4, bottom: 10),
                            child: Text(
                              "Business",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.01),
                                blurRadius: 8,
                              )
                            ],
                          ),
                          child: Column(
                            children: [
                              _menuTile(
                                icon: Icons.category_outlined,
                                title: "Categories",
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CategoriesScreen())),
                              ),
                              const Divider(height: 1, indent: 60, color: Color(0xFFF1F5F9)),
                              _menuTile(
                                icon: Icons.local_shipping_outlined,
                                title: "Suppliers",
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SuppliersScreen())),
                              ),
                              const Divider(height: 1, indent: 60, color: Color(0xFFF1F5F9)),
                              _menuTile(
                                icon: Icons.people_outline_rounded,
                                title: "Customers",
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CustomersScreen())),
                              ),
                              const Divider(height: 1, indent: 60, color: Color(0xFFF1F5F9)),
                              _menuTile(
                                icon: Icons.warehouse_outlined,
                                title: "Warehouses",
                                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WarehouseScreen())),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // --- Support Menu Area ---
                        Align(
                          alignment: Alignment.centerLeft,
                          child: const Padding(
                            padding: EdgeInsets.only(left: 4, bottom: 10),
                            child: Text(
                              "Support",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: textPrimary,
                              ),
                            ),
                          ),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.01),
                                blurRadius: 8,
                              )
                            ],
                          ),
                          child: Column(
                            children: [
                              _menuTile(
                                icon: Icons.headset_mic_outlined,
                                title: "Help & Support",
                                onTap: () {},
                              ),
                              const Divider(height: 1, indent: 60, color: Color(0xFFF1F5F9)),
                              _menuTile(
                                icon: Icons.info_outline_rounded,
                                title: "About FlowSync",
                                onTap: () {},
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // --- Logout Tile Action ---
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: const Color(0xFFFEE2E2)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFEE2E2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 20),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: const [
                                    Text(
                                      "Logout",
                                      style: TextStyle(
                                        color: Color(0xFF991B1B),
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    SizedBox(height: 2),
                                    Text(
                                      "Sign out from your account safely",
                                      style: TextStyle(color: Color(0xFFEF4444), fontSize: 12),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.chevron_right_rounded, color: Color(0xFF991B1B)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // WAVEY FOOTER: Positioned at the very end of the scroll container spanning edge-to-edge
                  SizedBox(
                    height: 75,
                    width: double.infinity,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: ClipPath(
                            clipper: WaveClipper(),
                            child: Container(
                              height: 55,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFDFF8EF),
                                    Color(0xFFEAF7F3),
                                    Color(0xFFD6F3EA),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: -5,
                          bottom: 0,
                          child: Image.asset(
                            "lib/assets/images/grass-removebg-preview.png",
                            height: 65,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const SizedBox(),
                          ),
                        ),
                        Positioned(
                          right: 5,
                          bottom: -15,
                          child: Image.asset(
                            "lib/assets/images/gears-removebg-preview.png",
                            height: 95,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const SizedBox(),
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
    );
  }

  static Widget _menuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFEFF6FF),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: const Color(0xFF3B82F6), size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14.5,
          color: Color(0xFF1E293B),
        ),
      ),
      trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFF94A3B8), size: 20),
      onTap: onTap,
    );
  }
}

class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, 20);
    path.quadraticBezierTo(size.width * 0.15, 0, size.width * 0.30, 15);
    path.quadraticBezierTo(size.width * 0.45, 30, size.width * 0.60, 10);
    path.quadraticBezierTo(size.width * 0.75, -5, size.width, 20);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}