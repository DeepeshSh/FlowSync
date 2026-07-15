import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/product_model.dart';
import '../models/customer_model.dart';
import '../models/purchase_item_model.dart'; // Reusing your model for item list lines
import '../services/product_service.dart';
import '../services/customer_service.dart';
import '../services/sale_service.dart';

class AddSaleScreen extends StatefulWidget {
  const AddSaleScreen({super.key});

  @override
  State<AddSaleScreen> createState() => _AddSaleScreenState();
}

class _AddSaleScreenState extends State<AddSaleScreen> {
  // STATE FLAGS
  bool isLoading = true;
  bool isSaving = false;
  String currentStatus = "Draft";

  // DATA STORAGE
  List<Product> products = [];
  List<Customer> customers = [];
  List<PurchaseItem> items = [];
  List<Product> filteredProducts = [];

  // SELECTED CUSTOMER
  Customer? selectedCustomer;

  // CONTROLLERS & DATA VARIABLES
  final notesController = TextEditingController();
  final contactPersonController = TextEditingController();
  final phoneController = TextEditingController();
  final paymentTermsController = TextEditingController();
  final searchController = TextEditingController();
  final TextEditingController advancePaymentController =
      TextEditingController();
  final deliveryNoteController = TextEditingController();

  double gstPercentage = 18.0;
  double advancePayment = 0.0;
  int? expandedIndex; // Keeps track of which product card is tapped open

  // DATES & IDENTIFIERS
  DateTime saleDate = DateTime.now();
  DateTime? deliveryDate;
  late String saleNumber;

  // FINANCIAL GETTERS
  double get subtotal => items.fold(0.0, (sum, item) => sum + item.amount);
  double get gstAmount => subtotal * (gstPercentage / 100);
  double get grandTotal => subtotal + gstAmount;
  double get balanceDue =>
      grandTotal - advancePayment >= 0 ? grandTotal - advancePayment : 0;

  @override
  void initState() {
    super.initState();
    generateSaleNumber();
    loadData();
    searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    notesController.dispose();
    deliveryNoteController.dispose();
    contactPersonController.dispose();
    phoneController.dispose();
    paymentTermsController.dispose();
    searchController.dispose();
    advancePaymentController.dispose();
    super.dispose();
  }

  // ==========================================
  // LOGIC & CORE FUNCTIONS
  // ==========================================

  void generateSaleNumber() {
    final now = DateTime.now();
    saleNumber =
        "SAL${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}${now.hour}${now.minute}";
  }

  Future<void> loadData() async {
    try {
      products = await ProductService().getProducts();
      customers = await CustomerService().getCustomers();
      filteredProducts = List.from(products);
      _updateState(() => isLoading = false);
    } catch (e) {
      _updateState(() => isLoading = false);
      _showSnackBar(
        "Failed to load inventory data: ${e.toString()}",
        Colors.red,
      );
    }
  }

  void _filterProducts() {
    final query = searchController.text.toLowerCase();
    _updateState(() {
      filteredProducts = products.where((product) {
        return product.name.toLowerCase().contains(query) ||
            product.sku.toLowerCase().contains(query);
      }).toList();
    });
  }

  void _updateState(VoidCallback fn) {
    if (mounted) setState(fn);
  }

  void _showSnackBar(String text, Color background) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        backgroundColor: background,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ==========================================
  // ACTION & DIALOG UTILITIES
  // ==========================================

  Future<void> addItem() async {
    final Product? selectedProduct = await showModalBottomSheet<Product>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _buildProductSelectionSheet(),
    );

    if (selectedProduct == null) return;

    _updateState(() {
      final existingIndex = items.indexWhere(
        (item) => item.productId == selectedProduct.id,
      );
      if (existingIndex >= 0) {
        items[existingIndex].quantity++;
        items[existingIndex].calculateAmount();
      } else {
        final item = PurchaseItem(
          productId: selectedProduct.id,
          productName: selectedProduct.name,
          sku: selectedProduct.sku,
          unit: selectedProduct.unit.isEmpty ? "Pcs" : selectedProduct.unit,
          quantity: 1,
          rate: selectedProduct.sellingPrice, // Updated to use selling price
          amount: selectedProduct.sellingPrice,
        );
        item.calculateAmount();
        items.add(item);
      }
      expandedIndex = null;
    });
  }

  void removeItem(int index) {
    _updateState(() {
      items.removeAt(index);
      expandedIndex = null;
    });
  }

  Future<void> _selectCustomer() async {
    final customer = await showModalBottomSheet<Customer>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _buildCustomerSelectionSheet(),
    );
    if (customer != null) {
      _updateState(() {
        selectedCustomer = customer;
        contactPersonController.text = customer.contactPerson;
        phoneController.text = customer.phone;
        paymentTermsController.text = "Cash";
      });
    }
  }

  Future<void> _selectSaleDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: saleDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
    );
    if (picked != null) _updateState(() => saleDate = picked);
  }

  Future<void> _selectDeliveryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: deliveryDate ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
    );
    if (picked != null) _updateState(() => deliveryDate = picked);
  }

  void _toggleStatus() {
    _updateState(() {
      currentStatus = (currentStatus == "Draft") ? "Pending" : "Draft";
    });
    _showSnackBar("Status switched to $currentStatus", Colors.blue);
  }

  Future<void> _submitSalesOrder(String targetStatus) async {
    if (selectedCustomer == null) {
      _showSnackBar(
        "Please select a customer to proceed.",
        Colors.orange,
      );
      return;
    }
    if (items.isEmpty) {
      _showSnackBar(
        "Your shopping cart is empty. Add items first.",
        Colors.orange,
      );
      return;
    }

    _updateState(() => isSaving = true);

    try {
    await SaleService().createSale(
  saleNumber: saleNumber,
  customerName: selectedCustomer!.customerName,
  items: items.map((e) => e.toJson()).toList(), // Maps to JSON structures
  totalAmount: grandTotal,
  paymentStatus: targetStatus,
);

    

      _showSnackBar(
        "Sales order successfully logged as $targetStatus!",
        Colors.green,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      _showSnackBar("Order Submission Failed: ${e.toString()}", Colors.red);
    } finally {
      _updateState(() => isSaving = false);
    }
  }

  // ==========================================
  // WIDGET TEMPLATE FUNCTIONS
  // ==========================================

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FC),
      resizeToAvoidBottomInset: true,
      appBar: _buildAppBar(),
      bottomNavigationBar: _buildBottomNavigationBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCustomerProfileCard(),
            const SizedBox(height: 20),
            _buildInventoryContainer(),
            const SizedBox(height: 20),
            _buildDeliveryNoteSection(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(80),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              IconButton(
                onPressed: () => Navigator.pop(context),
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
                    Text(
                      "ID: $saleNumber",
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              InkWell(
                onTap: _toggleStatus,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFE1E8F5)),
                    color: currentStatus == "Draft"
                        ? const Color(0xFFEAF2FF)
                        : const Color(0xFFE8F7F7),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        currentStatus == "Draft"
                            ? Icons.edit_note_outlined
                            : Icons.check_circle_outline,
                        size: 18,
                        color: currentStatus == "Draft"
                            ? const Color(0xFF2F80FF)
                            : const Color(0xFF0F9D94),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        currentStatus,
                        style: TextStyle(
                          color: currentStatus == "Draft"
                              ? const Color(0xFF2F80FF)
                              : const Color(0xFF0F9D94),
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
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
    );
  }

  Widget _buildBottomNavigationBar() {
    final finalBillAmount = grandTotal - advancePayment >= 0
        ? grandTotal - advancePayment
        : 0.0;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 25),
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSummaryRow("Total Amount (Excl. GST)", subtotal),
            _buildSummaryRow("GST ($gstPercentage%)", gstAmount),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Advance Payment",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                  SizedBox(
                    width: 100,
                    height: 32,
                    child: TextFormField(
                      controller: advancePaymentController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1B2559),
                      ),
                      decoration: InputDecoration(
                        prefixText: '₹',
                        prefixStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1B2559),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 0,
                        ),
                        filled: true,
                        fillColor: const Color(0xFFF8FAFC),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFFE2E8F0),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF2F80FF),
                          ),
                        ),
                      ),
                      onChanged: (val) {
                        _updateState(() {
                          advancePayment = double.tryParse(val) ?? 0.0;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(height: 1, thickness: 1),
            ),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Total Bill Amount",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "₹${finalBillAmount.toStringAsFixed(2)}",
                        style: const TextStyle(
                          color: Color(0xFF1B2559),
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: isSaving
                          ? null
                          : () => _submitSalesOrder(currentStatus),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF143D7A),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                      ),
                      child: isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Place Order",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                                SizedBox(width: 6),
                                Icon(
                                  Icons.arrow_forward,
                                  size: 16,
                                  color: Colors.white,
                                ),
                              ],
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String title, double value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          Text(
            "₹${value.toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1B2559),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerProfileCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F7F5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.person_outline,
                  size: 26,
                  color: Color(0xFF0F766E),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedCustomer?.customerName ?? "Select Customer",
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1B2559),
                      ),
                    ),
                    Text(
                      selectedCustomer?.phone ?? "No customer linked",
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF4E5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        "Opening Balance: ₹${selectedCustomer?.openingBalance.toStringAsFixed(0) ?? "0"}",
                        style: const TextStyle(
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: _selectCustomer,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFE2E8F0)),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text("Change", style: TextStyle(fontSize: 13)),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1),
          ),
          Row(
            children: [
              Expanded(
                child: _buildDateTile(
                  "Sale Date",
                  saleDate,
                  _selectSaleDate,
                ),
              ),
              Container(width: 1, height: 35, color: Colors.grey.shade200),
              Expanded(
                child: _buildDateTile(
                  "Delivery Date",
                  deliveryDate,
                  _selectDeliveryDate,
                ),
              ),
              Container(width: 1, height: 35, color: Colors.grey.shade200),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Terms",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        paymentTermsController.text.isEmpty
                            ? "Cash"
                            : paymentTermsController.text,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1B2559),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryContainer() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Items & Measurements",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B2559),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    hintText: "Search stock list...",
                    prefixIcon: const Icon(Icons.search, size: 20),
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF2F80FF)),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                height: 45,
                child: ElevatedButton.icon(
                  onPressed: addItem,
                  icon: const Icon(Icons.add, color: Colors.white, size: 16),
                  label: const Text(
                    "Add",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2F80FF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          items.isEmpty ? _buildEmptyStateWidget() : _buildInventoryItemsList(),
        ],
      ),
    );
  }

  Widget _buildEmptyStateWidget() {
    return Container(
      height: 120,
      width: double.infinity,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 36,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 6),
          const Text(
            "No inventory lines drafted yet",
            style: TextStyle(fontSize: 13, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryItemsList() {
    return ListView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: List.generate(items.length, (index) {
        final item = items[index];
        final isExpanded = expandedIndex == index;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isExpanded
                  ? const Color(0xFF2F80FF).withOpacity(0.3)
                  : const Color(0xFFE2E8F0),
              width: isExpanded ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(isExpanded ? 0.06 : 0.02),
                blurRadius: isExpanded ? 12 : 6,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                splashColor: Colors.transparent,
                highlightColor: Colors.transparent,
                onTap: () {
                  setState(() {
                    expandedIndex = isExpanded ? null : index;
                  });
                },
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B2559),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Code: ${item.sku} | Rate: ₹${item.rate.toStringAsFixed(2)}",
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Total: ₹${item.amount.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2F80FF),
                            ),
                          ),
                          if (item.notes != null && item.notes!.isNotEmpty) ...[
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF9E6),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.sticky_note_2,
                                    size: 12,
                                    color: Colors.orange,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      item.notes!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.orange,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.remove_circle_outline,
                                size: 22,
                                color: Color(0xFF1B2559),
                              ),
                              onPressed: () {
                                if (item.quantity > 1) {
                                  setState(() {
                                    item.quantity--;
                                    item.calculateAmount();
                                  });
                                }
                              },
                            ),
                            SizedBox(
                              width: 60,
                              height: 36,
                              child: TextFormField(
                                key: ValueKey(
                                  "${item.productId}_${item.quantity}",
                                ),
                                initialValue: item.quantity.toString(),
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF1B2559),
                                ),
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 2,
                                    horizontal: 4,
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF2F80FF),
                                    ),
                                  ),
                                ),
                                onChanged: (val) {
                                  final parsedQty = int.tryParse(val) ?? 0;
                                  setState(() {
                                    item.quantity = parsedQty;
                                    item.calculateAmount();
                                  });
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.add_circle_outline,
                                size: 22,
                                color: Color(0xFF1B2559),
                              ),
                              onPressed: () {
                                setState(() {
                                  item.quantity++;
                                  item.calculateAmount();
                                });
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.unit.isEmpty ? 'PCS' : item.unit.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
             if (isExpanded) ...[
  const Padding(
    padding: EdgeInsets.symmetric(vertical: 12),
    child: Divider(
      height: 1,
      thickness: 1,
      color: Color(0xFFEDF2F7),
    ),
  ),
  Row(
    children: [
      // 1. ADD / EDIT NOTE BUTTON
      Expanded(
        child: OutlinedButton.icon(
          onPressed: () => _showAddNoteDialog(index, item.notes ?? ""),
          icon: const Icon(Icons.edit_note, size: 18),
          label: Text(
            item.notes == null || item.notes!.isEmpty
                ? "Add Note"
                : "Edit Note",
          ),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF2F80FF),
            side: const BorderSide(color: Color(0xFF2F80FF)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      ),
      const SizedBox(width: 8),
      
      // 2. NEW CHANGE PRICE BUTTON
      Expanded(
        child: OutlinedButton.icon(
          onPressed: () => _showCustomPriceDialog(index, item.rate),
          icon: const Icon(Icons.edit_road_outlined, size: 18), // A sleek edit icon
          label: const Text("Edit Price"),
          style: OutlinedButton.styleFrom(
            foregroundColor: const Color(0xFF0F9D94),
            side: const BorderSide(color: Color(0xFF0F9D94)),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
        ),
      ),
      const SizedBox(width: 8),
      
      // 3. REMOVE ITEM BUTTON
      IconButton(
        onPressed: () {
          removeItem(index);
        },
        icon: const Icon(Icons.delete_outline, color: Colors.red),
        style: IconButton.styleFrom(
          backgroundColor: Colors.red.shade50,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          padding: const EdgeInsets.all(10),
        ),
      ),
    ],
  ),
],
            ],
          ),
        );
      }),
    );
  }

  void _showAddNoteDialog(int index, String currentNote) {
    final textController = TextEditingController(text: currentNote);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Product Note",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B2559),
            ),
          ),
          content: TextField(
            controller: textController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Enter shipping instructions or delivery batch details...",
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFF2F80FF)),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  items[index].notes = textController.text.trim();
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2F80FF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                "Save Note",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

void _showCustomPriceDialog(int index, double currentRate) {
  final priceController = TextEditingController(text: currentRate.toStringAsFixed(2));
  
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          "Modify Unit Price",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B2559),
          ),
        ),
        content: TextFormField(
          controller: priceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: "Enter manual rate per piece...",
            prefixText: "₹ ",
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF2F80FF)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final newRate = double.tryParse(priceController.text.trim());
              if (newRate != null && newRate >= 0) {
                setState(() {
                  items[index].rate = newRate;
                  items[index].calculateAmount(); // Re-compute quantity * new rate
                });
                Navigator.pop(context);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Please enter a valid amount")),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F9D94),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              "Update Price",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      );
    },
  );
}

  Widget _buildDateTile(String label, DateTime? date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 3),
            Text(
              date == null
                  ? "Select Date"
                  : "${date.day}/${date.month}/${date.year}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF1B2559),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryNoteSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.local_shipping_outlined,
                color: Color(0xFF1B2559),
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                "Delivery Instructions / Notes",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B2559),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          TextField(
            controller: deliveryNoteController,
            maxLines: 3,
            style: const TextStyle(fontSize: 14, color: Color(0xFF1B2559)),
            decoration: InputDecoration(
              hintText:
                  "Enter specific instructions for customer delivery, billing addresses, drop-off, etc...",
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF2F80FF)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductSelectionSheet() {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Select Product Inventory",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B2559),
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: filteredProducts.length,
                itemBuilder: (context, index) {
                  final product = filteredProducts[index];

                  return ListTile(
                    title: Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      "SKU: ${product.sku} | Unit: ${product.unit.isEmpty ? 'Pcs' : product.unit}",
                    ),
                    trailing: Text(
                      "₹${product.sellingPrice}", // Configured with selling price
                      style: const TextStyle(
                        color: Color(0xFF0F9D94),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () => Navigator.pop(context, product),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCustomerSelectionSheet() {
    return ListView.builder(
      itemCount: customers.length,
      itemBuilder: (context, index) {
        final c = customers[index];
        return ListTile(
          title: Text(
            c.customerName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(c.phone),
          trailing: const Icon(Icons.keyboard_arrow_right, size: 16),
          onTap: () => Navigator.pop(context, c),
        );
      },
    );
  }
}