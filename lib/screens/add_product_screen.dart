import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/product_service.dart';
import '../models/category_model.dart';
import '../models/warehouse_model.dart';
import '../models/supplier_model.dart';

import '../services/category_service.dart';
import '../services/warehouse_service.dart';
import '../services/supplier_service.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProductService _productService = ProductService();
  final CategoryService _categoryService = CategoryService();
  final WarehouseService _warehouseService = WarehouseService();
  final SupplierService _supplierService = SupplierService();
  final ImagePicker _picker = ImagePicker();
  
  bool _isSaving = false;
  File? _pickedImageFile; 

  // Form Controllers
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _brandController = TextEditingController();
  final _hsnController = TextEditingController();
  final _barcodeController = TextEditingController();
  final _descriptionController = TextEditingController();
  
  final _storageController = TextEditingController();
  final _stockController = TextEditingController();
  final _minStockController = TextEditingController();
  final _lengthController = TextEditingController();
  final _widthController = TextEditingController();
  final _heightController = TextEditingController();

  final _purchasePriceController = TextEditingController();
  final _sellingPriceController = TextEditingController();
  final _gstController = TextEditingController();
  final _mrpController = TextEditingController();

  final _amountPaidController = TextEditingController();
  final _balanceController = TextEditingController();
  final _purchaseDateController = TextEditingController();

  // Dropdown States
  Category? _selectedCategory;
  Warehouse? _selectedWarehouse;
  Supplier? _selectedSupplier;
  List<Category> _categories = [];
  List<Warehouse> _warehouses = [];
  List<Supplier> _suppliers = [];
  String? _selectedUnit;
  String? _selectedDimensionUnit = 'Inch';
  String? _selectedFragility = 'No';

  @override
  void initState() {
    super.initState();
    _loadInitialData();
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

  Future<void> _pickProductImage() async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: Color(0xFF2563EB)),
              title: const Text('Choose from Gallery'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
                if (pickedFile != null) {
                  setState(() => _pickedImageFile = File(pickedFile.path));
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined, color: Color(0xFF2563EB)),
              title: const Text('Take Photo with Camera'),
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

    try {
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
 
      await _productService.addProduct(
        name: _nameController.text.trim(),
        sku: _skuController.text.trim(),
        brandName: _brandController.text.trim(),
        category: _selectedCategory!.id,
        warehouseId: _selectedWarehouse!.id,
        storageLocation: _storageController.text.trim(),
        unit: _selectedUnit ?? 'Pcs',
        stock: int.tryParse(_stockController.text.trim()) ?? 0, 
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
        imageUrl: _pickedImageFile?.path ?? '', 
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Product added successfully!'), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving product: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Stack(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeaderCard(),
                          const SizedBox(height: 16),
                          
                          _buildSection(
                            title: '1. Basic Information',
                            icon: Icons.inventory_2_outlined,
                            accentColor: const Color(0xFF2563EB),
                            children: [
                              _buildTextField('Product Name *', 'Enter product name', _nameController, isMandatory: true),
                              
                              // Category Dropdown - Corrected UI Layout
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Category *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF334155))),
                                    const SizedBox(height: 6),
                                    DropdownButtonFormField<Category>(
                                      value: _selectedCategory,
                                      hint: const Text('Select category', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
                                      items: _categories.map((category) {
                                        return DropdownMenuItem(
                                          value: category,
                                          child: Text(category.name, style: const TextStyle(fontSize: 14)),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedCategory = value;
                                        });
                                      },
                                      decoration: InputDecoration(
                                        fillColor: Colors.white,
                                        filled: true,
                                        isDense: true,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              _buildTextField('Brand Name', 'Enter brand name', _brandController),
                              _buildTextField('SKU / Product Code', 'Enter SKU / code', _skuController),
                              _buildTextField('HSN / SAC Code', 'Enter HSN or SAC code', _hsnController),
                              _buildTextField('Barcode (optional)', 'Enter barcode', _barcodeController, suffixIcon: Icons.qr_code_scanner),
                              _buildTextField('Product Description (optional)', 'Enter product description...', _descriptionController, maxLines: 3),
                            ],
                          ),
                          const SizedBox(height: 16),

                          _buildSection(
                            title: '2. Inventory Information',
                            icon: Icons.layers_outlined,
                            accentColor: const Color(0xFF2563EB),
                            children: [
                              
                              // Warehouse Dropdown - Corrected UI Layout
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Warehouse *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF334155))),
                                    const SizedBox(height: 6),
                                    DropdownButtonFormField<Warehouse>(
                                      value: _selectedWarehouse,
                                      hint: const Text('Select warehouse', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
                                      items: _warehouses.map((warehouse) {
                                        return DropdownMenuItem(
                                          value: warehouse,
                                          child: Text(warehouse.name, style: const TextStyle(fontSize: 14)),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedWarehouse = value;
                                        });
                                      },
                                      decoration: InputDecoration(
                                        fillColor: Colors.white,
                                        filled: true,
                                        isDense: true,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              
                              _buildTextField('Storage Location', 'Enter storage location (e.g., A-1)', _storageController),
                              _buildDropdownField('Unit *', 'Select unit', ['Pcs', 'Boxes', 'Meters', 'Liters'], _selectedUnit, (v) => setState(() => _selectedUnit = v)),
                              _buildTextField('Quantity *', 'Enter initial quantity', _stockController, isMandatory: true, isNumber: true),
                              _buildTextField('Minimum Stock Level *', 'Enter minimum stock', _minStockController, isNumber: true),
                              
                              const Padding(
                                padding: EdgeInsets.only(top: 8, bottom: 4),
                                child: Row(
                                  children: [
                                    Text('Product Dimensions', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF334155))),
                                    SizedBox(width: 4),
                                    Icon(Icons.info_outline, size: 14, color: Color(0xFF94A3B8)),
                                  ],
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(child: _buildSimpleBorderField('Length', _lengthController)),
                                  const SizedBox(width: 6),
                                  Expanded(child: _buildSimpleBorderField('Width', _widthController)),
                                  const SizedBox(width: 6),
                                  Expanded(child: _buildSimpleBorderField('Height', _heightController)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _buildDropdownField('Dimension Unit', 'Select unit', ['Inch', 'Cm', 'Mm'], _selectedDimensionUnit, (v) => setState(() => _selectedDimensionUnit = v)),
                              _buildDropdownField('Fragility', 'Select fragility', ['No', 'Yes'], _selectedFragility, (v) => setState(() => _selectedFragility = v)),
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(8)),
                                child: const Row(
                                  children: [
                                    Icon(Icons.info_outline, color: Color(0xFF2563EB), size: 16),
                                    SizedBox(width: 8),
                                    Expanded(child: Text('This product can have multiple variants after saving.', style: TextStyle(color: Color(0xFF2563EB), fontSize: 12, fontWeight: FontWeight.w500))),
                                  ],
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 16),

                          _buildSection(
                            title: '3. Pricing',
                            icon: Icons.local_offer_outlined,
                            accentColor: const Color(0xFF2563EB),
                            children: [
                              _buildTextField('Purchase Price *', '0.00', _purchasePriceController, isNumber: true, prefixText: '₹ '),
                              _buildTextField('Selling Price *', '0.00', _sellingPriceController, isNumber: true, prefixText: '₹ '),
                              _buildTextField('GST % *', '0.00', _gstController, isNumber: true, prefixText: '% '),
                              _buildTextField('MRP (optional)', '0.00', _mrpController, isNumber: true, prefixText: '₹ '),
                            ],
                          ),
                          const SizedBox(height: 16),

                          _buildSection(
                            title: '4. Supplier Information',
                            icon: Icons.local_shipping_outlined,
                            accentColor: const Color(0xFF2563EB),
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('Supplier *', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF334155))),
                                    const SizedBox(height: 6),
                                    DropdownButtonFormField<Supplier>(
                                      value: _selectedSupplier,
                                      hint: const Text('Select supplier', style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
                                      items: _suppliers.map((supplier) {
                                        return DropdownMenuItem(
                                          value: supplier,
                                          child: Text(supplier.supplierName, style: const TextStyle(fontSize: 14)),
                                        );
                                      }).toList(),
                                      onChanged: (value) {
                                        setState(() {
                                          _selectedSupplier = value;
                                        });
                                      },
                                      decoration: InputDecoration(
                                        fillColor: Colors.white,
                                        filled: true,
                                        isDense: true,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              _buildTextField('Amount Paid *', '0.00', _amountPaidController, isNumber: true, prefixText: '₹ '),
                              _buildTextField('Outstanding Balance', '0.00', _balanceController, isNumber: true, prefixText: '₹ '),
                              _buildTextField('Purchase Date *', 'Select date', _purchaseDateController, suffixIcon: Icons.calendar_today_outlined, readOnly: true, onTap: () async {
                                DateTime? picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(2000),
                                  lastDate: DateTime(2101),
                                );
                                if (picked != null) {
                                  setState(() => _purchaseDateController.text = picked.toIso8601String().split('T').first);
                                }
                              }),
                            ],
                          ),
                          const SizedBox(height: 16),

                          _buildSection(
                            title: '5. Product Image',
                            icon: Icons.image_outlined,
                            accentColor: const Color(0xFF2563EB),
                            children: [
                              InkWell(
                                onTap: _pickProductImage,
                                borderRadius: BorderRadius.circular(12),
                                child: Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: const Color(0xFF2563EB).withOpacity(0.4), style: BorderStyle.solid, width: 1.5),
                                  ),
                                  child: _pickedImageFile != null 
                                    ? Column(
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.file(_pickedImageFile!, height: 120, width: 120, fit: BoxFit.cover),
                                          ),
                                          const SizedBox(height: 8),
                                          const Text('Change Product Image', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 13)),
                                        ],
                                      )
                                    : Column(
                                        children: [
                                          const Icon(Icons.cloud_upload_outlined, color: Color(0xFF2563EB), size: 36),
                                          const SizedBox(height: 8),
                                          const Text('Upload Product Image', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 14)),
                                          const SizedBox(height: 4),
                                          Text('PNG • JPG • JPEG\nMaximum size: 5 MB', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade400, fontSize: 11, height: 1.3)),
                                        ],
                                      ),
                                ),
                              )
                            ],
                          ),
                          const SizedBox(height: 16),

                          _buildSection(
                            title: '6. Product Variants',
                            icon: Icons.dashboard_customize_outlined,
                            accentColor: const Color(0xFF10B981),
                            children: [
                              Text('This product can have multiple sizes, models or configurations.', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                              const SizedBox(height: 10),
                              OutlinedButton.icon(
                                style: OutlinedButton.styleFrom(
                                  side: const BorderSide(color: Color(0xFF10B981)),
                                  minimumSize: const Size(double.infinity, 44),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                icon: const Icon(Icons.add, size: 16, color: Color(0xFF10B981)),
                                label: const Text('Add Variants After Saving Product', style: TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold, fontSize: 13)),
                                onPressed: () {},
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: [
                                  _buildSampleChip('Wash Basin → 18", 20", 24"'),
                                  _buildSampleChip('PVC Pipe → ½", 1", 2"'),
                                  _buildSampleChip('Tiles → White, Grey, Black'),
                                ],
                              )
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),
                  _buildBottomStickyActions(),
                ],
              ),
            ),
            
            if (_isSaving)
              Container(
                color: Colors.black.withOpacity(0.3),
                child: const Center(
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Color(0xFF2563EB)),
                          SizedBox(height: 16),
                          Text('Saving Product...', style: TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadInitialData() async {
    try {
      _categories = await _categoryService.getCategories();
      _warehouses = await _warehouseService.getWarehouses();
      _suppliers = await SupplierService().getSuppliers();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Widget _buildHeaderCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 12.0, bottom: 8.0),
      child: Stack(
        children: [
          Positioned(
            right: -10,
            top: 0,
            child: Image.asset(
              'lib/assets/images/addproductheader.png',
              width: 160,
              height: 130,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Container(
                width: 140,
                height: 110,
                decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(16)),
                child: const Icon(Icons.warehouse_outlined, size: 48, color: Color(0xFF2563EB)),
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WidgetInkwell(
                onTap: () => Navigator.pop(context),
                child: Container(
                  height: 40, width: 40,
                  decoration: BoxDecoration(
                    color: Colors.white, 
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6, offset: const Offset(0, 2))],
                  ),
                  child: const Icon(Icons.arrow_back, color: Color(0xFF0F172A), size: 18),
                ),
              ),
              const SizedBox(height: 20),
              const Text('Add Product', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFF0F172A), letterSpacing: -0.8)),
              const SizedBox(height: 6),
              const SizedBox(
                width: 180, 
                child: Text('Create a new inventory item for your business', style: TextStyle(color: Color(0xFF64748B), height: 1.3, fontSize: 13, fontWeight: FontWeight.w400)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title, 
    required IconData icon, 
    required Color accentColor, 
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F5F9)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.01), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: accentColor), 
              const SizedBox(width: 8), 
              Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: accentColor)),
            ],
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10), 
            child: Divider(color: const Color(0xFFF1F5F9), height: 1),
          ),
          ...children
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label, 
    String hint, 
    TextEditingController controller, {
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
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF334155))),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            readOnly: readOnly,
            onTap: onTap,
            maxLines: maxLines,
            keyboardType: isNumber ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
            validator: isMandatory ? (v) => (v == null || v.trim().isEmpty) ? 'Required field' : null : null,
            decoration: InputDecoration(
              hintText: hint,
              prefixText: prefixText,
              hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
              suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: const Color(0xFF94A3B8), size: 18) : null,
              fillColor: Colors.white,
              filled: true,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField(
    String label, 
    String hint, 
    List<String> items, 
    String? selectedValue, 
    ValueChanged<String?> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF334155))),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            value: selectedValue,
            hint: Text(hint, style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
            onChanged: onChanged,
            items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 14)))).toList(),
            decoration: InputDecoration(
              fillColor: Colors.white,
              filled: true,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleBorderField(String hint, TextEditingController controller) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      ),
    );
  }

  Widget _buildSampleChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(6)),
      child: Text(label, style: const TextStyle(color: Color(0xFF475569), fontSize: 11, fontWeight: FontWeight.w500)),
    );
  }

  Widget _buildBottomStickyActions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: Color(0xFFE2E8F0)))),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 46), side: const BorderSide(color: Color(0xFF2563EB)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(minimumSize: const Size(0, 46), backgroundColor: const Color(0xFF2563EB), elevation: 0, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              icon: const Icon(Icons.save_outlined, color: Colors.white, size: 18),
              label: const Text('Save Product', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              onPressed: _submitForm,
            ),
          ),
        ],
      ),
    );
  }
}

class WidgetInkwell extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;
  const WidgetInkwell({super.key, required this.child, required this.onTap});
  @override
  Widget build(BuildContext context) => InkWell(onTap: onTap, borderRadius: BorderRadius.circular(12), child: child);
}