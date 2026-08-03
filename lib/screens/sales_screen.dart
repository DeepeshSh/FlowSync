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

  // Kept exactly as in the original sale screen (backend/functionality unchanged)
  double _getSafeAmount(Sale sale) {
    return sale.totalAmount;
  }

  Future<void> loadSales() async {
    try {
      final data = await SaleService().getSales();
      if (!mounted) return;
      setState(() {
        sales = data;
        filteredSales = data;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> refreshSales() async {
    try {
      final data = await SaleService().getSales();
      if (!mounted) return;
      sales = data;
      filterSales();
    } catch (_) {}
  }

  void filterSales() {
    List<Sale> temp = List.from(sales);

    if (searchController.text.isNotEmpty) {
      final query = searchController.text.toLowerCase();
      temp = temp.where((sale) {
        final customer = sale.customerName.toLowerCase();
        final saleNo = sale.saleNumber.toLowerCase();
        return customer.contains(query) || saleNo.contains(query);
      }).toList();
    }

    if (selectedCustomer != "All Customers") {
      temp = temp.where((sale) {
        return sale.customerName == selectedCustomer;
      }).toList();
    }

    if (selectedDateRange != null) {
      final startDate = selectedDateRange!.start.subtract(const Duration(days: 1));
      final endDate = selectedDateRange!.end.add(const Duration(days: 1));
      temp = temp.where((sale) {
        return sale.saleDate.isAfter(startDate) && sale.saleDate.isBefore(endDate);
      }).toList();
    }

    if (!mounted) return;
    setState(() {
      filteredSales = temp;
    });
  }

  int get totalSales => sales.length;

  double get totalSalesValue {
    return sales.fold(0.0, (sum, sale) => sum + _getSafeAmount(sale));
  }

  double get pendingCollections {
    return sales
        .where((sale) => sale.paymentStatus != "Paid")
        .fold(0.0, (sum, sale) => sum + _getSafeAmount(sale));
  }

  List<String> get customers {
    final list = sales.map((sale) => sale.customerName).toSet().toList();
    list.sort();
    return ["All Customers", ...list];
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
                              "Sales",
                              style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0F172A)),
                            ),
                            SizedBox(height: 6),
                            Text(
                              "Manage all your sales orders across all networks",
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
                        'lib/assets/images/sales_screen_header.png',
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
                            "Sales Count",
                            totalSales.toString(),
                            Icons.receipt_long_rounded,
                            const Color(0xFF3B82F6),
                          ),
                          const SizedBox(width: 14),
                          _buildStatCard(
                            "Revenue",
                            "₹${totalSalesValue.toStringAsFixed(0)}",
                            Icons.currency_rupee_rounded,
                            const Color(0xFF10B981),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _buildFullWidthStatCard(
                        "Pending Collections",
                        "₹${pendingCollections.toStringAsFixed(0)}",
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
                      onChanged: (value) => filterSales(),
                      decoration: const InputDecoration(
                        hintText: "Search sales history...",
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
                              filterSales();
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
                                Expanded(
                                  child: Text(
                                    selectedDateRange == null
                                        ? "Date Range"
                                        : "${selectedDateRange!.start.day}/${selectedDateRange!.start.month} - ${selectedDateRange!.end.day}/${selectedDateRange!.end.month}",
                                    style: const TextStyle(color: Color(0xFF1E293B), fontSize: 13, fontWeight: FontWeight.w500),
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
                          height: 46,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<String>(
                              value: selectedCustomer,
                              isExpanded: true,
                              icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF64748B)),
                              style: const TextStyle(color: Color(0xFF1E293B), fontSize: 13, fontWeight: FontWeight.w500),
                              onChanged: (String? newValue) {
                                if (newValue != null) {
                                  selectedCustomer = newValue;
                                  filterSales();
                                }
                              },
                              items: customers.map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value, overflow: TextOverflow.ellipsis),
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

                // ================= SALE LIST ITEMS =================
                filteredSales.isEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 40),
                          child: Text("No Sales Found", style: TextStyle(color: Color(0xFF64748B))),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 100),
                        itemCount: filteredSales.length,
                        itemBuilder: (context, index) {
                          final sale = filteredSales[index];
                          final bool isPaid = sale.paymentStatus == "Paid";
                          final double calculatedAmount = _getSafeAmount(sale);
                          final int productCount = sale.itemCount;

                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => SaleDetailsScreen(sale: sale)),
                              );
                            },
                            child: Container(
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
                                              sale.customerName.toUpperCase(),
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
                                                sale.saleNumber,
                                                style: const TextStyle(
                                                  color: Color(0xFF3B82F6),
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(
                                              "Date: ${sale.saleDate.day}/${sale.saleDate.month}/${sale.saleDate.year}",
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
                                              color: isPaid ? const Color(0xFFECFDF5) : const Color(0xFFFFF7ED),
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                              sale.paymentStatus,
                                              style: TextStyle(
                                                color: isPaid ? const Color(0xFF10B981) : const Color(0xFFEA580C),
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
                                          const Text("Sale Amount", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11)),
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
            MaterialPageRoute(builder: (_) => const AddSaleScreen()),
          );
          await refreshSales();
        },
        backgroundColor: const Color(0xFF2563EB),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        icon: const Icon(Icons.add, color: Colors.white, size: 20),
        label: const Text(
          "New Sale",
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
          border: Border.all(color: const Color(0x99E2E8F0)),
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
        border: Border.all(color: const Color(0x99E2E8F0)),
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