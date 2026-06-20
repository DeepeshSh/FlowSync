import 'package:flutter/material.dart';

import '../models/supplier_model.dart';
import '../services/supplier_service.dart';
import 'add_supplier_screen.dart';

class SuppliersScreen extends StatefulWidget {
  const SuppliersScreen({super.key});

  @override
  State<SuppliersScreen> createState() =>
      _SuppliersScreenState();
}

class _SuppliersScreenState
    extends State<SuppliersScreen> {

  List<Supplier> suppliers = [];

  List<Supplier> filteredSuppliers = [];

  bool isLoading = true;

  final TextEditingController
      searchController =
          TextEditingController();

  double totalOutstanding = 0;

  int activeSuppliers = 0;

  String selectedFilter = "All";

  @override
  void initState() {
    super.initState();

    loadSuppliers();
  }

  Future<void> loadSuppliers() async {

    try {

      final data =
          await SupplierService()
              .getSuppliers();

      totalOutstanding = data.fold(
        0.0,
        (sum, supplier) =>
            sum +
            supplier.openingBalance,
      );

      activeSuppliers =
          data
              .where(
                (supplier) =>
                    supplier.isActive,
              )
              .length;

      setState(() {

        suppliers = data;

        filteredSuppliers = data;

        isLoading = false;
      });

    } catch (e) {

      setState(() {
        isLoading = false;
      });
    }
  }
    void searchSuppliers(
    String query,
  ) {

    setState(() {

      filteredSuppliers =
          suppliers.where((
        supplier,
      ) {

        return supplier
                .supplierName
                .toLowerCase()
                .contains(
                  query
                      .toLowerCase(),
                ) ||
            supplier.phone
                .contains(
                  query,
                );

      }).toList();
    });
  }

  void applyFilter(
    String filter,
  ) {

    setState(() {

      selectedFilter = filter;

      if (filter == "All") {

        filteredSuppliers =
            suppliers;

      } else if (
          filter ==
          "Active") {

        filteredSuppliers =
            suppliers.where(
          (
            supplier,
          ) {

            return supplier
                .isActive;

          },
        ).toList();

      } else if (
          filter ==
          "Inactive") {

        filteredSuppliers =
            suppliers.where(
          (
            supplier,
          ) {

            return !supplier
                .isActive;

          },
        ).toList();

      } else {

        filteredSuppliers =
            suppliers.where(
          (
            supplier,
          ) {

            return supplier
                    .openingBalance >
                0;

          },
        ).toList();
      }
    });
  }

      Widget filterChip(
  String title,
) {

  final isSelected =
      selectedFilter ==
          title;

  return InkWell(

    onTap: () {

      applyFilter(
        title,
      );
    },

    child: Container(

      padding:
          const EdgeInsets.symmetric(

        horizontal: 14,
        vertical: 8,
      ),

      decoration:
          BoxDecoration(

        color: isSelected

            ? const Color(
                0xFF143D7A,
              )

            : Colors.white,

        borderRadius:
            BorderRadius.circular(
          30,
        ),
      ),

      child: Text(

        title,

        style: TextStyle(

          color: isSelected

              ? Colors.white

              : Colors.black87,

          fontWeight:
              FontWeight.w600,
        ),
      ),
    ),
  );
}

Widget buildSupplierCard(
  Supplier supplier,
) {

  return Container(

    margin:
        const EdgeInsets.only(
      bottom: 14,
    ),

    padding:
        const EdgeInsets.all(16),

    decoration:
        BoxDecoration(

      color: Colors.white,

      borderRadius:
          BorderRadius.circular(
        24,
      ),

      boxShadow: const [

        BoxShadow(
          color: Colors.black12,
          blurRadius: 8,
        ),
      ],
    ),

    child: Column(

      children: [

        Row(

          children: [

            Container(

              width: 60,
              height: 60,

              decoration:
                  BoxDecoration(

                color:
                    const Color(
                  0xFFEAF2FF,
                ),

                borderRadius:
                    BorderRadius.circular(
                  18,
                ),
              ),

              child: const Icon(

                Icons.storefront_outlined,

                size: 30,

                color:
                    Color(
                  0xFF143D7A,
                ),
              ),
            ),

            const SizedBox(
              width: 12,
            ),

            Expanded(

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [

                  Text(
                    supplier
                        .supplierName,

                    style:
                        const TextStyle(

                      fontSize: 17,

                      fontWeight:
                          FontWeight
                              .bold,
                    ),
                  ),

                  const SizedBox(
                    height: 2,
                  ),

                  Text(
                    supplier.phone,

                    style:
                        const TextStyle(
                      color:
                          Colors.grey,
                    ),
                  ),

                  Text(
                    "${supplier.city}, ${supplier.state}",

                    style:
                        const TextStyle(
                      color:
                          Colors.grey,
                    ),
                  ),
                ],
              ),
            ),

            Container(

              padding:
                  const EdgeInsets.symmetric(

                horizontal: 10,
                vertical: 4,
              ),

              decoration:
                  BoxDecoration(

                color:
                    supplier.isActive

                        ? const Color(
                            0xFFE8F7F5,
                          )

                        : const Color(
                            0xFFFFF4E5,
                          ),

                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
              ),

              child: Text(

                supplier.isActive
                    ? "Active"
                    : "Inactive",

                style:
                    TextStyle(

                  color:
                      supplier.isActive

                          ? const Color(
                              0xFF0F766E,
                            )

                          : Colors.orange,

                  fontWeight:
                      FontWeight.w600,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(
          height: 16,
        ),

        Container(

          padding:
              const EdgeInsets.all(
            14,
          ),

          decoration:
              BoxDecoration(

            color:
                const Color(
              0xFFF8FAFC,
            ),

            borderRadius:
                BorderRadius.circular(
              16,
            ),
          ),

          child: Row(

            children: [

              Expanded(

                child: Column(

                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [

                    const Text(

                      "Outstanding",

                      style: TextStyle(
                        color:
                            Colors.grey,
                      ),
                    ),

                    const SizedBox(
                      height: 4,
                    ),

                    Text(

                      "₹${supplier.openingBalance.toStringAsFixed(0)}",

                      style:
                          const TextStyle(

                        color:
                            Colors.orange,

                        fontSize: 22,

                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              Container(

                padding:
                    const EdgeInsets.symmetric(

                  horizontal: 12,
                  vertical: 8,
                ),

                decoration:
                    BoxDecoration(

                  color:
                      const Color(
                    0xFFEAF2FF,
                  ),

                  borderRadius:
                      BorderRadius.circular(
                    12,
                  ),
                ),

                child: Text(

                  supplier.paymentTerms,

                  style:
                      const TextStyle(

                    color:
                        Color(
                      0xFF143D7A,
                    ),

                    fontWeight:
                        FontWeight.w600,
                  ),
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
  Widget build(
    BuildContext context,
  ) {

    return Scaffold(

      backgroundColor:
          const Color(
        0xFFF5F7FC,
      ),

      appBar: AppBar(

        elevation: 0,

        backgroundColor:
            const Color(
          0xFFF5F7FC,
        ),

        title: const Column(

          crossAxisAlignment:
              CrossAxisAlignment
                  .start,

          children: [

            Text(
              "Suppliers",

              style: TextStyle(
                fontSize: 24,
                fontWeight:
                    FontWeight.bold,

                color:
                    Color(
                  0xFF1B2559,
                ),
              ),
            ),

            Text(
              "Manage supplier network",

              style: TextStyle(
                fontSize: 13,

                color:
                    Colors.grey,
              ),
            ),
          ],
        ),
      ),

      body: isLoading

          ? const Center(
              child:
                  CircularProgressIndicator(),
            )

          : SingleChildScrollView(

    padding:
        const EdgeInsets.all(20),

    child: Column(

      children: [

        // SUMMARY CARD

        Container(

          padding:
              const EdgeInsets.all(22),

          decoration:
              BoxDecoration(

            gradient:
                const LinearGradient(

              colors: [

                Color(
                  0xFF143D7A,
                ),

                Color(
                  0xFF1E5CB3,
                ),
              ],
            ),

            borderRadius:
                BorderRadius.circular(
              28,
            ),
          ),

          child: Row(

            children: [

              Expanded(

                child: Column(

                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [

                    const Text(
                      "Total Outstanding",

                      style: TextStyle(
                        color:
                            Colors.white70,
                      ),
                    ),

                    const SizedBox(
                      height: 6,
                    ),

                    Text(
                      "₹${totalOutstanding.toStringAsFixed(0)}",

                      style:
                          const TextStyle(

                        color:
                            Colors.white,

                        fontSize: 28,

                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              Container(

                width: 1,

                height: 70,

                color:
                    Colors.white24,
              ),

              const SizedBox(
                width: 20,
              ),

              Expanded(

                child: Column(

                  crossAxisAlignment:
                      CrossAxisAlignment
                          .start,

                  children: [

                    const Text(
                      "Active Suppliers",

                      style: TextStyle(
                        color:
                            Colors.white70,
                      ),
                    ),

                    const SizedBox(
                      height: 6,
                    ),

                    Text(
                      activeSuppliers
                          .toString(),

                      style:
                          const TextStyle(

                        color:
                            Colors.white,

                        fontSize: 28,

                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(
          height: 20,
        ),

        // SEARCH BAR

        TextField(

          controller:
              searchController,

          onChanged:
              searchSuppliers,

          decoration:
              InputDecoration(

            hintText:
                "Search supplier...",

            prefixIcon:
                const Icon(
              Icons.search,
            ),

            filled: true,

            fillColor:
                Colors.white,

            border:
                OutlineInputBorder(

              borderRadius:
                  BorderRadius.circular(
                16,
              ),

              borderSide:
                  BorderSide.none,
            ),
          ),
        ),

        const SizedBox(
          height: 14,
        ),

        // FILTER CHIPS

        SingleChildScrollView(

          scrollDirection:
              Axis.horizontal,

          child: Row(

            children: [

              filterChip(
                "All",
              ),

              const SizedBox(
                width: 8,
              ),

              filterChip(
                "Active",
              ),

              const SizedBox(
                width: 8,
              ),

              filterChip(
                "Inactive",
              ),

              const SizedBox(
                width: 8,
              ),

              filterChip(
                "Outstanding",
              ),
            ],
          ),
        ),

        const SizedBox(
          height: 18,
        ),

        filteredSuppliers.isEmpty

    ? Container(

        padding:
            const EdgeInsets.all(
          40,
        ),

        child: const Column(

          children: [

            Icon(
              Icons.storefront_outlined,

              size: 70,

              color: Colors.grey,
            ),

            SizedBox(
              height: 12,
            ),

            Text(
              "No Suppliers Found",

              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
        ),
      )

    : ListView.builder(

        shrinkWrap: true,

        physics:
            const NeverScrollableScrollPhysics(),

        itemCount:
            filteredSuppliers.length,

        itemBuilder:
            (context, index) {

          final supplier =
              filteredSuppliers[
                  index];

          return buildSupplierCard(
            supplier,
          );
        },
      ),

          ],
    ),
  ),

  floatingActionButton:
      FloatingActionButton.extended(

    backgroundColor:
        const Color(
      0xFF143D7A,
    ),

    onPressed: () async {

      await Navigator.push(
        context,

        MaterialPageRoute(
          builder: (_) =>
              const AddSupplierScreen(),
        ),
      );

      loadSuppliers();
    },

    icon: const Icon(
      Icons.add,
      color: Colors.white,
    ),

    label: const Text(
      "Add Supplier",

      style: TextStyle(
        color: Colors.white,
      ),
    ),
  ),
);
  }
}

