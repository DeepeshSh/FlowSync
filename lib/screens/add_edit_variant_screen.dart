import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../models/variant_model.dart';
import '../models/warehouse_model.dart';

import '../services/variant_service.dart';
import '../services/warehouse_service.dart';

class AddEditVariantScreen extends StatefulWidget {
  final Product product;
  final Variant? variant;

  const AddEditVariantScreen({
    super.key,
    required this.product,
    this.variant,
  });

  @override
  State<AddEditVariantScreen> createState() => _AddEditVariantScreenState();
}

class _AddEditVariantScreenState extends State<AddEditVariantScreen> {
  final _formKey = GlobalKey<FormState>();
  final VariantService _variantService = VariantService();
  final WarehouseService _warehouseService = WarehouseService();

  final variantNameController = TextEditingController();
  final skuController = TextEditingController();
  final barcodeController = TextEditingController();
  final storageController = TextEditingController();
  final stockController = TextEditingController();
  final purchaseController = TextEditingController();
  final sellingController = TextEditingController();
  final mrpController = TextEditingController();
  final gstController = TextEditingController();
  final lowStockController = TextEditingController();

  List<Warehouse> warehouses = [];
  Warehouse? selectedWarehouse;
  bool isActive = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadWarehouses();

    if (widget.variant != null) {
      final v = widget.variant!;
      variantNameController.text = v.variantName;
      skuController.text = v.sku;
      barcodeController.text = v.barcode;
      storageController.text = v.storageLocation;
      stockController.text = v.stock.toString();
      purchaseController.text = v.purchasePrice.toString();
      sellingController.text = v.sellingPrice.toString();
      mrpController.text = v.mrp.toString();
      gstController.text = v.gstPercentage.toString();
      lowStockController.text = v.lowStockThreshold.toString();
      isActive = v.isActive;
    }
  }

  Future<void> loadWarehouses() async {
    try {
      final data = await _warehouseService.getWarehouses();
      if (!mounted) return;
      setState(() {
        warehouses = data;
        if (widget.variant != null) {
          try {
            selectedWarehouse = warehouses.firstWhere(
              (e) => e.id == widget.variant!.warehouseId,
            );
          } catch (_) {}
        }
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  Future<void> saveVariant() async {
    if (!_formKey.currentState!.validate()) return;

    if (selectedWarehouse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a warehouse")),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      if (widget.variant == null) {
        await _variantService.createVariant(
          productId: widget.product.id,
          variantName: variantNameController.text.trim(),
          sku: skuController.text.trim(),
          barcode: barcodeController.text.trim(),
          warehouseId: selectedWarehouse!.id,
          storageLocation: storageController.text.trim(),
          stock: int.parse(stockController.text),
          reservedStock: 0,
          lowStockThreshold: int.parse(lowStockController.text),
          purchasePrice: double.parse(purchaseController.text),
          sellingPrice: double.parse(sellingController.text),
          mrp: double.parse(mrpController.text),
          gstPercentage: double.parse(gstController.text),
          imageUrl: "",
          isActive: isActive,
        );
      } else {
        await _variantService.updateVariant(
          id: widget.variant!.id,
          variantName: variantNameController.text.trim(),
          sku: skuController.text.trim(),
          barcode: barcodeController.text.trim(),
          warehouseId: selectedWarehouse!.id,
          storageLocation: storageController.text.trim(),
          stock: int.parse(stockController.text),
          reservedStock: 0,
          lowStockThreshold: int.parse(lowStockController.text),
          purchasePrice: double.parse(purchaseController.text),
          sellingPrice: double.parse(sellingController.text),
          mrp: double.parse(mrpController.text),
          gstPercentage: double.parse(gstController.text),
          imageUrl: "",
          isActive: isActive,
        );
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    variantNameController.dispose();
    skuController.dispose();
    barcodeController.dispose();
    storageController.dispose();
    stockController.dispose();
    purchaseController.dispose();
    sellingController.dispose();
    mrpController.dispose();
    gstController.dispose();
    lowStockController.dispose();
    super.dispose();
  }

  // Modern Input Field Decoration Builder
  InputDecoration inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF64748B), fontSize: 14),
      prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 20),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent),
      ),
    );
  }

  // Wrapper layout for sub-sections
  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF475569),
              letterSpacing: 0.5,
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(color: Color(0xFFF1F5F9), height: 1),
          ),
          ...children,
        ],
      ),
    );
  }

  // Minimalist Core Header Component
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(8, 8, 20, 16),
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back, color: Color(0xFF1E293B)),
                ),
                const SizedBox(width: 4),
                Text(
                  widget.variant == null ? "Add Variant" : "Edit Variant",
                  style: const TextStyle(
                    color: Color(0xFF1E293B),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Parent SKU: ${widget.product.sku}",
                    style: const TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Section 1: Identity & Key Identifiers
                    _buildSectionCard(
                      title: "VARIANT IDENTITY",
                      children: [
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: variantNameController,
                          validator: (v) => (v == null || v.trim().isEmpty) ? "Required" : null,
                          decoration: inputDecoration("Variant Title (e.g., XL / Black)", Icons.layers_outlined),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: skuController,
                          validator: (v) => (v == null || v.trim().isEmpty) ? "Required" : null,
                          decoration: inputDecoration("Variant SKU", Icons.qr_code_outlined),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: barcodeController,
                          decoration: inputDecoration("Barcode", Icons.barcode_reader),
                        ),
                      ],
                    ),

                    // Section 2: Logistics & Inventory Management
                    _buildSectionCard(
                      title: "LOGISTICS & STOCK",
                      children: [
                        const SizedBox(height: 8),
                        DropdownButtonFormField<Warehouse>(
                          value: selectedWarehouse,
                          decoration: inputDecoration("Select Warehouse", Icons.warehouse_outlined),
                          items: warehouses.map((warehouse) {
                            return DropdownMenuItem(
                              value: warehouse,
                              child: Text(warehouse.name, style: const TextStyle(fontSize: 15)),
                            );
                          }).toList(),
                          onChanged: (value) => setState(() => selectedWarehouse = value),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: storageController,
                          decoration: inputDecoration("Storage Location / Bin Number", Icons.location_on_outlined),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: stockController,
                                keyboardType: TextInputType.number,
                                decoration: inputDecoration("Initial Stock", Icons.inventory_2_outlined),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: lowStockController,
                                keyboardType: TextInputType.number,
                                decoration: inputDecoration("Alert Threshold", Icons.warning_amber_rounded),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Section 3: Pricing Structure
                    _buildSectionCard(
                      title: "PRICING & TAXATION",
                      children: [
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: purchaseController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: inputDecoration("Purchase Cost", Icons.shopping_bag_outlined),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: sellingController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: inputDecoration("Selling Price", Icons.sell_outlined),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: mrpController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: inputDecoration("MRP", Icons.payments_outlined),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: gstController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                decoration: inputDecoration("GST %", Icons.percent_outlined),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Activation Switch Block
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: SwitchListTile(
                        value: isActive,
                        activeColor: const Color(0xFF2563EB),
                        title: const Text(
                          "Make variant visible and active",
                          style: TextStyle(fontSize: 14, color: Color(0xFF334155), fontWeight: FontWeight.w500),
                        ),
                        onChanged: (value) => setState(() => isActive = value),
                      ),
                    ),

                    // Modern Primary Action Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : saveVariant,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          disabledBackgroundColor: const Color(0xFF93C5FD),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5),
                              )
                            : Text(
                                widget.variant == null ? "Create Variant" : "Save Changes",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                        ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}