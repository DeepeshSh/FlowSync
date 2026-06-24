import 'package:flutter/material.dart';

import 'categories_screen.dart';
import 'suppliers_screen.dart';
import 'customers_screen.dart';
import 'warehouse_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FC),

      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Container(
                height: 360,

                child: Stack(
                  children: [

                    Positioned(
  left: -70,
  bottom: 80,

  child: Container(
    width: 260,
    height: 120,

    decoration: BoxDecoration(
      color: const Color(0xFFEAF2FF),
      borderRadius: BorderRadius.circular(100),
    ),
  ),
),
                    Positioned(
                      top: 20,
                      left: 20,

                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: const [
                          Text(
                            "More",

                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF0B1245),
                            ),
                          ),

                          SizedBox(height: 4),

                          Text(
                            "Manage your business & app",

                            style: TextStyle(color: Colors.grey, fontSize: 15),
                          ),
                        ],
                      ),
                    ),

                    Positioned(
                      top: 20,
                      right: 20,

                      child: Row(
                        children: [
                          const Icon(
                            Icons.cloud_outlined,
                            color: Color(0xFFDCE8FF),
                            size: 30,
                          ),

                          const SizedBox(width: 12),

                          Container(
                            width: 48,
                            height: 48,

                            decoration: BoxDecoration(
                              color: Colors.white,

                              borderRadius: BorderRadius.circular(14),
                            ),

                            child: const Icon(Icons.notifications_none),
                          ),

                          const SizedBox(width: 10),

                          Container(
                            width: 48,
                            height: 48,

                            decoration: BoxDecoration(
                              color: Colors.white,

                              borderRadius: BorderRadius.circular(14),
                            ),

                            child: const Icon(Icons.settings_outlined),
                          ),
                        ],
                      ),
                    ),

               
                  ],
                ),
              ),

             
             Padding(
  padding: const EdgeInsets.symmetric(horizontal: 20),

  child: Column(
    children: [

      Stack(
        clipBehavior: Clip.none,
   

    children: [

      Transform.translate(
        offset: const Offset(0, -210),

        child: Container(
                        padding: const EdgeInsets.all(24),

                        decoration: BoxDecoration(
                          color: Colors.white,

                          borderRadius: BorderRadius.circular(30),

                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 12),
                          ],
                        ),

                        child: Row(
                          children: [
                            Container(
                              width: 80,
                              height: 80,

                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,

                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF143D7A),
                                    Color(0xFF1E5CB3),
                                  ],
                                ),
                              ),

                              child: const Center(
                                child: Text(
                                  "DS",

                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 18),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  const Text(
                                    "Deepesh Shrivastava",

                                    style: TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 4),

                                  Text(
                                    "FlowSync Traders",

                                    style: TextStyle(
                                      color: Colors.grey.shade700,
                                    ),
                                  ),

                                  const SizedBox(height: 0),

                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),

                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE7F8F4),

                                      borderRadius: BorderRadius.circular(14),
                                    ),

                                    child: const Row(
                                      mainAxisSize: MainAxisSize.min,

                                      children: [
                                        Icon(
                                          Icons.workspace_premium,
                                          size: 16,
                                          color: Color(0xFF0F9D94),
                                        ),

                                        SizedBox(width: 6),

                                        Text(
                                          "Owner",

                                          style: TextStyle(
                                            color: Color(0xFF0F9D94),
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const Icon(Icons.chevron_right),
                          ],
                        ),
                      ),
                    ),

                    Positioned(
  top: -320,
  right: 9,

  child: Image.asset(
    "lib/assets/images/homeimage (2).png",
    height: 125,
  ),
),

Positioned(
                      top: -275,
                      right: 128,

                      child: Image.asset(
                        "lib/assets/images/paper_plane.png",
                        width: 98,
                      ),
                    ),
],
),



                    Transform.translate(
  offset: const Offset(0, -180),

  child: Column(
    children: [

      Align(
        alignment: Alignment.centerLeft,

        child: const Text(
          "Business",

                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0B1245),
                        ),
                      ),
                    ),

                    const SizedBox(height: 6),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius: BorderRadius.circular(24),

                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 10),
                        ],
                      ),

                      child: Column(
                        children: [
                          _menuTile(
                            icon: Icons.category_outlined,
                            title: "Categories",

                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CategoriesScreen(),
                                ),
                              );
                            },
                          ),

                          const Divider(height: 1),

                          _menuTile(
                            icon: Icons.local_shipping_outlined,

                            title: "Suppliers",

                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const SuppliersScreen(),
                                ),
                              );
                            },
                          ),

                          const Divider(height: 1),

                          _menuTile(
                            icon: Icons.people_outline,
                            title: "Customers",

                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CustomersScreen(),
                                ),
                              );
                            },
                          ),

                          const Divider(height: 1),

_menuTile(
  icon: Icons.warehouse_outlined,
  title: "Warehouses",

  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const WarehouseScreen(),
      ),
    );
  },
),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerLeft,

                      child: const Text(
                        "Support",

                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0B1245),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius: BorderRadius.circular(24),

                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 10),
                        ],
                      ),

                      child: Column(
                        children: [
                          _menuTile(
                            icon: Icons.headset_mic_outlined,

                            title: "Help & Support",

                            onTap: () {},
                          ),

                          const Divider(height: 1),

                          _menuTile(
                            icon: Icons.info_outline,

                            title: "About FlowSync",

                            onTap: () {},
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerLeft,

                      child: const Text(
                        "Account",

                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0B1245),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                    Container(
                      padding: EdgeInsets.symmetric(
  horizontal: 20,
  vertical: 24,
),

                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF4F4),

                        borderRadius: BorderRadius.circular(24),
                      ),

                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,

                            decoration: BoxDecoration(
                              color: const Color(0xFFFFE6E6),

                              borderRadius: BorderRadius.circular(14),
                            ),

                            child: const Icon(Icons.logout, color: Colors.red),
                          ),

                          const SizedBox(width: 16),

                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                Text(
                                  "Logout",

                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                SizedBox(height: 4),

                                Text("Sign out from your account"),
                              ],
                            ),
                          ),

                          const Icon(Icons.chevron_right, color: Colors.red),
                        ],
                      ),
                    ),

                    const SizedBox(height: 5),
                    Container(
  height: 45,
  margin: EdgeInsets.zero,

  child: Stack(
    clipBehavior: Clip.none,

    children: [

      

      

      // SOFT GROUND

     Positioned(
  left: 0,
  right: 0,
  bottom: 0,

  child: ClipPath(
    clipper: WaveClipper(),

    child: Container(
      height: 60,
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
          height: 80,
        ),
      ),

      // RIGHT GEARS

      Positioned(
        right: 5,
        bottom: -30,

        child: Image.asset(
          "lib/assets/images/gears-removebg-preview.png",
          height: 150,
        ),
      ),

    ],
  ),
),
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
    );
  }
  



  static Widget _menuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),

      leading: Container(
        width: 44,
        height: 44,

        decoration: BoxDecoration(
          color: const Color(0xFFEAF2FF),

          borderRadius: BorderRadius.circular(12),
        ),

        child: Icon(icon, color: const Color(0xFF2F80FF)),
      ),

      title: Text(
        title,

        style: const TextStyle(
          fontWeight: FontWeight.w600,

          color: Color(0xFF0B1245),
        ),
      ),

      trailing: const Icon(Icons.chevron_right),

      onTap: onTap,
    );
  }
}
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    path.lineTo(0, 25);

    path.quadraticBezierTo(
      size.width * 0.15,
      0,
      size.width * 0.30,
      20,
    );

    path.quadraticBezierTo(
      size.width * 0.45,
      40,
      size.width * 0.60,
      15,
    );

    path.quadraticBezierTo(
      size.width * 0.75,
      -5,
      size.width,
      25,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}