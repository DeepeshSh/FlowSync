import 'package:flutter/material.dart';

import '../models/sale_model.dart';
import '../services/sale_service.dart';
import 'add_sale_screen.dart';
import 'sale_details_screen.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({super.key});

  @override
  State<SalesScreen> createState() =>
      _SalesScreenState();
}

class _SalesScreenState
    extends State<SalesScreen> {

  List<Sale> sales = [];

  List<Sale> filteredSales = [];

  bool isLoading = true;

  final searchController =
      TextEditingController();

  String selectedCustomer =
      "All Customers";

      DateTimeRange? selectedDateRange;

  @override
  void initState() {
    super.initState();

    loadSales();
  }



  Future<void> loadSales() async {

    try {

      final data =
          await SaleService()
              .getSales();

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

    List<Sale> temp =
        List.from(sales);

    if (searchController
        .text
        .isNotEmpty) {

      temp = temp.where((sale) {

        return sale.customerName
                .toLowerCase()
                .contains(
                  searchController.text
                      .toLowerCase(),
                ) ||

            sale.saleNumber
                .toLowerCase()
                .contains(
                  searchController.text
                      .toLowerCase(),
                );

      }).toList();
    }

    if (selectedCustomer !=
        "All Customers") {

      temp = temp.where((sale) {

        return sale.customerName ==
            selectedCustomer;

      }).toList();
    }

if (selectedDateRange != null) {

  temp = temp.where((sale) {

    return sale.saleDate.isAfter(
          selectedDateRange!.start.subtract(
            const Duration(days: 1),
          ),
        ) &&

        sale.saleDate.isBefore(
          selectedDateRange!.end.add(
            const Duration(days: 1),
          ),
        );

  }).toList();
}
    setState(() {
      filteredSales = temp;
    });
  }

  int get totalSales =>
      sales.length;

  double get totalSalesValue {

    return sales.fold(
      0,
      (sum, sale) =>
          sum +
          sale.totalAmount,
    );
  }

  double get pendingCollections {

    return sales

        .where(
          (sale) =>
              sale.paymentStatus !=
              "Paid",
        )

        .fold(
          0,
          (sum, sale) =>
              sum +
              sale.totalAmount,
        );
  }



  List<String> get customers {

    final list = sales

        .map(
          (sale) =>
              sale.customerName,
        )

        .toSet()

        .toList();

    list.sort();

    return [
      "All Customers",
      ...list,
    ];
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(
        0xFFF5F7FC,
      ),

      floatingActionButton:
          FloatingActionButton.extended(

        backgroundColor:
            Colors.green,

        onPressed: () async {

          await Navigator.push(
            context,

            MaterialPageRoute(
              builder: (_) =>
                  const AddSaleScreen(),
            ),
          );

          loadSales();
        },

        icon: const Icon(
          Icons.add,
          color: Colors.white,
        ),

        label: const Text(
          "New Sale",

          style: TextStyle(
            color: Colors.white,
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),

      body: isLoading

          ? const Center(
              child:
                  CircularProgressIndicator(),
            )

          : SafeArea(

              child: Column(

                children: [

                  const SizedBox(
                    height: 20,
                  ),

                  Padding(

                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),

                    child: Row(

                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,

                      children: [

                        Column(

                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: const [

                            Text(
                              "Sales",

                              style:
                                  TextStyle(
                                fontSize:
                                    28,

                                fontWeight:
                                    FontWeight
                                        .bold,

                                color:
                                    Color(
                                  0xFF1B2559,
                                ),
                              ),
                            ),

                            SizedBox(
                              height: 4,
                            ),

                            Text(
                              "Manage all your sales orders",

                              style:
                                  TextStyle(
                                color:
                                    Colors
                                        .grey,
                              ),
                            ),
                          ],
                        ),

                        Container(

                          width: 52,

                          height: 52,

                          decoration:
                              BoxDecoration(

                            color:
                                Colors
                                    .white,

                            borderRadius:
                                BorderRadius
                                    .circular(
                              16,
                            ),

                            boxShadow:
                                const [

                              BoxShadow(
                                color:
                                    Colors
                                        .black12,

                                blurRadius:
                                    10,
                              ),
                            ],
                          ),

                          child:
                              const Icon(
                            Icons
                                .point_of_sale,

                            color:
                                Colors
                                    .green,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 18,
                  ),

                  Padding(

                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),

                    child: Row(

                      children: [

                        Expanded(
                          child:
                              _buildStatCard(
                            "Sales",

                            totalSales
                                .toString(),

                            Icons
                                .receipt_long,

                            Colors.blue,
                          ),
                        ),

                        const SizedBox(
                          width: 12,
                        ),

                        Expanded(
                          child:
                              _buildStatCard(
                            "Revenue",

                            "₹${totalSalesValue.toStringAsFixed(0)}",

                            Icons
                                .currency_rupee,

                            Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(
                    height: 12,
                  ),

                  Padding(

                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),

                    child: Container(

                      padding:
                          const EdgeInsets.all(
                        18,
                      ),

                      decoration:
                          BoxDecoration(

                        color:
                            Colors.white,

                        borderRadius:
                            BorderRadius
                                .circular(
                          24,
                        ),

                        boxShadow:
                            const [

                          BoxShadow(
                            color:
                                Colors
                                    .black12,

                            blurRadius:
                                10,
                          ),
                        ],
                      ),

                      child: Row(

                        children: [

                          Container(

                            width: 58,

                            height: 58,

                            decoration:
                                BoxDecoration(

                              color:
                                  Colors
                                      .orange
                                      .shade50,

                              borderRadius:
                                  BorderRadius
                                      .circular(
                                16,
                              ),
                            ),

                            child:
                                const Icon(
                              Icons
                                  .account_balance_wallet,

                              color:
                                  Colors
                                      .orange,
                            ),
                          ),

                          const SizedBox(
                            width: 14,
                          ),

                          Expanded(

                            child: Column(

                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                              children: [

                                Text(
                                  "₹${pendingCollections.toStringAsFixed(0)}",

                                  style:
                                      const TextStyle(
                                    fontSize:
                                        22,

                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),

                                const Text(
                                  "Pending Collections",
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  Padding(

                    padding:
                        const EdgeInsets.symmetric(
                      horizontal: 20,
                    ),

                    child: TextField(

                      controller:
                          searchController,

                      onChanged:
                          (value) {

                        filterSales();
                      },

                      decoration:
                          InputDecoration(

                        hintText:
                            "Search sales...",

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
                              BorderRadius
                                  .circular(
                            16,
                          ),

                          borderSide:
                              BorderSide.none,
                        ),
                      ),
                    ),
                  ),


const SizedBox(
  height: 15,
),

Padding(

  padding:

      const EdgeInsets.symmetric(

    horizontal: 20,

  ),



  child: Row(



    children: [



      Expanded(

        child: GestureDetector(



          onTap: () async {



            final result =

                await showDateRangePicker(



              context: context,



              firstDate:

                  DateTime(2020),



              lastDate:

                  DateTime(2100),

            );



            if (result != null) {



              setState(() {

                selectedDateRange =

                    result;

              });



              filterSales();

            }

          },



          child: Container(



            height: 52,



            padding:

                const EdgeInsets.symmetric(

              horizontal: 12,

            ),



            decoration:

                BoxDecoration(



              color: Colors.white,



              borderRadius:

                  BorderRadius.circular(

                16,

              ),



              boxShadow: const [

                BoxShadow(

                  color:

                      Colors.black12,

                  blurRadius: 8,

                ),

              ],

            ),



            child: Row(



              children: [



                const Icon(

                  Icons.calendar_month,

                  color:

                      Color(0xFF2F80FF),

                ),



                const SizedBox(

                  width: 8,

                ),



                Expanded(



                  child: Text(



                    selectedDateRange ==

                            null



                        ? "Date Range"



                        : "${selectedDateRange!.start.day}/${selectedDateRange!.start.month} - ${selectedDateRange!.end.day}/${selectedDateRange!.end.month}",



                    overflow:

                        TextOverflow

                            .ellipsis,

                  ),

                ),

              ],

            ),

          ),

        ),

      ),



      const SizedBox(

        width: 12,

      ),



      Expanded(



        child: Container(



          height: 52,



          padding:

              const EdgeInsets.symmetric(

            horizontal: 12,

          ),



          decoration:

              BoxDecoration(



            color: Colors.white,



            borderRadius:

                BorderRadius.circular(

              16,

            ),



            boxShadow: const [

              BoxShadow(

                color:

                    Colors.black12,

                blurRadius: 8,

              ),

            ],

          ),



          child:

              DropdownButtonHideUnderline(



            child:

                DropdownButton<String>(



              value:

                  selectedCustomer,



              isExpanded: true,



              items:

                  customers.map(

                (customer) {



                  return DropdownMenuItem(

                    value:

                        customer,



                    child: Text(

                      customer,

                    ),

                  );

                },

              ).toList(),



              onChanged:

                  (value) {



                if (value == null)

                  return;



                selectedCustomer =

                    value;



                filterSales();

              },

            ),

          ),

        ),

      ),

    ],

  ),

),





const SizedBox(
  height: 24,
),
Padding(

  padding:
      const EdgeInsets.symmetric(
    horizontal: 20,
  ),

  child: Row(

    mainAxisAlignment:
        MainAxisAlignment
            .spaceBetween,

            

    children: const [
      

      Text(
        "Recent Sales",

        style: TextStyle(
          fontSize: 20,
          fontWeight:
              FontWeight.bold,
          color:
              Color(0xFF1B2559),
        ),
      ),

      Text(
        "View All",

        style: TextStyle(
          color:
              Color(0xFF10B981),
          fontWeight:
              FontWeight.w600,
        ),
      ),
    ],
  ),
),

const SizedBox(
  height: 16,
),
                  
                  Expanded(
  child: filteredSales.isEmpty

      ? const Center(
          child: Text(
            "No Sales Found",
          ),
        )

      : ListView.builder(

          padding: const EdgeInsets.only(
            left: 20,
            right: 20,
            bottom: 100,
          ),

          itemCount:
              filteredSales.length,

          itemBuilder:
              (context, index) {

            final sale =
                filteredSales[index];

            final bool isPaid =
                sale.paymentStatus ==
                    "Paid";

            return GestureDetector(

  onTap: () {

    Navigator.push(
      context,

      MaterialPageRoute(
        builder: (_) =>
            SaleDetailsScreen(
          sale: sale,
        ),
      ),
    );
  },

  child: Container(
  

              margin:
                  const EdgeInsets.only(
                bottom: 16,
              ),

              padding:
                  const EdgeInsets.all(
                18,
              ),

              decoration:
                  BoxDecoration(

                color: Colors.white,

                borderRadius:
                    BorderRadius.circular(
                  24,
                ),

                boxShadow: const [

                  BoxShadow(
                    color:
                        Colors.black12,

                    blurRadius: 12,

                    offset:
                        Offset(0, 4),
                  ),
                ],
              ),
  

              child: Column(

                children: [

                  // TOP SECTION

                  Row(

                    children: [

                      Container(

                        width: 56,

                        height: 56,

                        decoration:
                            BoxDecoration(

                          color:
                              const Color(
                            0xFFE8FFF1,
                          ),

                          borderRadius:
                              BorderRadius
                                  .circular(
                            16,
                          ),
                        ),

                        child: Center(

                          child: Text(

                            sale.customerName
                                    .isNotEmpty
                                ? sale.customerName[
                                        0]
                                    .toUpperCase()
                                : "C",

                            style:
                                const TextStyle(

                              fontSize: 24,

                              fontWeight:
                                  FontWeight
                                      .bold,

                              color:
                                  Colors
                                      .green,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(
                        width: 14,
                      ),

                      Expanded(

                        child: Column(

                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,

                          children: [

                            Text(

                              sale.customerName,

                              style:
                                  const TextStyle(

                                fontSize: 17,

                                fontWeight:
                                    FontWeight
                                        .bold,

                                color:
                                    Color(
                                  0xFF1B2559,
                                ),
                              ),
                            ),

                            const SizedBox(
                              height: 4,
                            ),

                            Text(

                              sale.saleNumber,

                              style:
                                  const TextStyle(

                                color:
                                    Colors
                                        .grey,

                                fontSize:
                                    13,
                              ),
                            ),
                          ],
                        ),
                      ),
                  

                      Container(

                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),

                        decoration:
                            BoxDecoration(

                          color: isPaid

                              ? Colors
                                  .green
                                  .shade50

                              : Colors
                                  .orange
                                  .shade50,

                          borderRadius:
                              BorderRadius
                                  .circular(
                            20,
                          ),
                        ),

                        child: Text(

                          sale.paymentStatus,

                          style:
                              TextStyle(

                            color: isPaid

                                ? Colors
                                    .green

                                : Colors
                                    .orange,

                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  const Divider(),

                  const SizedBox(
                    height: 12,
                  ),

                  // DETAILS

                  Row(

                    children: [

                      Expanded(

                        child: Row(

                          children: [

                            Container(

                              padding:
                                  const EdgeInsets
                                      .all(
                                8,
                              ),

                              decoration:
                                  BoxDecoration(

                                color:
                                    const Color(
                                  0xFFEAF2FF,
                                ),

                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  10,
                                ),
                              ),

                              child:
                                  const Icon(

                                Icons
                                    .inventory_2_outlined,

                                size: 18,

                                color:
                                    Color(
                                  0xFF2F80FF,
                                ),
                              ),
                            ),

                            const SizedBox(
                              width: 10,
                            ),

                            Column(

                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                              children: [

                                Text(

                                  sale.itemCount
                                      .toString(),

                                  style:
                                      const TextStyle(
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),

                                const Text(

                                  "Items",

                                  style:
                                      TextStyle(

                                    color:
                                        Colors
                                            .grey,

                                    fontSize:
                                        12,
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

                              padding:
                                  const EdgeInsets
                                      .all(
                                8,
                              ),

                              decoration:
                                  BoxDecoration(

                                color:
                                    const Color(
                                  0xFFE9F8EE,
                                ),

                                borderRadius:
                                    BorderRadius
                                        .circular(
                                  10,
                                ),
                              ),

                              child:
                                  const Icon(

                                Icons
                                    .currency_rupee,

                                size: 18,

                                color:
                                    Colors
                                        .green,
                              ),
                            ),

                            const SizedBox(
                              width: 10,
                            ),

                            Column(

                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,

                              children: [

                                Text(

                                  "₹${sale.totalAmount.toStringAsFixed(0)}",

                                  style:
                                      const TextStyle(
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),

                                const Text(

                                  "Amount",

                                  style:
                                      TextStyle(

                                    color:
                                        Colors
                                            .grey,

                                    fontSize:
                                        12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  Row(

                    children: [

                      const Icon(

                        Icons
                            .calendar_month,

                        size: 18,

                        color:
                            Colors.grey,
                      ),

                      const SizedBox(
                        width: 6,
                      ),

                      Text(

                        "${sale.saleDate.day}/${sale.saleDate.month}/${sale.saleDate.year}",

                        style:
                            const TextStyle(
                          color:
                              Colors.grey,
                        ),
                      ),

                      const Spacer(),

                      const Icon(

                        Icons
                            .arrow_forward_ios,

                        size: 16,

                        color:
                            Colors.green,
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
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) 
  {

    return Container(

      padding:
          const EdgeInsets.all(18),

      decoration:
          BoxDecoration(

        color: Colors.white,

        borderRadius:
            BorderRadius.circular(
          24,
        ),

        boxShadow: const [

          BoxShadow(
            color:
                Colors.black12,

            blurRadius: 10,
          ),
        ],
      ),

      child: Column(

        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Icon(
            icon,
            color: color,
          ),

          const SizedBox(
            height: 14,
          ),

          Text(
            value,

            style:
                const TextStyle(
              fontSize: 20,

              fontWeight:
                  FontWeight.bold,
            ),
          ),

          const SizedBox(
            height: 4,
          ),

          Text(
            title,
          ),
        ],
      ),
    );
    
  }
}