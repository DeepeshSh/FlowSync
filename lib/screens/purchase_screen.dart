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
  final List<String> filterTabs = ["All", "Paid", "Pending", "Draft"];
  DateTimeRange? selectedDateRange;

  @override
  void initState() {
    super.initState();
    loadPurchases();
  }

  // Deep extraction function to safely fetch the amount fields directly from the original payload keys
  double _getSafeAmount(Purchase purchase) {
    try {
      final dynamic raw = purchase;
      Map<dynamic, dynamic>? rawMap;

      // Try to extract raw Map representation via serialization methods if available
      if (raw is Map) {
        rawMap = raw;
      } else {
        try {
          rawMap = raw.toJson() as Map<dynamic, dynamic>;
        } catch (_) {
          try {
            rawMap = raw.toMap() as Map<dynamic, dynamic>;
          } catch (_) {}
        }
      }

      if (rawMap != null) {
        // Updated priority checking keys matching AddPurchaseScreen submission payload and total bills
        final keysToTry = ['grandTotal', 'grand_total', 'total_bill_amount', 'totalBillAmount', 'totalAmount', 'total_amount', 'subtotal', 'amount'];
        for (final key in keysToTry) {
          if (rawMap[key] != null) {
            final parsedValue = double.tryParse(rawMap[key].toString());
            if (parsedValue != null && parsedValue > 0) {
              return parsedValue;
            }
          }
        }
      }
      
      // Property level reflection probing
      try {
        if (raw.grandTotal != null) return double.tryParse(raw.grandTotal.toString()) ?? 0.0;
      } catch (_) {}
      try {
        if (raw.totalAmount != null) return double.tryParse(raw.totalAmount.toString()) ?? 0.0;
      } catch (_) {}
      
      // Final fallback to model property
      return double.tryParse(purchase.totalAmount.toString()) ?? 0.0;
    } catch (_) {
      return 0.0;
    }
  }

  // Deep extraction function to normalize status dynamically into explicit categories: Paid, Pending, Draft
// Deep extraction function to normalize status dynamically into explicit categories: Paid, Pending, Draft
  String _getSafeStatus(Purchase purchase) {
    try {
      final dynamic raw = purchase;
      String extractedStatus = "";
      Map<dynamic, dynamic>? rawMap;

      // Extract raw representation maps safely 
      if (raw is Map) {
        rawMap = raw;
      } else {
        try {
          rawMap = raw.toJson() as Map<dynamic, dynamic>;
        } catch (_) {
          try {
            rawMap = raw.toMap() as Map<dynamic, dynamic>;
          } catch (_) {}
        }
      }

      if (rawMap != null) {
        if (rawMap['status'] != null) extractedStatus = rawMap['status'].toString();
        if (extractedStatus.isEmpty && rawMap['paymentStatus'] != null) extractedStatus = rawMap['paymentStatus'].toString();
        if (extractedStatus.isEmpty && rawMap['payment_status'] != null) extractedStatus = rawMap['payment_status'].toString();
      }

      if (extractedStatus.isEmpty) {
        try {
          if (raw.status != null) extractedStatus = raw.status.toString();
        } catch (_) {}
        try {
          if (raw.paymentStatus != null) extractedStatus = raw.paymentStatus.toString();
        } catch (_) {}
      }
      
      if (extractedStatus.isEmpty) {
        extractedStatus = purchase.paymentStatus ?? "";
      }

      final cleanStatus = extractedStatus.trim().toLowerCase();

      // 1. DRAFT CONDITION CHECK (Check first so financial evaluation doesn't overwrite it)
      if (cleanStatus == "draft") {
        return "Draft";
      }

      // 2. FINANCIAL BALANCE EVALUATION
      double totalBillAmount = _getSafeAmount(purchase);
      double dueAmount = 0.0; 

      if (rawMap != null) {
        // Added 'balanceDue' to match the payload submitted from AddPurchaseScreen
        final dueKeys = ['balanceDue', 'dueAmount', 'due_amount', 'balance', 'remainingAmount', 'amountDue'];
        bool foundDueKey = false;
        for (final key in dueKeys) {
          if (rawMap[key] != null) {
            dueAmount = double.tryParse(rawMap[key].toString()) ?? 0.0;
            foundDueKey = true;
            break;
          }
        }
        if (!foundDueKey && cleanStatus != "pending") {
          dueAmount = 0.0;
        } else if (!foundDueKey && cleanStatus == "pending") {
          dueAmount = totalBillAmount;
        }
      }

      // 3. PAID CONDITION: Explicit paid status value or no balance remaining
      if (cleanStatus == "paid" || (totalBillAmount > 0 && dueAmount == 0)) {
        return "Paid";
      }
      
      // 4. PENDING CONDITION: Fallback default if amount is due
      return "Pending";
    } catch (_) {
      return "Pending";
    }
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
      if (!mounted) return;
      purchases = data;
      filterPurchases();
    } catch (_) {}
  }

  void filterPurchases() {
    List<Purchase> temp = List.from(purchases);

    if (searchController.text.isNotEmpty) {
      final query = searchController.text.toLowerCase();
      temp = temp.where((purchase) {
        final supplier = purchase.supplierName.toLowerCase();
        final poNumber = purchase.purchaseNumber.toLowerCase();
        return supplier.contains(query) || poNumber.contains(query);
      }).toList();
    }

    if (selectedTab != "All") {
      temp = temp.where((purchase) {
        return _getSafeStatus(purchase).toLowerCase() == selectedTab.toLowerCase();
      }).toList();
    }

    if (selectedDateRange != null) {
      final startDate = selectedDateRange!.start.subtract(const Duration(days: 1));
      final endDate = selectedDateRange!.end.add(const Duration(days: 1));
      temp = temp.where((purchase) {
        return purchase.purchaseDate.isAfter(startDate) &&
            purchase.purchaseDate.isBefore(endDate);
      }).toList();
    }

    if (!mounted) return;
    setState(() {
      filteredPurchases = temp;
    });
  }

  int get totalPurchases => purchases.length;

  double get totalStockValue {
    return purchases.fold(0.0, (sum, purchase) => sum + _getSafeAmount(purchase));
  }

  double get pendingValue {
    return purchases
        .where((purchase) {
          final status = _getSafeStatus(purchase).toLowerCase();
          return status == "pending" || status == "draft";
        })
        .fold(0.0, (sum, purchase) => sum + _getSafeAmount(purchase));
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFE5ECF4),
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00B287)),
          ),
        ),
      );
    }

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ================= HEADER SECTION =================
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.maybePop(context),
                        child: const Icon(
                          Icons.arrow_back_ios_new_rounded,
                          color: Color(0xFF0F172A),
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text(
                              "Purchases",
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A)),
                            ),
                            SizedBox(height: 6),
                            Text(
                              "Manage all your purchase orders across all networks",
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
                        'lib/assets/images/purchase_screen_header.png',
                        height: 80,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) => const SizedBox(width: 80, height: 80),
                      ),
                    ],
                  ),
                ),

                // ================= STAT CARDS GRID =================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          _buildStatCard(
                            "Purchase Count",
                            totalPurchases.toString(),
                            Icons.receipt_long_rounded,
                            const Color(0xFF3B82F6),
                          ),
                          const SizedBox(width: 14),
                          _buildStatCard(
                            "Total Outflow",
                            "₹${totalStockValue.toStringAsFixed(0)}",
                            Icons.currency_rupee_rounded,
                            const Color(0xFF10B981),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _buildFullWidthStatCard(
                        "Pending Outflow",
                        "₹${pendingValue.toStringAsFixed(0)}",
                        Icons.account_balance_wallet_rounded,
                        const Color(0xFFF59E0B),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ================= SEARCH FIELD =================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Container(
                    height: 52,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: const [
                        BoxShadow(
                          color: Color(0x05000000),
                          spreadRadius: 1,
                          blurRadius: 8,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    child: TextField(
                      controller: searchController,
                      onChanged: (value) => filterPurchases(),
                      decoration: const InputDecoration(
                        hintText: "Search purchase history...",
                        hintStyle: TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
                        prefixIcon: Icon(Icons.search, color: Color(0xFF94A3B8), size: 22),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ================= FILTERS ROW =================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () async {
                            final picked = await showDateRangePicker(
                              context: context,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2030),
                              initialDateRange: selectedDateRange,
                            );
                            if (picked != null) {
                              selectedDateRange = picked;
                              filterPurchases();
                            }
                          },
                          child: Container(
                            height: 46,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFE2E8F0)),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.calendar_today_outlined, size: 16, color: Color(0xFF3B82F6)),
                                const SizedBox(width: 8),
                                Text(
                                  selectedDateRange == null
                                      ? "Date Range"
                                      : "${selectedDateRange!.start.day}/${selectedDateRange!.start.month} - ${selectedDateRange!.end.day}/${selectedDateRange!.end.month}",
                                  style: const TextStyle(color: Color(0xFF1E293B), fontSize: 13, fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Container(
                          height: 46,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedTab,
                              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                              style: const TextStyle(color: Color(0xFF1E293B), fontSize: 13, fontWeight: FontWeight.w500),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  selectedTab = newValue;
                                  filterPurchases();
                                }
                              },
                              items: filterTabs.map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value == "All" ? "All Statuses" : value),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // ================= LIST HEADER TITLE =================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text(
                        "Recent Transactions",
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E293B),
                        ),
                      ),
                      Text(
                        "View All",
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00B287),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                // ================= ORDER LIST ITEMS =================
                filteredPurchases.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Text("No Purchase Orders Found", style: TextStyle(color: Color(0xFF64748B))),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 100),
                        itemCount: filteredPurchases.length,
                        itemBuilder: (context, index) {
                          final purchase = filteredPurchases[index];
                          final String orderStatus = _getSafeStatus(purchase);
                          final double calculatedAmount = _getSafeAmount(purchase);

                          int productCount = 1;
                          try {
                            productCount = (purchase as dynamic).items.length;
                          } catch (_) {}

                          return Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: const Color(0xFFF1F5F9)),
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 44,
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(Icons.description_outlined, color: Color(0xFF64748B), size: 20),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            purchase.supplierName.toUpperCase(),
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF1E293B),
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
                                              purchase.purchaseNumber,
                                              style: const TextStyle(
                                                color: Color(0xFF3B82F6),
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            "Date: ${purchase.purchaseDate.day}/${purchase.purchaseDate.month}/${purchase.purchaseDate.year}",
                                            style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        const Text("Payment", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                                        const SizedBox(height: 4),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: orderStatus.toLowerCase() == "paid"
                                                ? const Color(0xFFECFDF5)
                                                : orderStatus.toLowerCase() == "draft"
                                                    ? const Color(0xFFEFF6FF)
                                                    : const Color(0xFFFFF7ED),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            orderStatus,
                                            style: TextStyle(
                                              color: orderStatus.toLowerCase() == "paid"
                                                  ? const Color(0xFF10B981)
                                                  : orderStatus.toLowerCase() == "draft"
                                                      ? const Color(0xFF3B82F6)
                                                      : const Color(0xFFEA580C),
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        const Text("Purchase Amount", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
                                        const SizedBox(height: 2),
                                        Text(
                                          "₹${calculatedAmount.toStringAsFixed(2)}",
                                          style: const TextStyle(
                                            color: Color(0xFF00B287),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(Icons.shopping_bag_outlined, size: 14, color: Color(0xFF64748B)),
                                          const SizedBox(width: 4),
                                          Text(
                                            "$productCount Products",
                                            style: const TextStyle(color: Color(0xFF1E293B), fontSize: 12, fontWeight: FontWeight.w500),
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
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddPurchaseScreen()),
          );
          await refreshPurchases();
        },
        backgroundColor: const Color(0xFF2563EB),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        icon: const Icon(Icons.add, color: Colors.white, size: 20),
        label: const Text(
          "New Purchase",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color tint) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border:  Border.all(color: Color(0x99E2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: tint.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: tint, size: 18),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    title,
                    style: const TextStyle(color: Color(0xFF64748B), fontSize: 11, fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullWidthStatCard(String title, String value, IconData icon, Color tint) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border:  Border.all(color: Color(0x99E2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: tint.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: tint, size: 20),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
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