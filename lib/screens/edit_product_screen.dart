import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../models/supplier_model.dart';
import '../models/warehouse_model.dart';
import '../services/category_service.dart';
import '../services/product_service.dart';
import '../services/supplier_service.dart';
import '../services/warehouse_service.dart';
import '../utils/app_theme.dart';
import '../widgets/custom_app_bar.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;

  const EditProductScreen({
    super.key,
    required this.product,
  });

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProductService _productService = ProductService();
  final CategoryService _categoryService = CategoryService();
  final WarehouseService _warehouseService = WarehouseService();
  final SupplierService _supplierService = SupplierService();
  final ImagePicker _picker = ImagePicker();

  bool _isSaving = false;
  File? _pickedImageFile;

  late TextEditingController _nameController;
  late TextEditingController _skuController;
  late TextEditingController _brandController;
  late TextEditingController _hsnController;
  late TextEditingController _barcodeController;
  late TextEditingController _descriptionController;

  late TextEditingController _storageController;
  late TextEditingController _stockController;
  late TextEditingController _minStockController;
  late TextEditingController _lengthController;
  late TextEditingController _widthController;
  late TextEditingController _heightController;

  late TextEditingController _purchasePriceController;
  late TextEditingController _sellingPriceController;
  late TextEditingController _gstController;
  late TextEditingController _mrpController;

  late TextEditingController _amountPaidController;
  late TextEditingController _balanceController;
  late TextEditingController _purchaseDateController;

  Category? _selectedCategory;
  Warehouse? _selectedWarehouse;
  Supplier? _selectedSupplier;
  List<Category> _categories = [];
  List<Warehouse> _warehouses = [];
  List<Supplier> _suppliers = [];
  String? _selectedUnit;
  String? _selectedDimensionUnit;
  String? _selectedFragility;

  @override
  void initState() {
    super.initState();

    Map<String, dynamic> productMap = {};
    try {
      productMap = (widget.product as dynamic).toJson();
    } catch (_) {}

    _nameController = TextEditingController(text: widget.product.name);
    _skuController = TextEditingController(text: widget.product.sku);
    _brandController = TextEditingController(text: widget.product.brandName);

    _hsnController = TextEditingController(text: productMap['hsnCode']?.toString() ?? '');
    _barcodeController = TextEditingController(text: productMap['barcode']?.toString() ?? '');
    _descriptionController = TextEditingController(text: productMap['description']?.toString() ?? '');

    _storageController = TextEditingController(text: widget.product.storageLocation);
    _stockController = TextEditingController(text: widget.product.stock.toString());
    _minStockController = TextEditingController(text: widget.product.lowStockThreshold.toString());

    var dims = productMap['dimensions'] ?? {};
    _lengthController = TextEditingController(text: (dims['length'] ?? productMap['length'] ?? '0.0').toString());
    _widthController = TextEditingController(text: (dims['width'] ?? productMap['width'] ?? '0.0').toString());
    _heightController = TextEditingController(text: (dims['height'] ?? productMap['height'] ?? '0.0').toString());

    _purchasePriceController = TextEditingController(text: widget.product.purchasePrice.toString());
    _sellingPriceController = TextEditingController(text: widget.product.sellingPrice.toString());

    _gstController = TextEditingController(text: (productMap['gstPercentage'] ?? '18.0').toString());
    _mrpController = TextEditingController(text: (productMap['mrp'] ?? '0.0').toString());

    _amountPaidController = TextEditingController(text: (productMap['amountPaid'] ?? '0.0').toString());
    _balanceController = TextEditingController(text: (productMap['outstandingBalance'] ?? '0.0').toString());
    _purchaseDateController = TextEditingController(text: productMap['purchaseDate']?.toString() ?? '');

    _selectedUnit = widget.product.unit;
    _selectedDimensionUnit = dims['unit']?.toString() ?? productMap['dimensionUnit']?.toString() ?? 'Inch';
    _selectedFragility = (productMap['fragile'] == true) ? 'Yes' : 'No';

    _loadInitialData(productMap);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _brandController.dispose();
    _hsnController.dispose();
    _barcodeController.dispose();
    _descriptionController.dispose();
    _storageController.dispose();
    _stockController.dispose();
    _minStockController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _purchasePriceController.dispose();
    _sellingPriceController.dispose();
    _gstController.dispose();
    _mrpController.dispose();
    _amountPaidController.dispose();
    _balanceController.dispose();
    _purchaseDateController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData(Map<String, dynamic> productMap) async {
    try {
      final results = await Future.wait([
        _categoryService.getCategories(),
        _warehouseService.getWarehouses(),
        _supplierService.getSuppliers(),
      ]);

      _categories = results[0] as List<Category>;
      _warehouses = results[1] as List<Warehouse>;
      _suppliers = results[2] as List<Supplier>;

      final categoryId = productMap['category'] ?? productMap['categoryId'];
      final warehouseId = productMap['warehouseId'];
      final supplierName = productMap['supplierName'] ?? widget.product.supplierName;

      if (_categories.isNotEmpty && categoryId != null) {
        try {
          _selectedCategory = _categories.firstWhere(
            (c) => c.id == categoryId.toString() || c.name == categoryId.toString(),
          );
        } catch (_) {}
      }
      if (_warehouses.isNotEmpty && warehouseId != null) {
        try {
          _selectedWarehouse = _warehouses.firstWhere(
            (w) => w.id == warehouseId.toString() || w.name == warehouseId.toString(),
          );
        } catch (_) {}
      }
      if (_suppliers.isNotEmpty && supplierName != null) {
        try {
          _selectedSupplier = _suppliers.firstWhere(
            (s) => s.supplierName.toLowerCase() == supplierName.toString().toLowerCase(),
          );
        } catch (_) {}
      }

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> _pickProductImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
      ),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: AppColors.primary, size: 20),
              title: const Text(
                'Choose from Gallery',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                if (pickedFile != null) {
                  setState(() => _pickedImageFile = File(pickedFile.path));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: AppColors.primary, size: 20),
              title: const Text(
                'Take Photo with Camera',
                style: TextStyle(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                final XFile? pickedFile = await _picker.pickImage(source: ImageSource.camera, imageQuality: 80);
                if (pickedFile != null) {
                  setState(() => _pickedImageFile = File(pickedFile.path));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();

    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a category")),
      );
      return;
    }

    if (_selectedWarehouse == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a warehouse")),
      );
      return;
    }

    if (_selectedSupplier == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a supplier")),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _productService.updateProduct(
        id: widget.product.id,
        name: _nameController.text.trim(),
        sku: _skuController.text.trim(),
        brandName: _brandController.text.trim(),
        category: _selectedCategory!.id,
        warehouseId: _selectedWarehouse!.id,
        storageLocation: _storageController.text.trim(),
        unit: _selectedUnit ?? 'Pcs',
        stock: int.tryParse(_stockController.text.trim()) ?? widget.product.stock,
        lowStockThreshold: int.tryParse(_minStockController.text) ?? 10,
        purchasePrice: double.tryParse(_purchasePriceController.text) ?? 0.0,
        sellingPrice: double.tryParse(_sellingPriceController.text) ?? 0.0,
        hsnCode: _hsnController.text.trim(),
        barcode: _barcodeController.text.trim(),
        description: _descriptionController.text.trim(),
        length: double.tryParse(_lengthController.text) ?? 0.0,
        width: double.tryParse(_widthController.text) ?? 0.0,
        height: double.tryParse(_heightController.text) ?? 0.0,
        dimensionUnit: _selectedDimensionUnit ?? 'Inch',
        fragile: _selectedFragility == 'Yes',
        gstPercentage: double.tryParse(_gstController.text) ?? 18.0,
        mrp: double.tryParse(_mrpController.text) ?? 0.0,
        supplierName: _selectedSupplier!.supplierName,
        amountPaid: double.tryParse(_amountPaidController.text) ?? 0.0,
        outstandingBalance: double.tryParse(_balanceController.text) ?? 0.0,
        purchaseDate: _purchaseDateController.text.isNotEmpty
            ? _purchaseDateController.text
            : DateTime.now().toIso8601String().split('T').first,
        imageUrl: _pickedImageFile != null ? _pickedImageFile!.path : widget.product.imageUrl,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product updated successfully!')),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating product: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  InputDecoration _fieldDecoration({String? hint, String? prefixText, IconData? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      prefixText: prefixText,
      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
      suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: AppColors.textSecondary, size: 18) : null,
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

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
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
          Row(
            children: [
              Icon(icon, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool isMandatory = false,
    bool isNumber = false,
    IconData? suffixIcon,
    String? prefixText,
    bool readOnly = false,
    VoidCallback? onTap,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            readOnly: readOnly,
            onTap: onTap,
            maxLines: maxLines,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
            keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
            validator: isMandatory ? (v) => (v == null || v.trim().isEmpty) ? 'Required field' : null : null,
            decoration: _fieldDecoration(hint: hint, prefixText: prefixText, suffixIcon: suffixIcon),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String hint,
    required List<String> itemsList,
    required String? selectedValue,
    required ValueChanged<String?> onChanged,
  }) {
    List<String> items = List<String>.from(itemsList);
    String? validValue;

    if (selectedValue != null && selectedValue.trim().isNotEmpty) {
      final trimmed = selectedValue.trim();
      for (final item in items) {
        if (item.toLowerCase() == trimmed.toLowerCase()) {
          validValue = item;
          break;
        }
      }
      if (validValue == null) {
        items.add(trimmed);
        validValue = trimmed;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: validValue,
            dropdownColor: Colors.white,
            style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
            hint: Text(hint, style: const TextStyle(color: AppColors.textMuted, fontSize: 13)),
            onChanged: onChanged,
            items: items
                .map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13))))
                .toList(),
            decoration: _fieldDecoration(),
          ),
        ],
      ),
    );
  }

  Widget _buildDimensionField(String hint, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(fontSize: 13, color: AppColors.textPrimary, fontWeight: FontWeight.w500),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: _fieldDecoration(hint: hint),
    );
  }

  Widget _buildBottomStickyActions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.cardBorder)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 48),
                side: const BorderSide(color: AppColors.cardBorder),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 13.5),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, 48),
                backgroundColor: AppColors.primary,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: _isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined, color: Colors.white, size: 18),
              label: Text(
                _isSaving ? 'Updating...' : 'Update Product',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13.5),
              ),
              onPressed: _isSaving ? null : _submitForm,
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
      appBar: const CustomAppBar(
        title: 'Edit Product',
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionCard(
                        title: 'Basic Information',
                        icon: Icons.inventory_2_outlined,
                        children: [
                          _buildField(
                            label: 'Product Name *',
                            hint: 'Enter product name',
                            controller: _nameController,
                            isMandatory: true,
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Category *',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12.5,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<Category>(
                                  value: _categories.contains(_selectedCategory) ? _selectedCategory : null,
                                  dropdownColor: Colors.white,
                                  hint: const Text('Select category', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                                  items: _categories.map((category) {
                                    return DropdownMenuItem(
                                      value: category,
                                      child: Text(category.name, style: const TextStyle(fontSize: 13)),
                                    );
                                  }).toList(),
                                  onChanged: (value) => setState(() => _selectedCategory = value),
                                  decoration: _fieldDecoration(),
                                ),
                              ],
                            ),
                          ),
                          _buildField(label: 'Brand Name', hint: 'Enter brand name', controller: _brandController),
                          _buildField(label: 'SKU / Product Code', hint: 'Enter SKU / code', controller: _skuController),
                          _buildField(label: 'HSN / SAC Code', hint: 'Enter HSN or SAC code', controller: _hsnController),
                          _buildField(label: 'Barcode (optional)', hint: 'Enter barcode', controller: _barcodeController, suffixIcon: Icons.qr_code_scanner),
                          _buildField(label: 'Product Description (optional)', hint: 'Enter product description...', controller: _descriptionController, maxLines: 3),
                        ],
                      ),
                      _buildSectionCard(
                        title: 'Inventory Information',
                        icon: Icons.layers_outlined,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Warehouse *',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12.5,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<Warehouse>(
                                  value: _warehouses.contains(_selectedWarehouse) ? _selectedWarehouse : null,
                                  dropdownColor: Colors.white,
                                  hint: const Text('Select warehouse', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                                  items: _warehouses.map((warehouse) {
                                    return DropdownMenuItem(
                                      value: warehouse,
                                      child: Text(warehouse.name, style: const TextStyle(fontSize: 13)),
                                    );
                                  }).toList(),
                                  onChanged: (value) => setState(() => _selectedWarehouse = value),
                                  decoration: _fieldDecoration(),
                                ),
                              ],
                            ),
                          ),
                          _buildField(label: 'Storage Location', hint: 'Enter storage location (e.g., A-1)', controller: _storageController),
                          _buildDropdownField(
                            label: 'Unit *',
                            hint: 'Select unit',
                            itemsList: ['Piece', 'Pcs', 'Boxes', 'Meters', 'Liters'],
                            selectedValue: _selectedUnit,
                            onChanged: (v) => setState(() => _selectedUnit = v),
                          ),
                          _buildField(label: 'Quantity *', hint: 'Enter quantity', controller: _stockController, isMandatory: true, isNumber: true),
                          _buildField(label: 'Minimum Stock Level *', hint: 'Enter minimum stock', controller: _minStockController, isNumber: true),
                          const Padding(
                            padding: EdgeInsets.only(top: 4, bottom: 6),
                            child: Text(
                              'Product Dimensions',
                              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.5, color: AppColors.textPrimary),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(child: _buildDimensionField('Length', _lengthController)),
                              const SizedBox(width: 8),
                              Expanded(child: _buildDimensionField('Width', _widthController)),
                              const SizedBox(width: 8),
                              Expanded(child: _buildDimensionField('Height', _heightController)),
                            ],
                          ),
                          const SizedBox(height: 12),
                          _buildDropdownField(
                            label: 'Dimension Unit',
                            hint: 'Select unit',
                            itemsList: ['Inch', 'Cm', 'Mm'],
                            selectedValue: _selectedDimensionUnit,
                            onChanged: (v) => setState(() => _selectedDimensionUnit = v),
                          ),
                          _buildDropdownField(
                            label: 'Fragility',
                            hint: 'Select fragility',
                            itemsList: ['No', 'Yes'],
                            selectedValue: _selectedFragility,
                            onChanged: (v) => setState(() => _selectedFragility = v),
                          ),
                        ],
                      ),
                      _buildSectionCard(
                        title: 'Pricing',
                        icon: Icons.local_offer_outlined,
                        children: [
                          _buildField(label: 'Purchase Price *', hint: '0.00', controller: _purchasePriceController, isNumber: true, prefixText: '₹ '),
                          _buildField(label: 'Selling Price *', hint: '0.00', controller: _sellingPriceController, isNumber: true, prefixText: '₹ '),
                          _buildField(label: 'GST % *', hint: '0.00', controller: _gstController, isNumber: true, prefixText: '% '),
                          _buildField(label: 'MRP (optional)', hint: '0.00', controller: _mrpController, isNumber: true, prefixText: '₹ '),
                        ],
                      ),
                      _buildSectionCard(
                        title: 'Supplier Information',
                        icon: Icons.local_shipping_outlined,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Supplier *',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12.5,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                DropdownButtonFormField<Supplier>(
                                  value: _suppliers.contains(_selectedSupplier) ? _selectedSupplier : null,
                                  dropdownColor: Colors.white,
                                  hint: const Text('Select supplier', style: TextStyle(color: AppColors.textMuted, fontSize: 13)),
                                  items: _suppliers.map((supplier) {
                                    return DropdownMenuItem(
                                      value: supplier,
                                      child: Text(supplier.supplierName, style: const TextStyle(fontSize: 13)),
                                    );
                                  }).toList(),
                                  onChanged: (value) => setState(() => _selectedSupplier = value),
                                  decoration: _fieldDecoration(),
                                ),
                              ],
                            ),
                          ),
                          _buildField(label: 'Amount Paid *', hint: '0.00', controller: _amountPaidController, isNumber: true, prefixText: '₹ '),
                          _buildField(label: 'Outstanding Balance', hint: '0.00', controller: _balanceController, isNumber: true, prefixText: '₹ '),
                          _buildField(
                            label: 'Purchase Date *',
                            hint: 'Select date',
                            controller: _purchaseDateController,
                            suffixIcon: Icons.calendar_today_outlined,
                            readOnly: true,
                            onTap: () async {
                              DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(2000),
                                lastDate: DateTime(2101),
                              );
                              if (picked != null) {
                                setState(() => _purchaseDateController.text = picked.toIso8601String().split('T').first);
                              }
                            },
                          ),
                        ],
                      ),
                      _buildSectionCard(
                        title: 'Product Image',
                        icon: Icons.image_outlined,
                        children: [
                          InkWell(
                            onTap: _pickProductImage,
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                              decoration: BoxDecoration(
                                color: AppColors.background,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.cardBorder),
                              ),
                              child: _pickedImageFile != null
                                  ? Column(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(6),
                                          child: Image.file(_pickedImageFile!, height: 110, width: 110, fit: BoxFit.cover),
                                        ),
                                        const SizedBox(height: 8),
                                        const Text(
                                          'Change Product Image',
                                          style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13),
                                        ),
                                      ],
                                    )
                                  : widget.product.imageUrl.isNotEmpty
                                      ? Column(
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(6),
                                              child: widget.product.imageUrl.startsWith('http')
                                                  ? Image.network(
                                                      widget.product.imageUrl,
                                                      height: 110,
                                                      width: 110,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (_, ___, ____) => const Icon(Icons.broken_image_outlined, size: 36, color: AppColors.textMuted),
                                                    )
                                                  : Image.file(
                                                      File(widget.product.imageUrl),
                                                      height: 110,
                                                      width: 110,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (_, ___, ____) => const Icon(Icons.broken_image_outlined, size: 36, color: AppColors.textMuted),
                                                    ),
                                            ),
                                            const SizedBox(height: 8),
                                            const Text(
                                              'Change Product Image',
                                              style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600, fontSize: 13),
                                            ),
                                          ],
                                        )
                                      : Column(
                                          children: const [
                                            Icon(Icons.cloud_upload_outlined, color: AppColors.primary, size: 32),
                                            SizedBox(height: 8),
                                            Text(
                                              'Upload Product Image',
                                              style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600, fontSize: 13.5),
                                            ),
                                            SizedBox(height: 4),
                                            Text(
                                              'PNG • JPG • JPEG (Up to 5 MB)',
                                              style: TextStyle(color: AppColors.textMuted, fontSize: 11.5),
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
              ),
            ),
            _buildBottomStickyActions(),
          ],
        ),
      ),
    );
  }
}