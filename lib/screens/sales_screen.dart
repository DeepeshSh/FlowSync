import 'package:flutter/material.dart';

import '../models/sale_model.dart';
import '../services/sale_service.dart';
import 'add_sale_screen.dart';
import 'sale_details_screen.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  List<Sale> sales = [];
  List<Sale> filteredSales = [];
  bool isLoading = true;

  final searchController = TextEditingController();
  String selectedCustomer = "All Customers";
  DateTimeRange? selectedDateRange;

  @override
  void initState() {
    super.initState();
    loadSales();
  }

  Future<void> loadSales() async {
    try {
      final data = await SaleService().getSales();
      setState(() {
        sales = data;
        filteredSales = data;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void filterSales() {
    List<Sale> temp = List.from(sales);

    if (searchController.text.isNotEmpty) {
      temp = temp.where((sale) {
        return sale.customerName
                .toLowerCase()
                .contains(searchController.text.toLowerCase()) ||
            sale.saleNumber
                .toLowerCase()
                .contains(searchController.text.toLowerCase());
      }).toList();
    }

    if (selectedCustomer != "All Customers") {
      temp = temp.where((sale) {
        return sale.customerName == selectedCustomer;
      }).toList();
    }

    if (selectedDateRange != null) {
      temp = temp.where((sale) {
        return sale.saleDate.isAfter(
              selectedDateRange!.start.subtract(const Duration(days: 1)),
            ) &&
            sale.saleDate.isBefore(
              selectedDateRange!.end.add(const Duration(days: 1)),
            );
      }).toList();
    }

    setState(() {
      filteredSales = temp;
    });
  }

  int get totalSales => sales.length;

  double get totalSalesValue {
    return sales.fold(0, (sum, sale) => sum + sale.totalAmount);
  }

  double get pendingCollections {
    return sales
        .where((sale) => sale.paymentStatus != "Paid")
        .fold(0, (sum, sale) => sum + sale.totalAmount);
  }

  List<String> get customers {
    final list = sales.map((sale) => sale.customerName).toSet().toList();
    list.sort();
    return ["All Customers", ...list];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // 1. Continuous Flow Background Gradient
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFE2EAF2), // Rich slate tint at top
                    Color(0xFFF1F5F9), // Fades down smoothly
                    Colors.white,      // Flawlessly clean white baseline
                  ],
                  stops: [0.0, 0.35, 0.7],
                ),
              ),
            ),
          ),

          // 2. Premium Ambient Flow Accent Circles (Lower Screen Areas)
          Positioned(
            right: -80,
            top: 320,
            child: Container(
              width: 220,
              height: 220,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0x0C3B82F6), Colors.transparent],
                ),
              ),
            ),
          ),

          // 3. Main Screen UI Content
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Layout aligning perfectly with image_8f1aa9.png
                      Padding(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Blended Back Button Arrow
                            Padding(
                              padding: const EdgeInsets.only(top: 6),
                              child: GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: Color(0xFF1E293B),
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),

                            // Typography Stack Parallel to the Navigation Axis
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    "Sales",
                                    style: TextStyle(
                                      fontSize: 26,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF0F172A),
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    "Manage all your sales orders /n across all networks",
                                    style: TextStyle(
                                      color: Color(0xFF64748B),
                                      fontSize: 13,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),

                            // Header Image paired with custom dark blue framing semicircle
                            Stack(
                              alignment: Alignment.center,
                              children: [
                                // Deep Dark Blue Semicircle Frame Asset Backdrop
                                ClipRect(
                                  child: Align(
                                    alignment: Alignment.topCenter,
                                    heightFactor: 0.9,
                                    child: Container(
                                      width: 84,
                                      height: 84,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          begin: Alignment.topCenter,
                                          end: Alignment.bottomCenter,
                                          colors: [
                                            const Color(0xFF1E3A8A).withOpacity(0.85), // Premium Dark Blue base
                                            const Color(0xFF0F172A).withOpacity(0.4),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                // Requested Header Asset Image
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
                                  child: Image.asset(
                                    'lib/assets/images/sales_screen_header.png',
                                    height: 72,
                                    width: 72,
                                    fit: BoxFit.contain,
                                    errorBuilder: (context, error, stackTrace) => const SizedBox(),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Top Metrics Row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          children: [
                            Expanded(
                              child: _buildStatCard(
                                "Sales Count",
                                totalSales.toString(),
                                Icons.receipt_long_rounded,
                                Colors.blue,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _buildStatCard(
                                "Revenue",
                                "₹${totalSalesValue.toStringAsFixed(0)}",
                                Icons.currency_rupee_rounded,
                                Colors.green,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Pending Collections Wide Metric Container
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.01),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              )
                            ]
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 46,
                                height: 46,
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade50,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.account_balance_wallet_rounded,
                                  color: Colors.orange,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "₹${pendingCollections.toStringAsFixed(0)}",
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF1E293B),
                                      ),
                                    ),
                                    const Text(
                                      "Pending Collections",
                                      style: TextStyle(color: Color(0xFF64748B), fontSize: 13),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Search Bar
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: TextField(
                          controller: searchController,
                          onChanged: (value) => filterSales(),
                          decoration: InputDecoration(
                            hintText: "Search sales history...",
                            hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
                            prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF64748B)),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(vertical: 14),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.5),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Filter Row Panel
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
                                    setState(() {
                                      selectedDateRange = result;
                                    });
                                    filterSales();
                                  }
                                },
                                child: Container(
                                  height: 48,
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.calendar_month_rounded, color: Color(0xFF3B82F6), size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          selectedDateRange == null
                                              ? "Date Range"
                                              : "${selectedDateRange!.start.day}/${selectedDateRange!.start.month} - ${selectedDateRange!.end.day}/${selectedDateRange!.end.month}",
                                          style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
                                          overflow: TextOverflow.ellipsis,
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
                                height: 48,
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: const Color(0xFFE2E8F0)),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: selectedCustomer,
                                    isExpanded: true,
                                    icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                                    items: customers.map((customer) {
                                      return DropdownMenuItem(
                                        value: customer,
                                        child: Text(
                                          customer,
                                          style: const TextStyle(fontSize: 13, color: Color(0xFF1E293B)),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      if (value == null) return;
                                      selectedCustomer = value;
                                      filterSales();
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Feed Segment Labels
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: const [
                            Text(
                              "Recent Transactions",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E293B),
                              ),
                            ),
                            Text(
                              "View All",
                              style: TextStyle(
                                color: Color(0xFF10B981),
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Transaction Feed List Builder Block
                      Expanded(
                        child: filteredSales.isEmpty
                            ? const Center(
                                child: Text(
                                  "No Sales Found",
                                  style: TextStyle(color: Color(0xFF94A3B8)),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.only(left: 20, right: 20, bottom: 100),
                                itemCount: filteredSales.length,
                                itemBuilder: (context, index) {
                                  final sale = filteredSales[index];
                                  final bool isPaid = sale.paymentStatus == "Paid";

                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => SaleDetailsScreen(sale: sale),
                                        ),
                                      );
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(bottom: 14),
                                      padding: const EdgeInsets.all(18),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(24),
                                        border: Border.all(color: const Color(0xFFE2E8F0)),
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: 52,
                                                height: 52,
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFF1F5F9),
                                                  borderRadius: BorderRadius.circular(14),
                                                ),
                                                child: const Icon(
                                                  Icons.description_outlined,
                                                  color: Color(0xFF64748B),
                                                  size: 22,
                                                ),
                                              ),
                                              const SizedBox(width: 14),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      sale.customerName.toUpperCase(),
                                                      style: const TextStyle(
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.w800,
                                                        color: Color(0xFF1E293B),
                                                        letterSpacing: 0.3,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 4),
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFFEFF6FF),
                                                        borderRadius: BorderRadius.circular(6),
                                                      ),
                                                      child: Text(
                                                        sale.saleNumber,
                                                        style: const TextStyle(
                                                          color: Color(0xFF2563EB),
                                                          fontWeight: FontWeight.w600,
                                                          fontSize: 11,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 6),
                                                    Text(
                                                      "Date: ${sale.saleDate.day}/${sale.saleDate.month}/${sale.saleDate.year}",
                                                      style: const TextStyle(
                                                        color: Color(0xFF64748B),
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  const Text(
                                                    "Payment",
                                                    style: TextStyle(
                                                      color: Color(0xFF94A3B8),
                                                      fontSize: 11,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 2),
                                                  Text(
                                                    sale.paymentStatus.toUpperCase(),
                                                    style: TextStyle(
                                                      color: isPaid ? const Color(0xFF10B981) : const Color(0xFFEA580C),
                                                      fontWeight: FontWeight.w900,
                                                      fontSize: 13,
                                                      letterSpacing: 0.3,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 6),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                                    decoration: BoxDecoration(
                                                      color: isPaid ? const Color(0xFFD1FAE5) : const Color(0xFFFFEDD5),
                                                      borderRadius: BorderRadius.circular(10),
                                                    ),
                                                    child: Text(
                                                      sale.paymentStatus,
                                                      style: TextStyle(
                                                        color: isPaid ? const Color(0xFF065F46) : const Color(0xFFC2410C),
                                                        fontWeight: FontWeight.w600,
                                                        fontSize: 11,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  const Text(
                                                    "Sale Amount",
                                                    style: TextStyle(
                                                      color: Color(0xFF94A3B8),
                                                      fontSize: 12,
                                                    ),
                                                  ),
                                                  const SizedBox(height: 4),
                                                  Text(
                                                    "₹${sale.totalAmount.toStringAsFixed(2)}",
                                                    style: const TextStyle(
                                                      fontWeight: FontWeight.w900,
                                                      fontSize: 18,
                                                      color: Color(0xFF10B981),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Container(
                                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFF1F5F9),
                                                  borderRadius: BorderRadius.circular(12),
                                                ),
                                                child: Row(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    const Icon(
                                                      Icons.shopping_bag_outlined,
                                                      size: 15,
                                                      color: Color(0xFF3B82F6),
                                                    ),
                                                    const SizedBox(width: 6),
                                                    Text(
                                                      "${sale.itemCount} Products",
                                                      style: const TextStyle(
                                                        color: Color(0xFF1E293B),
                                                        fontWeight: FontWeight.bold,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF10B981),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddSaleScreen()),
          );
          loadSales();
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "New Sale",
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color accentColor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: accentColor.withOpacity(0.1),
            child: Icon(icon, color: accentColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E293B),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  title,
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}