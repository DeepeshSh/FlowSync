import 'package:flutter/material.dart';

import '../models/customer_model.dart';
import '../services/customer_service.dart';
import 'add_customer_screen.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  List<Customer> customers = [];

  List<Customer> filteredCustomers = [];

  bool isLoading = true;

  final TextEditingController searchController = TextEditingController();

  double totalReceivables = 0;

  double overdueAmount = 0;

  int customersWithDue = 0;

  int overdueCustomers = 0;

  String selectedFilter = "All";

  @override
  void initState() {
    super.initState();

    loadCustomers();
  }

  Future<void> loadCustomers() async {
    try {
      final data = await CustomerService().getCustomers();

      totalReceivables = data.fold(
        0.0,
        (sum, customer) => sum + customer.openingBalance,
      );

      customersWithDue = data
          .where((customer) => customer.openingBalance > 0)
          .length;

      overdueAmount = data.fold(
        0.0,
        (sum, customer) =>
            customer.openingBalance > 0 ? sum + customer.openingBalance : sum,
      );

      overdueCustomers = data
          .where((customer) => customer.openingBalance > 0)
          .length;

      setState(() {
        customers = data;

        filteredCustomers = data;

        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  void searchCustomers(String query) {
    setState(() {
      filteredCustomers = customers.where((customer) {
        return customer.customerName.toLowerCase().contains(
              query.toLowerCase(),
            ) ||
            customer.phone.contains(query);
      }).toList();
    });
  }

  void applyFilter(String filter) {
    setState(() {
      selectedFilter = filter;

      if (filter == "All") {
        filteredCustomers = customers;
      } else if (filter == "Receivables") {
        filteredCustomers = customers.where((customer) {
          return customer.openingBalance > 0;
        }).toList();
      } else if (filter == "Overdue") {
        filteredCustomers = customers.where((customer) {
          return customer.openingBalance > 0;
        }).toList();
      } else {
        filteredCustomers = customers.where((customer) {
          return customer.isActive;
        }).toList();
      }
    });
  }

  Widget filterChip(String title) {
    final isSelected = selectedFilter == title;

    return InkWell(
      onTap: () {
        applyFilter(title);
      },

      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),

        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF143D7A) : Colors.white,

          borderRadius: BorderRadius.circular(30),
        ),

        child: Text(
          title,

          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,

            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget buildCustomerCard(Customer customer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Colors.white,

        borderRadius: BorderRadius.circular(24),

        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8)],
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          // CUSTOMER AVATAR
          Container(
            width: 62,
            height: 62,

            decoration: BoxDecoration(
              color: const Color(0xFFEAF2FF),

              borderRadius: BorderRadius.circular(18),
            ),

            child: const Icon(
              Icons.person_outline,

              size: 30,

              color: Color(0xFF143D7A),
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        customer.customerName,

                        style: const TextStyle(
                          fontSize: 16,

                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),

                      decoration: BoxDecoration(
                        color: customer.isActive
                            ? const Color(0xFFE8F7F5)
                            : const Color(0xFFFFF4E5),

                        borderRadius: BorderRadius.circular(20),
                      ),

                      child: Text(
                        customer.isActive ? "Active" : "Inactive",

                        style: TextStyle(
                          color: customer.isActive
                              ? const Color(0xFF0F766E)
                              : Colors.orange,

                          fontWeight: FontWeight.w600,

                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 4),

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        customer.phone,

                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),

                    Text(
                      "₹${customer.openingBalance.toStringAsFixed(0)}",

                      style: const TextStyle(
                        color: Colors.orange,

                        fontSize: 18,

                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 2),

                Row(
                  children: [
                    Expanded(
                      child: Text(
                        "${customer.city}, ${customer.state}",

                        style: const TextStyle(color: Colors.grey),
                      ),
                    ),

                    const Text(
                      "Receivable",

                      style: TextStyle(color: Colors.grey, fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FC),

      appBar: AppBar(
        elevation: 0,

        backgroundColor: const Color(0xFFF5F7FC),

        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            Text(
              "Customers",

              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,

                color: Color(0xFF1B2559),
              ),
            ),

            Text(
              "Manage customer network",

              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ],
        ),
      ),

      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),

              child: Column(
                children: [
                  // SUMMARY CARD
                  Container(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),

                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF143D7A), Color(0xFF1E5CB3)],
                      ),
                      borderRadius: BorderRadius.circular(22),
                    ),

                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  const Text(
                                    "Total Receivables",
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),

                                  const SizedBox(height: 6),

                                  Text(
                                    "₹${totalReceivables.toStringAsFixed(0)}",

                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 30,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            Container(
                              width: 1,
                              height: 105,
                              color: Colors.white24,
                            ),

                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 16),

                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.notifications_active,
                                          size: 14,
                                          color: Color(0xFFFF4D6D),
                                        ),

                                        const SizedBox(width: 4),

                                        const Text(
                                          "Overdue Amount",

                                          style: TextStyle(
                                            color: Colors.white70,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 6),

                                    Text(
                                      "₹${overdueAmount.toStringAsFixed(0)}",

                                      style: const TextStyle(
                                        color: Color(0xFFFF4D6D),
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 0),

                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,

                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.groups,
                                        size: 17,
                                        color: Colors.white60,
                                      ),

                                      const SizedBox(width: 4),

                                      Text(
                                        "$customersWithDue Customers have dues",

                                        style: const TextStyle(
                                          color: Colors.white60,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 8),

                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.warning_amber_rounded,
                                          size: 17,
                                          color: Color(0xFFFF4D6D),
                                        ),

                                        const SizedBox(width: 4),

                                        Text(
                                          "$overdueCustomers Customers overdue",

                                          style: const TextStyle(
                                            color: Colors.white60,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // SEARCH BAR
                  TextField(
                    controller: searchController,

                    onChanged: searchCustomers,

                    decoration: InputDecoration(
                      hintText: "Search customer...",

                      prefixIcon: const Icon(Icons.search),

                      filled: true,

                      fillColor: Colors.white,

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),

                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // FILTERS
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,

                    child: Row(
                      children: [
                        filterChip("All"),

                        const SizedBox(width: 8),

                        filterChip("Receivables"),

                        const SizedBox(width: 8),

                        filterChip("Overdue"),

                        const SizedBox(width: 8),

                        filterChip("Active"),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  filteredCustomers.isEmpty
                      ? Container(
                          padding: const EdgeInsets.all(40),

                          child: const Column(
                            children: [
                              Icon(
                                Icons.people_outline,

                                size: 70,

                                color: Colors.grey,
                              ),

                              SizedBox(height: 12),

                              Text(
                                "No Customers Found",

                                style: TextStyle(
                                  fontSize: 18,

                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          shrinkWrap: true,

                          physics: const NeverScrollableScrollPhysics(),

                          itemCount: filteredCustomers.length,

                          itemBuilder: (context, index) {
                            final customer = filteredCustomers[index];

                            return buildCustomerCard(customer);
                          },
                        ),
                ],
              ),
            ),

      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF143D7A),

        onPressed: () async {
          await Navigator.push(
            context,

            MaterialPageRoute(builder: (_) => const AddCustomerScreen()),
          );

          loadCustomers();
        },

        icon: const Icon(Icons.add, color: Colors.white),

        label: const Text(
          "Add Customer",

          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
