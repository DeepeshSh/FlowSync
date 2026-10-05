import 'package:flutter/material.dart';

import '../models/product_model.dart';
import '../models/variant_model.dart';
import '../models/warehouse_model.dart';
import '../services/variant_service.dart';
import '../services/warehouse_service.dart';
import '../utils/app_theme.dart';
import '../widgets/custom_app_bar.dart';

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

  InputDecoration inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
      prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 18),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.cardBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.primary, width: 1.2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: AppColors.error, width: 1.2),
      ),
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildProductHeaderBanner() {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.product.name,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            "Parent SKU: ${widget.product.sku}",
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: widget.variant == null ? "Add Variant" : "Edit Variant",
      ),
      body: Column(
        children: [
          _buildProductHeaderBanner(),
          const Divider(height: 1, color: AppColors.cardBorder),
          Expanded(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                child: Column(
                  children: [
                    _buildSectionCard(
                      title: "Variant Identity",
                      children: [
                        TextFormField(
                          controller: variantNameController,
                          style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                          validator: (v) => (v == null || v.trim().isEmpty) ? "Required" : null,
                          decoration: inputDecoration("Variant Title (e.g., XL / Black)", Icons.layers_outlined),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: skuController,
                          style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                          validator: (v) => (v == null || v.trim().isEmpty) ? "Required" : null,
                          decoration: inputDecoration("Variant SKU", Icons.qr_code_outlined),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: barcodeController,
                          style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                          decoration: inputDecoration("Barcode", Icons.barcode_reader),
                        ),
                      ],
                    ),
                    _buildSectionCard(
                      title: "Logistics & Stock",
                      children: [
                        DropdownButtonFormField<Warehouse>(
                          value: selectedWarehouse,
                          dropdownColor: Colors.white,
                          style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                          decoration: inputDecoration("Select Warehouse", Icons.warehouse_outlined),
                          items: warehouses.map((warehouse) {
                            return DropdownMenuItem(
                              value: warehouse,
                              child: Text(warehouse.name, style: const TextStyle(fontSize: 13)),
                            );
                          }).toList(),
                          onChanged: (value) => setState(() => selectedWarehouse = value),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: storageController,
                          style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                          decoration: inputDecoration("Storage Location / Bin Number", Icons.location_on_outlined),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: stockController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                                decoration: inputDecoration("Initial Stock", Icons.inventory_2_outlined),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: lowStockController,
                                keyboardType: TextInputType.number,
                                style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                                decoration: inputDecoration("Alert Threshold", Icons.warning_amber_rounded),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    _buildSectionCard(
                      title: "Pricing & Taxation",
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: purchaseController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                                decoration: inputDecoration("Purchase Cost", Icons.shopping_bag_outlined),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: sellingController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                                decoration: inputDecoration("Selling Price", Icons.sell_outlined),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: mrpController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                                decoration: inputDecoration("MRP", Icons.payments_outlined),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: gstController,
                                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                style: const TextStyle(fontSize: 13, color: AppColors.textPrimary),
                                decoration: inputDecoration("GST %", Icons.percent_outlined),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Container(
                      margin: const EdgeInsets.only(bottom: 24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.cardBorder),
                      ),
                      child: SwitchListTile(
                        value: isActive,
                        activeColor: AppColors.primary,
                        title: const Text(
                          "Make variant visible and active",
                          style: TextStyle(
                            fontSize: 13.5,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        onChanged: (value) => setState(() => isActive = value),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.cardBorder)),
            ),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: isLoading ? null : saveVariant,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        widget.variant == null ? "Create Variant" : "Save Changes",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}