import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../models/purchase_item_model.dart';
import '../models/supplier_model.dart';
import '../services/product_service.dart';
import '../services/purchase_service.dart';
import '../services/supplier_service.dart';
import '../utils/app_theme.dart';
import '../widgets/custom_app_bar.dart';

class AddPurchaseScreen extends StatefulWidget {
  const AddPurchaseScreen({super.key});

  @override
  State<AddPurchaseScreen> createState() => _AddPurchaseScreenState();
}

class _AddPurchaseScreenState extends State<AddPurchaseScreen> {
  bool isLoading = true;
  bool isSaving = false;
  String currentStatus = "Pending";

  List<Product> products = [];
  List<Supplier> suppliers = [];
  List<PurchaseItem> items = [];
  List<Product> filteredProducts = [];

  Supplier? selectedSupplier;

  final notesController = TextEditingController();
  final contactPersonController = TextEditingController();
  final phoneController = TextEditingController();
  final paymentTermsController = TextEditingController();
  final searchController = TextEditingController();
  final advancePaymentController = TextEditingController();
  final transportChargesController = TextEditingController();

  double gstPercentage = 18.0;
  double advancePayment = 0.0;
  double transportCharges = 0.0;
  int? expandedIndex;

  DateTime purchaseDate = DateTime.now();
  DateTime? deliveryDate;
  late String purchaseNumber;

  double get subtotal => items.fold(0.0, (sum, item) => sum + item.amount);
  double get gstAmount => subtotal * (gstPercentage / 100);
  double get grandTotal => subtotal + gstAmount + transportCharges;
  double get balanceDue =>
      grandTotal - advancePayment >= 0 ? grandTotal - advancePayment : 0.0;

  @override
  void initState() {
    super.initState();
    generatePurchaseNumber();
    loadData();
    searchController.addListener(_filterProducts);
  }

  @override
  void dispose() {
    notesController.dispose();
    contactPersonController.dispose();
    phoneController.dispose();
    paymentTermsController.dispose();
    searchController.dispose();
    advancePaymentController.dispose();
    transportChargesController.dispose();
    super.dispose();
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
      filteredProducts = List.from(products);
      _updateState(() => isLoading = false);
    } catch (e) {
      _updateState(() => isLoading = false);
      _showSnackBar(
        "Failed to load inventory data: ${e.toString()}",
        AppColors.error,
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

  Future<void> addItem() async {
    final Product? selectedProduct = await showModalBottomSheet<Product>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
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
          rate: selectedProduct.purchasePrice,
          amount: selectedProduct.purchasePrice,
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

  Future<void> _selectSupplier() async {
    final supplier = await showModalBottomSheet<Supplier>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (_) => _buildSupplierSelectionSheet(),
    );
    if (supplier != null) {
      _updateState(() {
        selectedSupplier = supplier;
        contactPersonController.text = supplier.contactPerson;
        phoneController.text = supplier.phone;
        paymentTermsController.text = supplier.paymentTerms;
      });
    }
  }

  Future<void> _selectPurchaseDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: purchaseDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
    );
    if (picked != null) _updateState(() => purchaseDate = picked);
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
    _showSnackBar("Status switched to $currentStatus", AppColors.primary);
  }

  Future<void> _submitPurchaseOrder(String targetStatus) async {
    if (selectedSupplier == null) {
      _showSnackBar(
        "Please select a vendor/supplier to proceed.",
        const Color(0xFFD97706),
      );
      return;
    }
    if (items.isEmpty) {
      _showSnackBar(
        "Your shopping cart is empty. Add items first.",
        const Color(0xFFD97706),
      );
      return;
    }

    _updateState(() => isSaving = true);

    try {
      final orderPayload = {
        "purchaseNumber": purchaseNumber,
        "supplierId": selectedSupplier!.id,
        "supplierName": selectedSupplier!.supplierName,
        "contactPerson": selectedSupplier!.contactPerson,
        "phone": selectedSupplier!.phone,
        "email": selectedSupplier!.email,
        "gstNumber": selectedSupplier!.gstNumber,
        "address": selectedSupplier!.address,
        "city": selectedSupplier!.city,
        "state": selectedSupplier!.state,
        "pincode": selectedSupplier!.pincode,
        "paymentTerms": selectedSupplier!.paymentTerms,
        "purchaseDate": purchaseDate.toIso8601String(),
        "deliveryDate": deliveryDate?.toIso8601String(),
        "items": items.map((i) {
          return {
            "productId": i.productId,
            "productName": i.productName,
            "sku": i.sku,
            "unit": i.unit,
            "quantity": i.quantity,
            "rate": i.rate,
            "amount": i.amount,
            "notes": i.notes ?? "",
          };
        }).toList(),
        "notes": notesController.text.trim(),
        "subtotal": subtotal,
        "discount": 0,
        "gst": gstAmount,
        "transportCharges": transportCharges,
        "advancePayment": advancePayment,
        "balanceDue": balanceDue,
        "totalAmount": grandTotal,
        "paymentStatus": advancePayment >= grandTotal
            ? "Paid"
            : advancePayment > 0
                ? "Partial"
                : "Pending",
        "status": targetStatus,
      };

      await PurchaseService().createPurchase(orderPayload);
      _showSnackBar(
        "Purchase successfully logged as $targetStatus!",
        const Color(0xFF10B981),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      _showSnackBar("Order Submission Failed: ${e.toString()}", AppColors.error);
    } finally {
      _updateState(() => isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar(
        title: "New Purchase",
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Center(
              child: InkWell(
                onTap: _toggleStatus,
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: currentStatus == "Draft"
                        ? const Color(0xFFE8EEF5)
                        : const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: currentStatus == "Draft"
                          ? const Color(0xFFBFDBFE)
                          : const Color(0xFFA7F3D0),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        currentStatus == "Draft"
                            ? Icons.edit_note_outlined
                            : Icons.check_circle_outline,
                        size: 15,
                        color: currentStatus == "Draft"
                            ? const Color(0xFF0F294A)
                            : const Color(0xFF10B981),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        currentStatus,
                        style: TextStyle(
                          color: currentStatus == "Draft"
                              ? const Color(0xFF0F294A)
                              : const Color(0xFF10B981),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                "ID: $purchaseNumber",
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            _buildSupplierProfileCard(),
            const SizedBox(height: 16),
            _buildInventoryContainer(),
            const SizedBox(height: 16),
            _buildDeliveryNoteSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.cardBorder)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSummaryRow("Subtotal (Excl. GST)", subtotal),
            _buildSummaryRow("GST ($gstPercentage%)", gstAmount),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Transportation Charges",
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  SizedBox(
                    width: 110,
                    height: 32,
                    child: TextFormField(
                      controller: transportChargesController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      decoration: const InputDecoration(
                        prefixText: '₹ ',
                        prefixStyle: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 0,
                        ),
                        filled: true,
                        fillColor: AppColors.background,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                          borderSide: BorderSide(color: AppColors.cardBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                          borderSide: BorderSide(color: AppColors.primary),
                        ),
                      ),
                      onChanged: (val) {
                        _updateState(() {
                          transportCharges = double.tryParse(val) ?? 0.0;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Advance Payment",
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  SizedBox(
                    width: 110,
                    height: 32,
                    child: TextFormField(
                      controller: advancePaymentController,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      decoration: const InputDecoration(
                        prefixText: '₹ ',
                        prefixStyle: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 0,
                        ),
                        filled: true,
                        fillColor: AppColors.background,
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                          borderSide: BorderSide(color: AppColors.cardBorder),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.all(Radius.circular(6)),
                          borderSide: BorderSide(color: AppColors.primary),
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
              child: Divider(height: 1, color: AppColors.cardBorder),
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
                          fontSize: 11,
                          color: AppColors.textMuted,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "₹${grandTotal.toStringAsFixed(2)}",
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (advancePayment > 0) ...[
                        const SizedBox(height: 2),
                        Text(
                          "Due: ₹${balanceDue.toStringAsFixed(2)}",
                          style: const TextStyle(
                            color: Color(0xFFD97706),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
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
                          : () => _submitPurchaseOrder(currentStatus),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
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
                                    fontSize: 14,
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
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          Text(
            "₹${value.toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSupplierProfileCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8EEF5),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.sticky_note_2_outlined,
                  size: 20,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      selectedSupplier?.supplierName ??
                          "Select Supplier/Vendor",
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      selectedSupplier?.phone ?? "No supplier linked",
                      style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Text(
                        "Prev Balance: ₹${selectedSupplier?.openingBalance.toStringAsFixed(0) ?? "0"}",
                        style: const TextStyle(
                          color: Color(0xFFD97706),
                          fontWeight: FontWeight.bold,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              OutlinedButton(
                onPressed: _selectSupplier,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.cardBorder),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  minimumSize: const Size(0, 32),
                ),
                child: const Text(
                  "Change",
                  style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
                ),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: AppColors.cardBorder),
          ),
          Row(
            children: [
              Expanded(
                child: _buildDateTile(
                  "Purchase Date",
                  purchaseDate,
                  _selectPurchaseDate,
                ),
              ),
              Container(width: 1, height: 32, color: AppColors.cardBorder),
              Expanded(
                child: _buildDateTile(
                  "Delivery Date",
                  deliveryDate,
                  _selectDeliveryDate,
                ),
              ),
              Container(width: 1, height: 32, color: AppColors.cardBorder),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Terms",
                        style: TextStyle(color: AppColors.textMuted, fontSize: 11),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        paymentTermsController.text.isEmpty
                            ? "Net 30"
                            : paymentTermsController.text,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          color: AppColors.textPrimary,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Items & Measurements",
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                  decoration: const InputDecoration(
                    hintText: "Search stock list...",
                    hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 13),
                    prefixIcon: Icon(Icons.search, size: 18, color: AppColors.textMuted),
                    filled: true,
                    fillColor: AppColors.background,
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide(color: AppColors.cardBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(8)),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              SizedBox(
                height: 40,
                child: ElevatedButton.icon(
                  onPressed: addItem,
                  icon: const Icon(Icons.add, color: Colors.white, size: 16),
                  label: const Text(
                    "Add",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          items.isEmpty ? _buildEmptyStateWidget() : _buildInventoryItemsList(),
        ],
      ),
    );
  }

  Widget _buildEmptyStateWidget() {
    return Container(
      height: 100,
      width: double.infinity,
      alignment: Alignment.center,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 32,
            color: AppColors.textMuted,
          ),
          SizedBox(height: 6),
          Text(
            "No inventory lines drafted yet",
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ],
      ),
    );
  }

  Widget _buildInventoryItemsList() {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (context, index) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final item = items[index];
        final isExpanded = expandedIndex == index;

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isExpanded
                  ? AppColors.primary.withOpacity(0.4)
                  : AppColors.cardBorder,
            ),
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
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            "Code: ${item.sku} | Rate: ₹${item.rate.toStringAsFixed(2)}",
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Total: ₹${item.amount.toStringAsFixed(2)}",
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          if (item.notes != null && item.notes!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFBEB),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.sticky_note_2,
                                    size: 11,
                                    color: Color(0xFFD97706),
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      item.notes!,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 10.5,
                                        color: Color(0xFFD97706),
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
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.remove_circle_outline,
                                size: 20,
                                color: AppColors.textPrimary,
                              ),
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              padding: EdgeInsets.zero,
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
                              width: 52,
                              height: 32,
                              child: TextFormField(
                                key: ValueKey(
                                  "${item.productId}_${item.quantity}",
                                ),
                                initialValue: item.quantity.toString(),
                                keyboardType: TextInputType.number,
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                    vertical: 2,
                                    horizontal: 4,
                                  ),
                                  filled: true,
                                  fillColor: AppColors.background,
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(6)),
                                    borderSide: BorderSide(color: AppColors.cardBorder),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.all(Radius.circular(6)),
                                    borderSide: BorderSide(color: AppColors.primary),
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
                                size: 20,
                                color: AppColors.textPrimary,
                              ),
                              constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                              padding: EdgeInsets.zero,
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
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (isExpanded) ...[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: Divider(height: 1, color: AppColors.cardBorder),
                ),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _showAddNoteDialog(index, item.notes ?? ""),
                        icon: const Icon(Icons.edit_note, size: 16),
                        label: Text(
                          item.notes == null || item.notes!.isEmpty
                              ? "Add Note"
                              : "Edit Note",
                          style: const TextStyle(fontSize: 12),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.primary),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _showCustomPriceDialog(
                          index,
                          item.rate,
                          item.productId,
                        ),
                        icon: const Icon(Icons.edit_outlined, size: 16),
                        label: const Text("Edit Price", style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.textSecondary,
                          side: const BorderSide(color: AppColors.cardBorder),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () {
                        removeItem(index);
                      },
                      icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 18),
                      style: IconButton.styleFrom(
                        backgroundColor: const Color(0xFFFEF2F2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                          side: const BorderSide(color: Color(0xFFFECACA)),
                        ),
                        padding: const EdgeInsets.all(8),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  void _showAddNoteDialog(int index, String currentNote) {
    final textController = TextEditingController(text: currentNote);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          title: const Text(
            "Product Note",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: AppColors.textPrimary,
            ),
          ),
          content: TextField(
            controller: textController,
            maxLines: 3,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
            decoration: const InputDecoration(
              hintText: "Enter production instructions or batch info...",
              hintStyle: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
              filled: true,
              fillColor: AppColors.background,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(6)),
                borderSide: BorderSide(color: AppColors.cardBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(6)),
                borderSide: BorderSide(color: AppColors.primary),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel", style: TextStyle(color: AppColors.textSecondary)),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  items[index].notes = textController.text.trim();
                });
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
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

  void _showCustomPriceDialog(int index, double currentRate, String productId) {
    final priceController = TextEditingController(
      text: currentRate.toStringAsFixed(2),
    );
    bool updateMasterCatalog = false;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              title: const Text(
                "Modify Purchase Price",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: AppColors.textPrimary,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: priceController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                    decoration: const InputDecoration(
                      hintText: "Enter manual rate per piece...",
                      hintStyle: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                      prefixText: "₹ ",
                      filled: true,
                      fillColor: AppColors.background,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(6)),
                        borderSide: BorderSide(color: AppColors.cardBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(6)),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    activeColor: AppColors.primary,
                    title: const Text(
                      "Update master product purchase price",
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    subtitle: const Text(
                      "Saves this price to master inventory for future orders",
                      style: TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                    value: updateMasterCatalog,
                    onChanged: (val) {
                      setDialogState(() {
                        updateMasterCatalog = val ?? false;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Cancel",
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final newRate = double.tryParse(
                      priceController.text.trim(),
                    );
                    if (newRate != null && newRate >= 0) {
                      setState(() {
                        items[index].rate = newRate;
                        items[index].calculateAmount();
                      });

                      if (updateMasterCatalog) {
                        try {
                          final prodIndex = products.indexWhere(
                            (p) => p.id == productId,
                          );
                          if (prodIndex >= 0) {
                            products[prodIndex].purchasePrice = newRate;
                            await ProductService().updatePurchasePrice(productId, newRate);
                          }

                          _showSnackBar(
                            "Master product purchase price updated!",
                            const Color(0xFF10B981),
                          );
                        } catch (e) {
                          _showSnackBar(
                            "Failed to update master catalog: $e",
                            const Color(0xFFD97706),
                          );
                        }
                      }

                      if (context.mounted) Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Please enter a valid amount"),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
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
      },
    );
  }

  Widget _buildDateTile(String label, DateTime? date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 11),
            ),
            const SizedBox(height: 2),
            Text(
              date == null
                  ? "Select Date"
                  : "${date.day}/${date.month}/${date.year}",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 12,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeliveryNoteSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.local_shipping_outlined,
                color: AppColors.primary,
                size: 18,
              ),
              SizedBox(width: 8),
              Text(
                "Delivery Instructions / Notes",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          TextField(
            controller: notesController,
            maxLines: 3,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
            decoration: const InputDecoration(
              hintText:
                  "Enter specific instructions for shipping, drop-off details, gates, etc...",
              hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 12.5),
              filled: true,
              fillColor: AppColors.background,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 10,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(6)),
                borderSide: BorderSide(color: AppColors.cardBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(6)),
                borderSide: BorderSide(color: AppColors.primary),
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
            const SizedBox(height: 10),
            Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.cardBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Select Product Inventory",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                controller: scrollController,
                itemCount: filteredProducts.length,
                separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.cardBorder),
                itemBuilder: (context, index) {
                  final product = filteredProducts[index];

                  return ListTile(
                    title: Text(
                      product.name,
                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                    ),
                    subtitle: Text(
                      "SKU: ${product.sku} | Unit: ${product.unit.isEmpty ? 'Pcs' : product.unit}",
                      style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                    trailing: Text(
                      "₹${product.purchasePrice}",
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
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

  Widget _buildSupplierSelectionSheet() {
    return ListView.separated(
      itemCount: suppliers.length,
      separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.cardBorder),
      itemBuilder: (context, index) {
        final s = suppliers[index];
        return ListTile(
          title: Text(
            s.supplierName,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5, color: AppColors.textPrimary),
          ),
          subtitle: Text(
            s.phone,
            style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
          trailing: const Icon(Icons.chevron_right, size: 18, color: AppColors.textMuted),
          onTap: () => Navigator.pop(context, s),
        );
      },
    );
  }
}