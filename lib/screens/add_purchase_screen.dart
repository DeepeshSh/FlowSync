import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/supplier_model.dart';
import '../models/purchase_item_model.dart';
import 'add_supplier_screen.dart';
import '../services/product_service.dart';
import '../services/supplier_service.dart';
import '../services/purchase_service.dart';

class AddPurchaseScreen extends StatefulWidget {
  const AddPurchaseScreen({super.key});

  @override
  State<AddPurchaseScreen> createState() => _AddPurchaseScreenState();
}

class _AddPurchaseScreenState extends State<AddPurchaseScreen> {
  bool isLoading = true;

  // DATA

  List<Product> products = [];

  List<Supplier> suppliers = [];

  List<PurchaseItem> items = [];

  // SELECTED SUPPLIER

  Supplier? selectedSupplier;

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

  DateTime purchaseDate = DateTime.now();

  DateTime? deliveryDate;

  // PURCHASE NUMBER

  late String purchaseNumber;

  @override
  void initState() {
    super.initState();

    generatePurchaseNumber();

    loadData();
  }

  void generatePurchaseNumber() {
    final now = DateTime.now();

    purchaseNumber =
        "PUR${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour}${now.minute}";
  }

  Future<void> loadData() async {
    try {
      products = await ProductService().getProducts();

      suppliers = await SupplierService().getSuppliers();

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

              trailing: Text("₹${product.purchasePrice}"),

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

        quantity: 1,

        rate: selectedProduct.purchasePrice,

        amount: selectedProduct.purchasePrice,
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
                        "New Purchase",

                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B2559),
                        ),
                      ),

                      const SizedBox(height: 2),

                      Text(
                        "Create a new purchase order",

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
            const SizedBox(height: 20),
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
                  // SUPPLIER HEADER
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
                          Icons.local_shipping_outlined,
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
                              selectedSupplier?.supplierName ??
                                  "Select Supplier",

                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1B2559),
                              ),
                            ),

                            const SizedBox(height: 1),

                            Text(
                              selectedSupplier?.phone ?? "",

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
                                "Opening Balance: ₹${selectedSupplier?.openingBalance.toStringAsFixed(0) ?? "0"}",

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
                          final supplier = await showModalBottomSheet<Supplier>(
                            context: context,

                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(24),
                              ),
                            ),

                            builder: (_) {
                              return ListView.builder(
                                itemCount: suppliers.length,

                                itemBuilder: (context, index) {
                                  final s = suppliers[index];

                                  return ListTile(
                                    title: Text(s.supplierName),

                                    subtitle: Text(s.phone),

                                    onTap: () {
                                      Navigator.pop(context, s);
                                    },
                                  );
                                },
                              );
                            },
                          );

                          if (supplier != null) {
                            setState(() {
                              selectedSupplier = supplier;

                              contactPersonController.text =
                                  supplier.contactPerson;

                              phoneController.text = supplier.phone;

                              paymentTermsController.text =
                                  supplier.paymentTerms;
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

                              initialDate: purchaseDate,

                              firstDate: DateTime(2024),

                              lastDate: DateTime(2035),
                            );

                            if (picked != null) {
                              setState(() {
                                purchaseDate = picked;
                              });
                            }
                          },

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              const Text(
                                "Purchase Date",

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
                                    "${purchaseDate.day}/${purchaseDate.month}/${purchaseDate.year}",
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
                                    const Icon(
                                      Icons.local_shipping_outlined,
                                      size: 20,
                                    ),

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
      BoxShadow(
        color: Colors.black12,
        blurRadius: 8,
      ),
    ],
  ),

 child: Column(
  crossAxisAlignment: CrossAxisAlignment.start,
         
          children: [

            Text(
              item.productName,

              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 4),

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
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),

                  decoration: BoxDecoration(
                    color:
                        const Color(0xFFEAF2FF),

                    borderRadius:
                        BorderRadius.circular(
                      8,
                    ),
                  ),

                  child: const Text(
                    "Product",
                    style: TextStyle(
                      fontSize: 11,
                      color:
                          Color(0xFF2F80FF),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              "₹${item.rate.toStringAsFixed(2)} / piece",

              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [

                Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color:
                          const Color(
                        0xFFE2E8F0,
                      ),
                    ),

                    borderRadius:
                        BorderRadius.circular(
                      12,
                    ),
                  ),

                  child: Row(
                    children: [

                      IconButton(
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
                        ),
                      ),

                      Text(
                        item.quantity.toString(),
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      IconButton(
                        onPressed: () {
                          setState(() {
                            item.quantity++;
                            item.calculateAmount();
                          });
                        },

                        icon:
                            const Icon(Icons.add),
                      ),
                    ],
                  ),
                ),

                const Spacer(),

                Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.end,

                  children: [

                    Text(
                      "₹${item.amount.toStringAsFixed(2)}",

                      style:
                          const TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

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
      BoxShadow(
        color: Colors.black12,
        blurRadius: 8,
      ),
    ],
  ),

  child: Column(
    crossAxisAlignment:
        CrossAxisAlignment.start,

    children: [

      const Text(
        "Purchase Notes",

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
          hintText:
              "Add notes for supplier...",

          filled: true,

          fillColor:
              const Color(0xFFF8FAFC),

          border: OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              16,
            ),
          ),

          enabledBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              16,
            ),

            borderSide:
                const BorderSide(
              color:
                  Color(0xFFE2E8F0),
            ),
          ),

          focusedBorder:
              OutlineInputBorder(
            borderRadius:
                BorderRadius.circular(
              16,
            ),

            borderSide:
                const BorderSide(
              color:
                  Color(0xFF2F80FF),
              width: 1.5,
            ),
          ),
        ),
      ),
    ],
  ),
),
                  

                           const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () async {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("Draft Saved")),
                            );
                          },

                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 55),

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),

                          child: const Text("Save Draft"),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        flex: 2,

                        child: ElevatedButton(
                          onPressed: () async {
                            if (selectedSupplier == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Please select supplier"),
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
                            await PurchaseService().createPurchase(
                              purchaseNumber: purchaseNumber,

                              supplierName: selectedSupplier!.supplierName,

                              items: items
                                  .map((item) => item.toJson())
                                  .toList(),

                              totalAmount: grandTotal,

                              paymentStatus: "Pending",
                            ); // BACKEND SAVE WILL BE CONNECTED HERE

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Purchase Order Created"),
                              ),
                            );

                            Navigator.pop(context);
                          },

                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2F80FF),

                            foregroundColor: Colors.white,

                            minimumSize: const Size(double.infinity, 55),

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),

                          child: const Text("Review & Place Order"),
                        ),
                      ),
                    ],
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
