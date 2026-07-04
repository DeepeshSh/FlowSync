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
  
  String selectedTab = "All"; 
  final List<String> filterTabs = ["All", "Pending", "Paid"];

  @override
  void initState() {
    super.initState();
    loadPurchases();
  }

  Future<void> loadPurchases() async {
    try {
      final data = await PurchaseService().getPurchases();
      if (!mounted) return;
      
      setState(() {
        purchases = data;
        filteredPurchases = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> refreshPurchases() async {
    try {
      final data = await PurchaseService().getPurchases();
      purchases = data;
      filterPurchases();
    } catch (_) {}
  }

  void filterPurchases() {
    List<Purchase> temp = List.from(purchases);

    if (searchController.text.isNotEmpty) {
      temp = temp.where((purchase) {
        final supplier = purchase.supplierName;
        final poNumber = purchase.purchaseNumber;
        return supplier.toLowerCase().contains(searchController.text.toLowerCase()) ||
            poNumber.toLowerCase().contains(searchController.text.toLowerCase());
      }).toList();
    }

    if (selectedTab != "All") {
      temp = temp.where((purchase) {
        final status = purchase.paymentStatus;
        return status.toLowerCase() == selectedTab.toLowerCase();
      }).toList();
    }

    if (!mounted) return;
    setState(() {
      filteredPurchases = temp;
    });
  }

  int get totalPurchases => purchases.length;

  double get totalStockValue {
    return purchases.fold(0.0, (sum, purchase) => sum + purchase.totalAmount);
  }

  int get pendingCount {
    return purchases.where((purchase) => purchase.paymentStatus.toLowerCase() == "pending").length;
  }

  int get uniqueSuppliersCount {
    return purchases.map((p) => p.supplierName).toSet().length;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF8FAFC),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2F6BFA)),
          ),
        ),
      );
    }

    const Color bgScaffold = Color(0xFFF8FAFC);
    const Color textPrimary = Color(0xFF0F172A);
    const Color textMuted = Color(0xFF64748B);
    const Color brandBlue = Color(0xFF2F6BFA);

    return Scaffold(
      backgroundColor: bgScaffold,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              
              // ================= HEADER SECTION WITH TOP-RIGHT ILLUSTRATION (Matches image_771d5f.png) =================
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Purchases",
                            style: TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                              color: textPrimary,
                              letterSpacing: -0.5,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            "Track purchases &\nsupplier payments",
                            style: TextStyle(
                              fontSize: 14,
                              color: textMuted,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Header Image container positioned on the right
                    Container(
                      height: 200,
                      width: 240,
                      margin: const EdgeInsets.only(top: 4),
                      child: Image.asset(
                        'lib/assets/images/purchase_screen_header.png',
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                      ),
                    ),
                  ],
                ),
              ),

              // ================= 2x2 COMPACT GRID INFO BOXES =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  childAspectRatio: 1.8, 
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    _buildGridStatsCard(
                      value: totalPurchases.toString(),
                      label: "Total Orders",
                      icon: Icons.receipt_long_outlined,
                      iconBg: const Color(0xFFEEF2FF),
                      iconColor: brandBlue,
                    ),
                    _buildGridStatsCard(
                      value: "₹${(totalStockValue / 100000).toStringAsFixed(1)}L",
                      label: "Total Outflow",
                      icon: Icons.currency_rupee_rounded,
                      iconBg: const Color(0xFFECFDF5),
                      iconColor: const Color(0xFF10B981),
                    ),
                    _buildGridStatsCard(
                      value: pendingCount.toString(),
                      label: "Pending Bills",
                      icon: Icons.warning_amber_rounded,
                      iconBg: const Color(0xFFFFF7ED),
                      iconColor: const Color(0xFFF97316),
                    ),
                    _buildGridStatsCard(
                      value: uniqueSuppliersCount.toString(),
                      label: "Suppliers",
                      icon: Icons.storefront_outlined,
                      iconBg: const Color(0xFFF5F3FF),
                      iconColor: const Color(0xFF8B5CF6),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // ================= SEARCH & FILTER LINE =================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: TextField(
                          controller: searchController,
                          onChanged: (value) => filterPurchases(),
                          decoration: const InputDecoration(
                            hintText: "Search orders, suppliers...",
                            hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                            prefixIcon: Icon(Icons.search, color: Color(0xFF94A3B8), size: 20),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: const Icon(Icons.filter_list, color: brandBlue, size: 20),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ================= HORIZONTAL STATUS CHIPS ROW =================
              SizedBox(
                height: 38,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  itemCount: filterTabs.length,
                  itemBuilder: (context, index) {
                    final tabName = filterTabs[index];
                    final bool isSelected = selectedTab == tabName;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedTab = tabName;
                          filterPurchases();
                        });
                      },
                      child: Container(
                        margin: const EdgeInsets.only(right: 10),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        decoration: BoxDecoration(
                          color: isSelected ? brandBlue : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected ? brandBlue : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            tabName,
                            style: TextStyle(
                              color: isSelected ? Colors.white : const Color(0xFF475569),
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),

              // ================= CARDS LIST (Actionless / Product Count Added) =================
              filteredPurchases.isEmpty
                  ? const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Text("No Orders Found", style: TextStyle(color: textMuted)),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 100),
                      itemCount: filteredPurchases.length,
                      itemBuilder: (context, index) {
                        final purchase = filteredPurchases[index];
                        final String supplierName = purchase.supplierName;
                        final String poNumber = purchase.purchaseNumber;
                        final double amount = purchase.totalAmount;
                        final String displayStatus = purchase.paymentStatus;
                        final bool isPaid = displayStatus.toLowerCase() == "paid";

                        int productCount = 0;
                        try {
                          productCount = (purchase as dynamic).items.length;
                        } catch (_) {
                          productCount = 1; 
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: const Icon(Icons.receipt_long_rounded, color: Color(0xFF94A3B8), size: 24),
                                  ),
                                  const SizedBox(width: 14),
                                  
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          supplierName.toUpperCase(),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: textPrimary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: const Color(0xFFEFF6FF),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            "PO: $poNumber",
                                            style: const TextStyle(
                                              color: brandBlue,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "Date: ${purchase.purchaseDate.day}/${purchase.purchaseDate.month}/${purchase.purchaseDate.year}",
                                          style: const TextStyle(color: textMuted, fontSize: 12, fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      const Text("Payment", style: TextStyle(color: textMuted, fontSize: 11)),
                                      const SizedBox(height: 2),
                                      Text(
                                        displayStatus.toUpperCase(),
                                        style: TextStyle(
                                          color: isPaid ? const Color(0xFF10B981) : const Color(0xFFF97316),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: isPaid ? const Color(0xFFECFDF5) : const Color(0xFFFFF7ED),
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          isPaid ? "Settled" : "Pending",
                                          style: TextStyle(
                                            color: isPaid ? const Color(0xFF10B981) : const Color(0xFFF97316),
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                ],
                              ),
                              const SizedBox(height: 16),
                              
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text("Purchase Amount", style: TextStyle(color: textMuted, fontSize: 11)),
                                      const SizedBox(height: 2),
                                      Text(
                                        "₹${amount.toStringAsFixed(2)}",
                                        style: const TextStyle(
                                          color: Color(0xFF10B981),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(Icons.inventory_2_outlined, size: 14, color: brandBlue),
                                        const SizedBox(width: 6),
                                        Text(
                                          "$productCount Products",
                                          style: const TextStyle(color: textPrimary, fontSize: 12, fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
          ],
        ),
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
        backgroundColor: brandBlue,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        icon: const Icon(Icons.add, color: Colors.white, size: 20),
        label: const Text(
          "Add Order",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildGridStatsCard({
    required String value,
    required String label,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
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