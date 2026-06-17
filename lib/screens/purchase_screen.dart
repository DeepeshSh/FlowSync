import 'package:flutter/material.dart';

import '../models/purchase_model.dart';
import '../services/purchase_service.dart';

import 'add_purchase_screen.dart';

class PurchaseScreen extends StatefulWidget {
  const PurchaseScreen({super.key});

  @override
  State<PurchaseScreen> createState() => _PurchaseScreenState();
}

class _PurchaseScreenState extends State<PurchaseScreen> {
  List<Purchase> purchases = [];

  List<Purchase> filteredPurchases = [];

  bool isLoading = true;

  final searchController = TextEditingController();

  String selectedSupplier = "All Suppliers";

  DateTimeRange? selectedDateRange;

  @override
  void initState() {
    super.initState();

    loadPurchases();
  }

  Future<void> loadPurchases() async {
    try {
      purchases = await PurchaseService().getPurchases();

      filteredPurchases = purchases;

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> refreshPurchases() async {
    purchases = await PurchaseService().getPurchases();

    filterPurchases();

    setState(() {});
  }

  void filterPurchases() {
    List<Purchase> temp = List.from(purchases);

    // Search

    if (searchController.text.isNotEmpty) {
      temp = temp.where((purchase) {
        return purchase.supplierName.toLowerCase().contains(
              searchController.text.toLowerCase(),
            ) ||
            purchase.purchaseNumber.toLowerCase().contains(
              searchController.text.toLowerCase(),
            );
      }).toList();
    }

    // Supplier Filter

    if (selectedSupplier != "All Suppliers") {
      temp = temp.where((purchase) {
        return purchase.supplierName == selectedSupplier;
      }).toList();
    }

    // Date Filter

    if (selectedDateRange != null) {
      temp = temp.where((purchase) {
        return purchase.purchaseDate.isAfter(
              selectedDateRange!.start.subtract(const Duration(days: 1)),
            ) &&
            purchase.purchaseDate.isBefore(
              selectedDateRange!.end.add(const Duration(days: 1)),
            );
      }).toList();
    }

    setState(() {
      filteredPurchases = temp;
    });
  }

  List<String> get suppliers {
    final list = purchases
        .map((purchase) => purchase.supplierName)
        .toSet()
        .toList();

    list.sort();

    return ["All Suppliers", ...list];
  }

  int get totalPurchases => purchases.length;

  double get monthlyPurchaseValue {
    return purchases.fold(0, (sum, purchase) => sum + purchase.totalAmount);
  }

  double get pendingPayments {
    return purchases
        .where((purchase) => purchase.paymentStatus == "Pending")
        .fold(0, (sum, purchase) => sum + purchase.totalAmount);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FC),

      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 12),

            // HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),

              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  // MENU BUTTON
                  

                  const SizedBox(width: 16),

                  // TITLE
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: const [
                        Text(
                          "Purchases",

                          style: TextStyle(
                            fontSize: 28,

                            fontWeight: FontWeight.bold,

                            color: Color(0xFF1B2559),
                          ),
                        ),

                        SizedBox(height: 4),

                        Text(
                          "Manage all your purchase orders",

                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),

                  // NOTIFICATION
                  Stack(
                    children: [
                      Container(
                        width: 50,
                        height: 50,

                        decoration: BoxDecoration(
                          color: Colors.white,

                          borderRadius: BorderRadius.circular(16),

                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 10),
                          ],
                        ),

                        child: const Icon(
                          Icons.notifications_none,

                          size: 24,

                          color: Color(0xFF1B2559),
                        ),
                      ),

                      Positioned(
                        right: 2,
                        top: 2,

                        child: Container(
                          width: 22,
                          height: 22,

                          decoration: const BoxDecoration(
                            color: Colors.red,

                            shape: BoxShape.circle,
                          ),

                          child: const Center(
                            child: Text(
                              "3",

                              style: TextStyle(
                                color: Colors.white,

                                fontSize: 11,

                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(width: 12),

                  // PROFILE
                  Container(
                    width: 50,
                    height: 50,

                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF2FF),

                      borderRadius: BorderRadius.circular(16),
                    ),

                    child: const Icon(
                      Icons.person,

                      size: 24,

                      color: Color(0xFF2F80FF),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),

            // STATISTICS SECTION
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),

              child: Row(
                children: [
                  Expanded(
                    child: _buildStatsCard(
                      title: "Purchases",

                      value: totalPurchases.toString(),

                      icon: Icons.shopping_cart,

                      iconColor: const Color(0xFF2F80FF),

                      backgroundColor: const Color(0xFFEAF2FF),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: _buildStatsCard(
                      title: "This Month",

                      value: "₹${monthlyPurchaseValue.toStringAsFixed(0)}",

                      icon: Icons.currency_rupee,

                      iconColor: Colors.green,

                      backgroundColor: const Color(0xFFE9F8EE),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),

              child: Container(
                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(24),

                  boxShadow: const [
                    BoxShadow(color: Colors.black12, blurRadius: 10),
                  ],
                ),

                child: Row(
                  children: [
                    Container(
                      width: 58,
                      height: 58,

                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF4E8),

                        borderRadius: BorderRadius.circular(16),
                      ),

                      child: const Icon(
                        Icons.account_balance_wallet,

                        color: Colors.orange,

                        size: 28,
                      ),
                    ),

                    const SizedBox(width: 16),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            "₹${pendingPayments.toStringAsFixed(0)}",

                            style: const TextStyle(
                              fontSize: 22,

                              fontWeight: FontWeight.bold,

                              color: Color(0xFF1B2559),
                            ),
                          ),

                          const SizedBox(height: 4),

                          const Text(
                            "Pending Payments",

                            style: TextStyle(color: Colors.grey, fontSize: 14),
                          ),
                        ],
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),

                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,

                        borderRadius: BorderRadius.circular(20),
                      ),

                      child: const Text(
                        "Due",

                        style: TextStyle(
                          color: Colors.orange,

                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // SEARCH + FILTER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),

              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 56,

                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius: BorderRadius.circular(18),

                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 8),
                        ],
                      ),

                      child: TextField(
                        controller: searchController,

                        onChanged: (value) {
                          filterPurchases();
                        },

                        decoration: const InputDecoration(
                          hintText: "Search purchases...",

                          prefixIcon: Icon(Icons.search),

                          border: InputBorder.none,

                          contentPadding: EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Container(
                    width: 56,
                    height: 56,

                    decoration: BoxDecoration(
                      color: const Color(0xFF2F80FF),

                      borderRadius: BorderRadius.circular(18),
                    ),

                    child: IconButton(
                      onPressed: () {},

                      icon: const Icon(Icons.tune, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 18),

            // DATE + SUPPLIER FILTERS
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),

              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final result = await showDateRangePicker(
                          context: context,

                          firstDate: DateTime(2020),

                          lastDate: DateTime(2100),
                        );

                        if (result != null) {
                          selectedDateRange = result;

                          filterPurchases();
                        }
                      },

                      child: Container(
                        height: 52,

                        padding: const EdgeInsets.symmetric(horizontal: 14),

                        decoration: BoxDecoration(
                          color: Colors.white,

                          borderRadius: BorderRadius.circular(16),

                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 8),
                          ],
                        ),

                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_month,

                              color: Color(0xFF2F80FF),
                            ),

                            const SizedBox(width: 8),

                            Expanded(
                              child: Text(
                                selectedDateRange == null
                                    ? "Date Range"
                                    : "${selectedDateRange!.start.day}/${selectedDateRange!.start.month} - ${selectedDateRange!.end.day}/${selectedDateRange!.end.month}",

                                overflow: TextOverflow.ellipsis,

                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Container(
                      height: 52,

                      padding: const EdgeInsets.symmetric(horizontal: 12),

                      decoration: BoxDecoration(
                        color: Colors.white,

                        borderRadius: BorderRadius.circular(16),

                        boxShadow: const [
                          BoxShadow(color: Colors.black12, blurRadius: 8),
                        ],
                      ),

                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedSupplier,

                          isExpanded: true,

                          items: suppliers.map((supplier) {
                            return DropdownMenuItem(
                              value: supplier,

                              child: Text(supplier),
                            );
                          }).toList(),

                          onChanged: (value) {
                            if (value == null) {
                              return;
                            }

                            selectedSupplier = value;

                            filterPurchases();
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // PURCHASE LIST HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),

              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,

                children: const [
                  Text(
                    "Recent Purchases",

                    style: TextStyle(
                      fontSize: 20,

                      fontWeight: FontWeight.bold,

                      color: Color(0xFF1B2559),
                    ),
                  ),

                  Text(
                    "View All",

                    style: TextStyle(
                      color: Color(0xFF2F80FF),

                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Expanded(
              child: filteredPurchases.isEmpty
                  ? const Center(child: Text("No Purchases Found"))
                  : ListView.builder(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        bottom: 120,
                      ),

                      itemCount: filteredPurchases.length,

                      itemBuilder: (context, index) {
                        final purchase = filteredPurchases[index];
                        final bool isPaid = purchase.paymentStatus == "Paid";

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),

                          padding: const EdgeInsets.all(18),

                          decoration: BoxDecoration(
                            color: Colors.white,

                            borderRadius: BorderRadius.circular(24),

                            boxShadow: const [
                              BoxShadow(
                                color: Colors.black12,

                                blurRadius: 12,

                                offset: Offset(0, 4),
                              ),
                            ],
                          ),

                          child: Column(
                            children: [
                              // TOP ROW
                              Row(
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,

                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEAF2FF),

                                      borderRadius: BorderRadius.circular(16),
                                    ),

                                    child: Center(
                                      child: Text(
                                        purchase.supplierName.isNotEmpty
                                            ? purchase.supplierName[0]
                                                  .toUpperCase()
                                            : "S",

                                        style: const TextStyle(
                                          fontSize: 24,

                                          fontWeight: FontWeight.bold,

                                          color: Color(0xFF2F80FF),
                                        ),
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 14),

                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,

                                      children: [
                                        Text(
                                          purchase.supplierName,

                                          style: const TextStyle(
                                            fontSize: 17,

                                            fontWeight: FontWeight.bold,

                                            color: Color(0xFF1B2559),
                                          ),
                                        ),

                                        const SizedBox(height: 4),

                                        Text(
                                          purchase.purchaseNumber,

                                          style: const TextStyle(
                                            color: Colors.grey,

                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,

                                      vertical: 6,
                                    ),

                                    decoration: BoxDecoration(
                                      color: isPaid
                                          ? Colors.green.shade50
                                          : Colors.orange.shade50,

                                      borderRadius: BorderRadius.circular(20),
                                    ),

                                    child: Text(
                                      purchase.paymentStatus,

                                      style: TextStyle(
                                        color: isPaid
                                            ? Colors.green
                                            : Colors.orange,

                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  const SizedBox(width: 8),

                                  const Icon(
                                    Icons.more_vert,

                                    color: Colors.grey,
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              const Divider(),

                              const SizedBox(height: 12),

                              // DETAILS
                              Row(
                                children: [
                                  Expanded(
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),

                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEAF2FF),

                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),

                                          child: const Icon(
                                            Icons.inventory_2_outlined,

                                            size: 18,

                                            color: Color(0xFF2F80FF),
                                          ),
                                        ),

                                        const SizedBox(width: 10),

                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,

                                          children: [
                                            Text(
                                              "${purchase.items.length}",

                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),

                                            const Text(
                                              "Items",

                                              style: TextStyle(
                                                color: Colors.grey,

                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  Expanded(
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),

                                          decoration: BoxDecoration(
                                            color: const Color(0xFFE9F8EE),

                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),

                                          child: const Icon(
                                            Icons.currency_rupee,

                                            size: 18,

                                            color: Colors.green,
                                          ),
                                        ),

                                        const SizedBox(width: 10),

                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,

                                          children: [
                                            Text(
                                              "₹${purchase.totalAmount.toStringAsFixed(0)}",

                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),

                                            const Text(
                                              "Amount",

                                              style: TextStyle(
                                                color: Colors.grey,

                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 16),

                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_month,

                                    size: 18,

                                    color: Colors.grey,
                                  ),

                                  const SizedBox(width: 6),

                                  Text(
                                    "${purchase.purchaseDate.day}/${purchase.purchaseDate.month}/${purchase.purchaseDate.year}",

                                    style: const TextStyle(color: Colors.grey),
                                  ),

                                  const Spacer(),

                                  const Icon(
                                    Icons.arrow_forward_ios,

                                    size: 16,

                                    color: Color(0xFF2F80FF),
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
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,

            MaterialPageRoute(builder: (_) => const AddPurchaseScreen()),
          );

          await refreshPurchases();
        },

        backgroundColor: const Color(0xFF2F80FF),

        icon: const Icon(Icons.add, color: Colors.white),

        label: const Text(
          "New Purchase",

          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildStatsCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color backgroundColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(24),

        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Container(
            width: 48,
            height: 48,

            decoration: BoxDecoration(
              color: backgroundColor,

              borderRadius: BorderRadius.circular(14),
            ),

            child: Icon(icon, color: iconColor, size: 24),
          ),

          const SizedBox(height: 18),

          Text(
            value,

            maxLines: 1,

            overflow: TextOverflow.ellipsis,

            style: const TextStyle(
              fontSize: 20,

              fontWeight: FontWeight.bold,

              color: Color(0xFF1B2559),
            ),
          ),

          const SizedBox(height: 6),

          Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        ],
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();

    super.dispose();
  }
}
