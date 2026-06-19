import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/purchase_item_model.dart';
import '../models/customer_model.dart';

import '../services/product_service.dart';
import '../services/customer_service.dart';
import '../services/sale_service.dart';
class AddSaleScreen extends StatefulWidget {
  const AddSaleScreen({super.key});

  @override
  State<AddSaleScreen> createState() => _AddSaleScreenState();
}

class _AddSaleScreenState extends State<AddSaleScreen> {
  bool isLoading = true;

  // DATA

  List<Product> products = [];

  List<Customer> customers = [];

  List<PurchaseItem> items = [];

  // SELECTED Customer

  Customer? selectedCustomer;

  // CONTROLLERS

  final notesController = TextEditingController();

  final advancePaymentController = TextEditingController(text: "0");

  final discountController = TextEditingController(text: "0");

  final gstController = TextEditingController(text: "0");

  final transportController = TextEditingController(text: "0");

  final contactPersonController = TextEditingController();

  final phoneController = TextEditingController();

  final paymentTermsController = TextEditingController();

  // DATES

  DateTime saleDate = DateTime.now();

  DateTime? deliveryDate;

  // Sale NUMBER

  late String saleNumber;

  @override
  void initState() {
    super.initState();

    generateSaleNumber();

    loadData();
  }

  void generateSaleNumber() {
    final now = DateTime.now();

    saleNumber =
        "SAL${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour}${now.minute}";
  }

  Future<void> loadData() async {
    try {
      products = await ProductService().getProducts();

      customers = await CustomerService().getCustomers();

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });

      debugPrint(e.toString());
    }
  }

  // PRODUCT ROW

  Future<void> addItem() async {
    final Product? selectedProduct = await showModalBottomSheet<Product>(
      context: context,

      isScrollControlled: true,

      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),

      builder: (context) {
        return ListView.builder(
          shrinkWrap: true,

          itemCount: products.length,

          itemBuilder: (context, index) {
            final product = products[index];

            return ListTile(
              title: Text(product.name),

              subtitle: Text(product.sku),

              trailing: Text("₹${product.sellingPrice}"),
              onTap: () {
                Navigator.pop(context, product);
              },
            );
          },
        );
      },
    );

    if (selectedProduct == null) {
      return;
    }

    setState(() {
      final item = PurchaseItem(
        productId: selectedProduct.id,
        productName: selectedProduct.name,
        sku: selectedProduct.sku,

        unit: selectedProduct.unit,

        quantity: 1,
        rate: selectedProduct.sellingPrice,
        amount: selectedProduct.sellingPrice,
      );
      item.calculateAmount();

      items.add(item);
    });
  }

  void removeItem(int index) {
    setState(() {
      items.removeAt(index);
    });
  }

  // CALCULATIONS

  double get subtotal {
    double total = 0;

    for (final item in items) {
      total += item.amount;
    }

    return total;
  }

  double get discount {
    return double.tryParse(discountController.text) ?? 0;
  }

  double get gst {
    return double.tryParse(gstController.text) ?? 0;
  }

  double get transportCharges {
    return double.tryParse(transportController.text) ?? 0;
  }

  double get advancePayment {
    return double.tryParse(advancePaymentController.text) ?? 0;
  }

  double get grandTotal {
    return subtotal - discount + gst + transportCharges;
  }

  double get balanceDue {
    return grandTotal - advancePayment;
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FC),

      bottomNavigationBar: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 15),

        decoration: const BoxDecoration(
          color: Colors.white,

          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),

          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 12)],
        ),

        child: SafeArea(
          top: false,

          child: Row(
            children: [
              // LEFT SUMMARY
              Expanded(
                flex: 1,

                child: Row(
                  children: [
                    Container(
                      width: 68,
                      height: 68,

                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FC),
                        borderRadius: BorderRadius.circular(31),
                      ),

                      child: const Icon(
                        Icons.shopping_cart_outlined,
                        color: Color(0xFF1B2559),
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [
                          Text(
                            "${items.length} Items",

                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 30,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            "Sub Total   ₹${subtotal.toStringAsFixed(0)}",

                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 16,
                            ),
                          ),

                          Text(
                            "Tax (GST)   ₹${gst.toStringAsFixed(0)}",

                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              Container(width: 1, height: 70, color: Colors.grey.shade300),

              const SizedBox(width: 16),

              // RIGHT SIDE
              Expanded(
                flex: 1,

                child: Padding(
                  padding: const EdgeInsets.only(top: 8),

                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      const Text(
                        "Total Amount",

                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF1B2559),
                        ),
                      ),

                      const SizedBox(height: 4),

                      Text(
                        "₹${grandTotal.toStringAsFixed(2)}",

                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F9D94),
                        ),
                      ),

                      const SizedBox(height: 8),

                      SizedBox(
                        width: double.infinity,
                        height: 48,

                        child: ElevatedButton(
                          onPressed: () async {
                            if (selectedCustomer == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Please select customer"),
                                ),
                              );
                              return;
                            }

                            if (items.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Please add products"),
                                ),
                              );
                              return;
                            }

                            await SaleService().createSale(
                              saleNumber: saleNumber,
                              customerName: selectedCustomer!.customerName,
                              items: items.map((e) => e.toJson()).toList(),
                              totalAmount: grandTotal,
                              paymentStatus: "Pending",
                            );

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Sales Order Created"),
                              ),
                            );

                            Navigator.pop(context);
                          },

                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF143D7A),

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),

                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,

                            children: [
                              Expanded(
                                child: Text(
                                  "Place Order",

                                  textAlign: TextAlign.center,

                                  overflow: TextOverflow.ellipsis,

                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),

                              SizedBox(width: 8),

                              CircleAvatar(
                                radius: 10,
                                backgroundColor: Colors.white,

                                child: Icon(
                                  Icons.arrow_forward,
                                  size: 14,
                                  color: Color(0xFF143D7A),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),

        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },

                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Color(0xFF1B2559),
                  ),
                ),

                const SizedBox(width: 2),

                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,

                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      const Text(
                        "New Sale",

                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B2559),
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        "Create a new Sale order",

                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),

                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE1E8F5)),

                    borderRadius: BorderRadius.circular(16),
                  ),

                  child: Row(
                    children: const [
                      Icon(
                        Icons.description_outlined,
                        size: 18,
                        color: Color(0xFF2F80FF),
                      ),

                      SizedBox(width: 8),

                      Text(
                        "Draft",

                        style: TextStyle(
                          color: Color(0xFF2F80FF),
                          fontWeight: FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),

                IconButton(
                  onPressed: () {},

                  icon: const Icon(Icons.more_vert, color: Color(0xFF1B2559)),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),

                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 10),
                ],
              ),

              child: Column(
                children: [
                  // Customer HEADER
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Container(
                        width: 70,
                        height: 70,

                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F7F5),

                          borderRadius: BorderRadius.circular(35),
                        ),

                        child: const Icon(
                          Icons.person_outline,
                          size: 30,
                          color: Color(0xFF0F766E),
                        ),
                      ),

                      const SizedBox(width: 16),

                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,

                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Text(
                              selectedCustomer?.customerName ??
                                  "Select Customer",

                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1B2559),
                              ),
                            ),

                            const SizedBox(height: 1),

                            Text(
                              selectedCustomer?.phone ?? "",

                              style: const TextStyle(color: Colors.grey),
                            ),

                            const SizedBox(height: 4),

                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),

                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF4E5),

                                borderRadius: BorderRadius.circular(10),
                              ),

                              child: Text(
                                "Opening Balance: ₹${selectedCustomer?.openingBalance.toStringAsFixed(0) ?? "0"}",

                                style: const TextStyle(
                                  color: Colors.orange,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      OutlinedButton.icon(
                        onPressed: () async {
                          final customer = await showModalBottomSheet<Customer>(
                            context: context,

                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(24),
                              ),
                            ),

                            builder: (_) {
                              return ListView.builder(
                                itemCount: customers.length,

                                itemBuilder: (context, index) {
                                  final s = customers[index];

                                  return ListTile(
                                    title: Text(s.customerName),

                                    subtitle: Text(s.phone),

                                    onTap: () {
                                      Navigator.pop(context, s);
                                    },
                                  );
                                },
                              );
                            },
                          );

                          if (customer != null) {
                            setState(() {
                              selectedCustomer = customer;

                              contactPersonController.text =
                                  customer.contactPerson;

                              phoneController.text = customer.phone;

                              paymentTermsController.text = "Cash";
                            });
                          }
                        },

                        icon: const Icon(Icons.edit_outlined, size: 12),

                        label: const Text("Change"),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  const Divider(height: 1),

                  const SizedBox(height: 8),

                  // DATE + PAYMENT ROW
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,

                              initialDate: saleDate,

                              firstDate: DateTime(2024),

                              lastDate: DateTime(2035),
                            );

                            if (picked != null) {
                              setState(() {
                                saleDate = picked;
                              });
                            }
                          },

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              const Text(
                                "Sale Date",

                                style: TextStyle(color: Colors.grey),
                              ),

                              const SizedBox(height: 8),

                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_month_outlined,
                                    size: 20,
                                  ),

                                  const SizedBox(width: 8),

                                  Text(
                                    "${saleDate.day}/${saleDate.month}/${saleDate.year}",
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      Container(
                        width: 1,
                        height: 50,
                        color: Colors.grey.shade300,
                      ),

                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,

                              initialDate: deliveryDate ?? DateTime.now(),

                              firstDate: DateTime(2024),

                              lastDate: DateTime(2035),
                            );

                            if (picked != null) {
                              setState(() {
                                deliveryDate = picked;
                              });
                            }
                          },

                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                const Text(
                                  "Delivery Date",

                                  style: TextStyle(color: Colors.grey),
                                ),

                                const SizedBox(height: 8),

                                Row(
                                  children: [
                                    const Icon(Icons.person_outline, size: 20),

                                    const SizedBox(width: 8),

                                    Text(
                                      deliveryDate == null
                                          ? "Select"
                                          : "${deliveryDate!.day}/${deliveryDate!.month}/${deliveryDate!.year}",
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      Container(
                        width: 1,
                        height: 50,
                        color: Colors.grey.shade300,
                      ),

                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 12),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              const Text(
                                "Payment Terms",

                                style: TextStyle(color: Colors.grey),
                              ),

                              const SizedBox(height: 8),

                              Text(
                                paymentTermsController.text.isEmpty
                                    ? "Cash"
                                    : paymentTermsController.text,
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

            // PRODUCTS CARD
            Container(
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(24),

                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 10),
                ],
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const Text(
                    "Products",

                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B2559),
                    ),
                  ),

                  const SizedBox(height: 16),

                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Search products...",

                            prefixIcon: const Icon(Icons.search),

                            filled: true,

                            fillColor: Colors.white,

                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                            ),

                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),

                              borderSide: const BorderSide(
                                color: Color(0xFFE2E8F0),
                              ),
                            ),

                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),

                              borderSide: const BorderSide(
                                color: Color(0xFF2F80FF),
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),
                      SizedBox(
                        width: 130,
                        height: 54,

                        child: Container(
                          height: 54,

                          decoration: BoxDecoration(
                            color: const Color(0xFF2F80FF),

                            borderRadius: BorderRadius.circular(16),
                          ),

                          child: Material(
                            color: Colors.transparent,

                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),

                              onTap: addItem,

                              child: const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 18),

                                child: Row(
                                  children: [
                                    Icon(Icons.add, color: Colors.white),

                                    SizedBox(width: 8),

                                    Text(
                                      "Add Item",

                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  if (items.isEmpty)
                    Container(
                      height: 180,
                      width: double.infinity,

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),

                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,

                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 48,
                            color: Colors.grey.shade400,
                          ),

                          const SizedBox(height: 12),

                          const Text(
                            "No Products Added",

                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            "Tap Add to start building this order",

                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                        ],
                      ),
                    ),

                  if (items.isNotEmpty)
                    ...List.generate(items.length, (index) {
                      final item = items[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),

                        padding: const EdgeInsets.all(14),

                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 8),
                          ],
                        ),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,

                                    children: [
                                      Text(
                                        item.productName,

                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          height: 1.0,
                                        ),
                                      ),

                                      const SizedBox(height: 1),

                                      Row(
                                        children: [
                                          Text(
                                            "Code: ${item.sku}",

                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 13,
                                            ),
                                          ),

                                          const SizedBox(width: 8),

                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 3,
                                            ),

                                            decoration: BoxDecoration(
                                              color: const Color(0xFFEAF2FF),

                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                        ],
                                      ),

                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,

                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 12,
                                              vertical: 10,
                                            ),

                                            decoration: BoxDecoration(
                                              color: const Color(0xFFEAF2FF),

                                              borderRadius:
                                                  BorderRadius.circular(12),

                                              border: Border.all(
                                                color: const Color(0xFFD6E7FF),
                                              ),
                                            ),

                                            child: Text(
                                              "Total: ₹${item.amount.toStringAsFixed(2)}",

                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFF2F80FF),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                Column(
                                  children: [
                                    SizedBox(
                                      width: 140,

                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,

                                        children: [
                                          // MINUS BUTTON
                                          Container(
                                            width: 36,
                                            height: 36,

                                            decoration: BoxDecoration(
                                              color: Colors.white,

                                              borderRadius:
                                                  BorderRadius.circular(10),

                                              border: Border.all(
                                                color: const Color(0xFFE2E8F0),
                                              ),
                                            ),

                                            child: IconButton(
                                              padding: EdgeInsets.zero,

                                              onPressed: () {
                                                if (item.quantity > 1) {
                                                  setState(() {
                                                    item.quantity--;
                                                    item.calculateAmount();
                                                  });
                                                }
                                              },

                                              icon: const Icon(
                                                Icons.remove,
                                                size: 18,
                                                color: Color(0xFF1B2559),
                                              ),
                                            ),
                                          ),

                                          // QUANTITY
                                          SizedBox(
                                            width: 55,

                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,

                                              children: [
                                                TextFormField(
                                                  initialValue: item.quantity
                                                      .toString(),

                                                  textAlign: TextAlign.center,

                                                  keyboardType:
                                                      TextInputType.number,

                                                  decoration:
                                                      const InputDecoration(
                                                        isDense: true,
                                                        border:
                                                            InputBorder.none,
                                                        contentPadding:
                                                            EdgeInsets.zero,
                                                      ),

                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color(0xFF1B2559),
                                                  ),

                                                  onChanged: (value) {
                                                    item.quantity =
                                                        int.tryParse(value) ??
                                                        1;

                                                    setState(() {
                                                      item.calculateAmount();
                                                    });
                                                  },
                                                ),

                                                Text(
                                                  item.unit.isEmpty
                                                      ? "PCS"
                                                      : item.unit,

                                                  style: const TextStyle(
                                                    fontSize: 12,
                                                    color: Colors.grey,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),

                                          // PLUS BUTTON
                                          Container(
                                            width: 40,
                                            height: 40,

                                            decoration: BoxDecoration(
                                              color: Colors.white,

                                              borderRadius:
                                                  BorderRadius.circular(10),

                                              border: Border.all(
                                                color: const Color(0xFFE2E8F0),
                                              ),
                                            ),

                                            child: IconButton(
                                              padding: EdgeInsets.zero,

                                              onPressed: () {
                                                setState(() {
                                                  item.quantity++;
                                                  item.calculateAmount();
                                                });
                                              },

                                              icon: const Icon(
                                                Icons.add,
                                                size: 18,
                                                color: Color(0xFF1B2559),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 8),

                                    IconButton(
                                      onPressed: () {
                                        removeItem(index);
                                      },

                                      icon: const Icon(
                                        Icons.delete_outline,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),

                            // PRICE + DELETE
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),

            // NOTES CARD
            const SizedBox(height: 20),

            Container(
              padding: const EdgeInsets.all(20),

              decoration: BoxDecoration(
                color: Colors.white,

                borderRadius: BorderRadius.circular(20),

                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 8),
                ],
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const Text(
                    "Sale Notes",

                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1B2559),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: notesController,

                    maxLines: 1,

                    decoration: InputDecoration(
                      hintText: "Add notes for Customer...",

                      filled: true,

                      fillColor: const Color(0xFFF8FAFC),

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),

                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),

                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),

                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),

                        borderSide: const BorderSide(
                          color: Color(0xFF2F80FF),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ), // Main Column
      ), // SingleChildScrollView
      // body
      // Scaffold
    );
  } // build

  Widget _summaryRow(String title, double value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          Text(
            title,

            style: TextStyle(
              fontSize: isBold ? 16 : 14,

              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),

          Text(
            "₹${value.toStringAsFixed(2)}",

            style: TextStyle(
              fontSize: isBold ? 16 : 14,

              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    notesController.dispose();

    advancePaymentController.dispose();

    discountController.dispose();

    gstController.dispose();

    transportController.dispose();

    contactPersonController.dispose();

    phoneController.dispose();

    paymentTermsController.dispose();

    super.dispose();
  }
}
