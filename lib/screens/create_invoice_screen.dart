import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../models/invoice_model.dart';
import '../models/party_model.dart';
import '../models/product_model.dart';
import '../services/invoice_service.dart';
import '../services/party_service.dart';
import '../services/product_service.dart';
import '../utils/app_theme.dart';
import '../utils/invoice_pdf_generator.dart';
import '../widgets/custom_app_bar.dart';

class CreateInvoiceScreen extends StatefulWidget {
  final List<Product>? initialProducts;
  final List<Party>? initialParties;

  const CreateInvoiceScreen({
    super.key,
    this.initialProducts,
    this.initialParties,
  });

  @override
  State<CreateInvoiceScreen> createState() => _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends State<CreateInvoiceScreen> {
  final InvoiceService _invoiceService = InvoiceService();
  final ProductService _productService = ProductService();
  final PartyService _partyService = PartyService();

  String _invoiceType = 'SALE';
  Party? _selectedParty;
  final List<InvoiceItem> _items = [];

  List<Product> _availableProducts = [];
  List<Party> _availableParties = [];
  bool _isLoadingPrereqs = false;
  bool _isSaving = false;

  String _paymentStatus = 'UNPAID';
  final TextEditingController _notesController = TextEditingController();

  Product? _currentItemProduct;
  final TextEditingController _quantityController = TextEditingController(text: '1');
  final TextEditingController _rateController = TextEditingController(text: '0');
  double _currentGstRate = 18.0;

  @override
  void initState() {
    super.initState();
    if (widget.initialProducts != null && widget.initialParties != null) {
      _availableProducts = List.from(widget.initialProducts!);
      _availableParties = List.from(widget.initialParties!);
      if (_availableParties.isNotEmpty) {
        _selectedParty = _availableParties.first;
      }
      if (_availableProducts.isNotEmpty) {
        _currentItemProduct = _availableProducts.first;
        _rateController.text = (_invoiceType == 'SALE'
                ? _currentItemProduct!.sellingPrice
                : _currentItemProduct!.purchasePrice)
            .toStringAsFixed(0);
      }
    } else {
      _loadPrerequisites();
    }
  }

  @override
  void dispose() {
    _notesController.dispose();
    _quantityController.dispose();
    _rateController.dispose();
    super.dispose();
  }

  Future<void> _loadPrerequisites() async {
    setState(() => _isLoadingPrereqs = true);
    try {
      final results = await Future.wait([
        _productService.getProducts(),
        _partyService.getParties(),
      ]).timeout(const Duration(seconds: 60));

      if (mounted) {
        setState(() {
          _availableProducts = results[0] as List<Product>;
          _availableParties = results[1] as List<Party>;
          _isLoadingPrereqs = false;

          if (_availableParties.isNotEmpty && _selectedParty == null) {
            _selectedParty = _availableParties.first;
          }
          if (_availableProducts.isNotEmpty && _currentItemProduct == null) {
            _currentItemProduct = _availableProducts.first;
            _rateController.text = (_invoiceType == 'SALE'
                    ? _currentItemProduct!.sellingPrice
                    : _currentItemProduct!.purchasePrice)
                .toStringAsFixed(0);
          }
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingPrereqs = false);
    }
  }

  double get _subtotal {
    return _items.fold<double>(0.0, (sum, i) => sum + i.amount);
  }

  double get _gstTotal {
    return _items.fold<double>(0.0, (sum, i) => sum + i.gstAmount);
  }

  double get _grandTotal => _subtotal + _gstTotal;

  void _addItem() {
    if (_currentItemProduct == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a product")),
      );
      return;
    }

    final qty = int.tryParse(_quantityController.text.trim()) ?? 0;
    final rate = double.tryParse(_rateController.text.trim()) ?? 0.0;

    if (qty <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Quantity must be at least 1")),
      );
      return;
    }

    if (rate < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Rate cannot be negative")),
      );
      return;
    }

    final itemAmount = qty * rate;

    setState(() {
      _items.add(
        InvoiceItem(
          productId: _currentItemProduct!.id,
          productName: _currentItemProduct!.name,
          quantity: qty,
          rate: rate,
          gstRate: _currentGstRate,
          amount: itemAmount,
        ),
      );
      _quantityController.text = '1';
    });
  }

  void _removeItem(int index) {
    setState(() {
      _items.removeAt(index);
    });
  }

  Invoice _buildCurrentInvoiceObject() {
    return Invoice(
      id: '',
      invoiceNumber: 'PREVIEW-${DateFormat('HHmmss').format(DateTime.now())}',
      type: _invoiceType,
      partyId: _selectedParty?.id ?? '',
      partyName: _selectedParty?.businessName ?? 'Retail Party',
      items: List.from(_items),
      subtotal: _subtotal,
      gstTotal: _gstTotal,
      grandTotal: _grandTotal,
      paymentStatus: _paymentStatus,
      notes: _notesController.text.trim(),
      date: DateTime.now(),
    );
  }

  Future<void> _previewPdf() async {
    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add at least one line item")),
      );
      return;
    }

    final invoice = _buildCurrentInvoiceObject();
    final pdfBytes = await InvoicePdfGenerator.generate(invoice);

    if (!mounted) return;

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: '${invoice.invoiceNumber}.pdf',
    );
  }

  Future<void> _saveInvoice() async {
    if (_selectedParty == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a party/customer")),
      );
      return;
    }

    if (_items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add at least one product item")),
      );
      return;
    }

    setState(() => _isSaving = true);

    final payload = {
      'type': _invoiceType,
      'partyId': _selectedParty!.id,
      'partyName': _selectedParty!.businessName,
      'items': _items.map((i) => i.toJson()).toList(),
      'paymentStatus': _paymentStatus,
      'notes': _notesController.text.trim(),
      'date': DateTime.now().toIso8601String(),
    };

    try {
      final created = await _invoiceService.createInvoice(payload);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Invoice ${created.invoiceNumber} created successfully!"),
          backgroundColor: const Color(0xFF10B981),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error creating invoice: $e"),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  InputDecoration _fieldDecoration({String? labelText, String? hintText}) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      labelStyle: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
      hintStyle: const TextStyle(fontSize: 12.5, color: AppColors.textMuted),
      filled: true,
      fillColor: Colors.white,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.cardBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: _invoiceType == 'SALE' ? "Create Tax Invoice" : "Create Purchase Bill",
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined, color: AppColors.textPrimary),
            tooltip: "Preview PDF",
            onPressed: _previewPdf,
          ),
        ],
      ),
      body: _isLoadingPrereqs
          ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
          : SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTypeToggle(),
                  const SizedBox(height: 14),
                  _buildPartySection(),
                  const SizedBox(height: 14),
                  _buildAddItemSection(),
                  const SizedBox(height: 14),
                  _buildItemsListSection(),
                  const SizedBox(height: 14),
                  _buildTotalsSection(),
                  const SizedBox(height: 14),
                  _buildPaymentAndNotesSection(),
                  const SizedBox(height: 20),
                  _buildActionButtons(),
                ],
              ),
            ),
    );
  }

  Widget _buildTypeToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _invoiceType = 'SALE';
                  if (_currentItemProduct != null) {
                    _rateController.text = _currentItemProduct!.sellingPrice.toStringAsFixed(0);
                  }
                });
              },
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _invoiceType == 'SALE' ? const Color(0xFFE8EEF5) : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _invoiceType == 'SALE' ? const Color(0xFFBFDBFE) : Colors.transparent,
                  ),
                ),
                child: Center(
                  child: Text(
                    "Sales Tax Invoice",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _invoiceType == 'SALE' ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: InkWell(
              onTap: () {
                setState(() {
                  _invoiceType = 'PURCHASE';
                  if (_currentItemProduct != null) {
                    _rateController.text = _currentItemProduct!.purchasePrice.toStringAsFixed(0);
                  }
                });
              },
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: _invoiceType == 'PURCHASE' ? const Color(0xFFE8EEF5) : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: _invoiceType == 'PURCHASE' ? const Color(0xFFBFDBFE) : Colors.transparent,
                  ),
                ),
                child: Center(
                  child: Text(
                    "Purchase Bill",
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _invoiceType == 'PURCHASE' ? AppColors.primary : AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartySection() {
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
          Row(
            children: [
              const Icon(Icons.storefront_outlined, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                _invoiceType == 'SALE' ? "Customer / Party" : "Supplier / Vendor",
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_availableParties.isEmpty)
            const Text(
              "No parties found. Please create parties in Parties CRM first.",
              style: TextStyle(fontSize: 12, color: AppColors.error),
            )
          else
            DropdownButtonFormField<Party>(
              initialValue: _selectedParty,
              isExpanded: true,
              dropdownColor: Colors.white,
              style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
              decoration: _fieldDecoration(),
              items: _availableParties.map((p) {
                return DropdownMenuItem<Party>(
                  value: p,
                  child: Text(
                    "${p.businessName} (${p.name})",
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) setState(() => _selectedParty = val);
              },
            ),
        ],
      ),
    );
  }

  Widget _buildAddItemSection() {
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
          Row(
            children: const [
              Icon(Icons.add_shopping_cart_outlined, size: 18, color: AppColors.primary),
              SizedBox(width: 8),
              Text(
                "Add Line Item",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_availableProducts.isEmpty)
            const Text("No products found in catalog.", style: TextStyle(fontSize: 12, color: AppColors.textMuted))
          else
            DropdownButtonFormField<Product>(
              initialValue: _currentItemProduct,
              isExpanded: true,
              dropdownColor: Colors.white,
              style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
              decoration: _fieldDecoration(labelText: "Select Product"),
              items: _availableProducts.map((prod) {
                return DropdownMenuItem<Product>(
                  value: prod,
                  child: Text(
                    "${prod.name} (Stock: ${prod.stock})",
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _currentItemProduct = val;
                    _rateController.text = (_invoiceType == 'SALE'
                            ? val.sellingPrice
                            : val.purchasePrice)
                        .toStringAsFixed(0);
                  });
                }
              },
            ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                  decoration: _fieldDecoration(labelText: "Qty"),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: _rateController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                  decoration: _fieldDecoration(labelText: "Rate (₹)"),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: DropdownButtonFormField<double>(
                  initialValue: _currentGstRate,
                  dropdownColor: Colors.white,
                  style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
                  decoration: _fieldDecoration(labelText: "GST"),
                  items: const [
                    DropdownMenuItem(value: 0.0, child: Text("0%")),
                    DropdownMenuItem(value: 5.0, child: Text("5%")),
                    DropdownMenuItem(value: 12.0, child: Text("12%")),
                    DropdownMenuItem(value: 18.0, child: Text("18%")),
                    DropdownMenuItem(value: 28.0, child: Text("28%")),
                  ],
                  onChanged: (val) {
                    if (val != null) setState(() => _currentGstRate = val);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.cardBorder),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.add, size: 16, color: AppColors.primary),
              label: const Text(
                "Add Line Item",
                style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13),
              ),
              onPressed: _addItem,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsListSection() {
    if (_items.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.cardBorder),
        ),
        child: const Center(
          child: Text(
            "No items added yet. Select a product and add line items above.",
            style: TextStyle(fontSize: 12, color: AppColors.textMuted),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Line Items (${_items.length})",
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                Text(
                  "Subtotal: ₹${_subtotal.toStringAsFixed(0)}",
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.cardBorder),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _items.length,
            separatorBuilder: (context, index) => const Divider(height: 1, color: AppColors.cardBorder),
            itemBuilder: (context, idx) {
              final item = _items[idx];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.productName,
                            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "${item.quantity} pcs @ ₹${item.rate.toStringAsFixed(0)} (+${item.gstRate.toStringAsFixed(0)}% GST)",
                            style: const TextStyle(fontSize: 11.5, color: AppColors.textMuted),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      "₹${item.amount.toStringAsFixed(0)}",
                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.error),
                      constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                      padding: EdgeInsets.zero,
                      onPressed: () => _removeItem(idx),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTotalsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        children: [
          _summaryRow("Subtotal", "₹${_subtotal.toStringAsFixed(2)}"),
          const SizedBox(height: 8),
          _summaryRow("GST Total", "₹${_gstTotal.toStringAsFixed(2)}"),
          const SizedBox(height: 10),
          const Divider(height: 1, color: AppColors.cardBorder),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Grand Total",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              Text(
                "₹${_grandTotal.toStringAsFixed(2)}",
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
        Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      ],
    );
  }

  Widget _buildPaymentAndNotesSection() {
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
            "Payment Status",
            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 8),
          Row(
            children: ['PAID', 'UNPAID', 'PARTIAL'].map((status) {
              final isSelected = _paymentStatus == status;
              Color activeBg;
              Color activeBorder;
              Color activeText;

              if (status == 'PAID') {
                activeBg = const Color(0xFFECFDF5);
                activeBorder = const Color(0xFFA7F3D0);
                activeText = const Color(0xFF10B981);
              } else if (status == 'UNPAID') {
                activeBg = const Color(0xFFFEF2F2);
                activeBorder = const Color(0xFFFECACA);
                activeText = const Color(0xFFEF4444);
              } else {
                activeBg = const Color(0xFFFFFBEB);
                activeBorder = const Color(0xFFFDE68A);
                activeText = const Color(0xFFD97706);
              }

              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: InkWell(
                    onTap: () => setState(() => _paymentStatus = status),
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? activeBg : AppColors.background,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isSelected ? activeBorder : AppColors.cardBorder,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          status,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? activeText : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notesController,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
            decoration: _fieldDecoration(
              labelText: "Terms / Notes (Optional)",
              hintText: "Payment terms, delivery conditions...",
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.cardBorder),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            icon: const Icon(Icons.visibility_outlined, size: 16, color: AppColors.primary),
            label: const Text(
              "Preview PDF",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.primary),
            ),
            onPressed: _previewPdf,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            icon: _isSaving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Icon(Icons.check_rounded, size: 16),
            label: Text(
              _isSaving ? "Issuing..." : "Issue Invoice",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            onPressed: _isSaving ? null : _saveInvoice,
          ),
        ),
      ],
    );
  }
}