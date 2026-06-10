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

  void addItem() {
    setState(() {
      items.add(
        PurchaseItem(
          productId: "",
          productName: "",
          sku: "",
          quantity: 1,
          rate: 0,
          amount: 0,
        ),
      );
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

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,

        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF1B2559)),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

        title: const Text(
          "New Purchase Order",

          style: TextStyle(
            color: Color(0xFF1B2559),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          children: [
            // PURCHASE NUMBER CARD
            Container(
              width: double.infinity,

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
                    padding: const EdgeInsets.all(12),

                    decoration: BoxDecoration(
                      color: const Color(0xFFEAF2FF),

                      borderRadius: BorderRadius.circular(14),
                    ),

                    child: const Icon(
                      Icons.receipt_long,
                      color: Color(0xFF2F80FF),
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        const Text(
                          "Purchase Number",

                          style: TextStyle(color: Colors.grey),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          purchaseNumber,

                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,

                            color: Color(0xFF1B2559),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // SUPPLIER DETAILS CARD
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
                    "Supplier Details",

                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,

                      color: Color(0xFF1B2559),
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    children: [
                      Expanded(
                        child: DropdownButtonFormField<Supplier>(
                          value: selectedSupplier,

                          decoration: InputDecoration(
                            labelText: "Supplier",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),

                          items: suppliers.map((supplier) {
                            return DropdownMenuItem(
                              value: supplier,
                              child: Text(supplier.supplierName),
                            );
                          }).toList(),

                          onChanged: (supplier) {
                            setState(() {
                              selectedSupplier = supplier;

                              contactPersonController.text =
                                  supplier?.contactPerson ?? "";

                              phoneController.text = supplier?.phone ?? "";

                              paymentTermsController.text =
                                  supplier?.paymentTerms ?? "";
                            });
                          },
                        ),
                      ),

                      const SizedBox(width: 10),

                      SizedBox(
                        width: 56,
                        height: 56,

                        child: ElevatedButton(
                          onPressed: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AddSupplierScreen(),
                              ),
                            );

                            await loadData();
                          },

                          child: const Icon(Icons.add),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: contactPersonController,

                    decoration: InputDecoration(
                      labelText: "Contact Person",

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextFormField(
                    controller: paymentTermsController,

                    decoration: InputDecoration(
                      labelText: "Payment Terms",

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

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

                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: "Purchase Date",

                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),

                            child: Text(
                              "${purchaseDate.day}/${purchaseDate.month}/${purchaseDate.year}",
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: InkWell(
                          onTap: () async {
                            final picked = await showDatePicker(
                              context: context,

                              initialDate: DateTime.now(),

                              firstDate: DateTime(2024),

                              lastDate: DateTime(2035),
                            );

                            if (picked != null) {
                              setState(() {
                                deliveryDate = picked;
                              });
                            }
                          },

                          child: InputDecorator(
                            decoration: InputDecoration(
                              labelText: "Delivery Date",

                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),

                            child: Text(
                              deliveryDate == null
                                  ? "Select"
                                  : "${deliveryDate!.day}/${deliveryDate!.month}/${deliveryDate!.year}",
                            ),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      const Text(
                        "Products",

                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,

                          color: Color(0xFF1B2559),
                        ),
                      ),

                      ElevatedButton.icon(
                        onPressed: addItem,

                        icon: const Icon(Icons.add),

                        label: const Text("Add Item"),

                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2F80FF),

                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  if (items.isEmpty)
                    Container(
                      width: double.infinity,

                      padding: const EdgeInsets.all(20),

                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,

                        borderRadius: BorderRadius.circular(16),
                      ),

                      child: const Center(child: Text("No Products Added")),
                    ),

                  ...List.generate(items.length, (index) {
                    final item = items[index];

                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),

                      padding: const EdgeInsets.all(16),

                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),

                        borderRadius: BorderRadius.circular(16),
                      ),

                      child: Column(
                        children: [
                          DropdownButtonFormField<Product>(
                            value: item.productId.isEmpty
                                ? null
                                : products.firstWhere(
                                    (p) => p.id == item.productId,
                                  ),

                            decoration: InputDecoration(
                              labelText: "Product",

                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),

                            items: products.map((product) {
                              return DropdownMenuItem(
                                value: product,

                                child: Text(product.name),
                              );
                            }).toList(),

                            onChanged: (product) {
                              if (product == null) {
                                return;
                              }

                              setState(() {
                                item.productId = product.id;

                                item.productName = product.name;

                                item.sku = product.sku;

                                item.rate = product.purchasePrice;

                                item.calculateAmount();
                              });
                            },
                          ),
                          const SizedBox(height: 14),

                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: item.sku,

                                  readOnly: true,

                                  decoration: InputDecoration(
                                    labelText: "SKU",

                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: TextFormField(
                                  initialValue: item.rate.toString(),

                                  keyboardType: TextInputType.number,

                                  decoration: InputDecoration(
                                    labelText: "Rate",

                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),

                                  onChanged: (value) {
                                    item.rate = double.tryParse(value) ?? 0;

                                    setState(() {
                                      item.calculateAmount();
                                    });
                                  },
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  initialValue: item.quantity.toString(),

                                  keyboardType: TextInputType.number,

                                  decoration: InputDecoration(
                                    labelText: "Quantity",

                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),

                                  onChanged: (value) {
                                    item.quantity = int.tryParse(value) ?? 1;

                                    setState(() {
                                      item.calculateAmount();
                                    });
                                  },
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 18,
                                  ),

                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF5F7FC),

                                    borderRadius: BorderRadius.circular(16),
                                  ),

                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,

                                    children: [
                                      const Text(
                                        "Amount",

                                        style: TextStyle(color: Colors.grey),
                                      ),

                                      const SizedBox(height: 4),

                                      Text(
                                        "₹${item.amount.toStringAsFixed(2)}",

                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,

                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 14),

                          Align(
                            alignment: Alignment.centerRight,

                            child: TextButton.icon(
                              onPressed: () {
                                removeItem(index);
                              },

                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),

                              label: const Text(
                                "Remove Item",

                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // NOTES CARD
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
                    "Purchase Notes",

                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: notesController,

                    maxLines: 4,

                    decoration: InputDecoration(
                      hintText: "Add notes for supplier...",

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // PAYMENT SUMMARY
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
                    "Payment Summary",

                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: advancePaymentController,

                    keyboardType: TextInputType.number,

                    onChanged: (_) {
                      setState(() {});
                    },

                    decoration: InputDecoration(
                      labelText: "Advance Payment",

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: discountController,

                    keyboardType: TextInputType.number,

                    onChanged: (_) {
                      setState(() {});
                    },

                    decoration: InputDecoration(
                      labelText: "Discount",

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: gstController,

                    keyboardType: TextInputType.number,

                    onChanged: (_) {
                      setState(() {});
                    },

                    decoration: InputDecoration(
                      labelText: "GST",

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  TextField(
                    controller: transportController,

                    keyboardType: TextInputType.number,

                    onChanged: (_) {
                      setState(() {});
                    },

                    decoration: InputDecoration(
                      labelText: "Transport Charges",

                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ORDER SUMMARY
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
                children: [
                  _summaryRow("Subtotal", subtotal),

                  _summaryRow("Discount", discount),

                  _summaryRow("GST", gst),

                  _summaryRow("Transport", transportCharges),

                  const Divider(),

                  _summaryRow("Grand Total", grandTotal, isBold: true),

                  _summaryRow("Advance Paid", advancePayment),

                  const Divider(),

                  _summaryRow("Balance Due", balanceDue, isBold: true),
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
                          const SnackBar(content: Text("Please add products")),
                        );

                        return;
                      }
await PurchaseService().createPurchase(
  purchaseNumber: purchaseNumber,

  supplierName:
      selectedSupplier!.supplierName,

  items: items
      .map(
        (item) => item.toJson(),
      )
      .toList(),

  totalAmount: grandTotal,

  paymentStatus: "Pending",
);// BACKEND SAVE WILL BE CONNECTED HERE

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Purchase Order Created")),
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
        ),
      ),
    );
  }

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
