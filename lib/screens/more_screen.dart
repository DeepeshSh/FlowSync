import 'package:flutter/material.dart';

import 'categories_screen.dart';
import 'suppliers_screen.dart';
import 'customers_screen.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FC),

      appBar: AppBar(
        title: const Text("More"),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),

        child: Column(
          children: [

            // PROFILE CARD

            Container(
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius:
                    BorderRadius.circular(20),

                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                  ),
                ],
              ),

              child: Row(
                children: [

                  const CircleAvatar(
                    radius: 35,

                    backgroundColor:
                        Color(0xFF2F80FF),

                    child: Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 35,
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,

                      children: const [

                        Text(
                          "Deepesh Shrivastava",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        SizedBox(height: 4),

                        Text(
                          "FlowSync Traders",
                          style: TextStyle(
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),

                  IconButton(
                    onPressed: () {},

                    icon: const Icon(
                      Icons.edit,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // BUSINESS SECTION

            _sectionTitle("Business"),

            _menuTile(
  icon: Icons.category,
  title: "Categories",
  onTap: () {

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const CategoriesScreen(),
      ),
    );
  },
),

            _menuTile(
  icon: Icons.local_shipping,
  title: "Suppliers",
  onTap: () {

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const SuppliersScreen(),
      ),
    );
  },
),

            _menuTile(
  icon: Icons.people,
  title: "Customers",
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const CustomersScreen(),
      ),
    );
  },
),

            const SizedBox(height: 20),

            // SETTINGS SECTION

            _sectionTitle("Settings"),

            _menuTile(
              icon: Icons.business,
              title: "Business Settings",
              onTap: () {},
            ),

            _menuTile(
              icon: Icons.notifications,
              title: "Notifications",
              onTap: () {},
            ),

            _menuTile(
              icon: Icons.backup,
              title: "Backup & Restore",
              onTap: () {},
            ),

            const SizedBox(height: 20),

            // SUPPORT SECTION

            _sectionTitle("Support"),

            _menuTile(
              icon: Icons.help_outline,
              title: "Help & Support",
              onTap: () {},
            ),

            _menuTile(
              icon: Icons.info_outline,
              title: "About FlowSync",
              onTap: () {},
            ),

            const SizedBox(height: 20),

            // ACCOUNT SECTION

            _sectionTitle("Account"),

            _menuTile(
              icon: Icons.lock_outline,
              title: "Change Password",
              onTap: () {},
            ),

            _menuTile(
              icon: Icons.logout,
              title: "Logout",
              onTap: () {},
              isLogout: true,
            ),
          ],
        ),
      ),
    );
  }

  static Widget _sectionTitle(
    String title,
  ) {
    return Padding(
      padding:
          const EdgeInsets.only(
        bottom: 10,
      ),

      child: Align(
        alignment:
            Alignment.centerLeft,

        child: Text(
          title,

          style: const TextStyle(
            fontSize: 18,
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),
    );
  }

  static Widget _menuTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return Card(
      elevation: 0,

      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(
          15,
        ),
      ),

      child: ListTile(
        leading: Icon(
          icon,
          color: isLogout
              ? Colors.red
              : const Color(
                  0xFF2F80FF,
                ),
        ),

        title: Text(
          title,
          style: TextStyle(
            color: isLogout
                ? Colors.red
                : Colors.black,
          ),
        ),

        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
        ),

        onTap: onTap,
      ),
    );
  }
}