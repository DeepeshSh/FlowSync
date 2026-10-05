import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../config/api_config.dart';
import '../models/product_model.dart';
import '../models/warehouse_model.dart';
import '../services/product_service.dart';
import '../services/warehouse_service.dart';
import '../utils/app_theme.dart';
import '../widgets/custom_app_bar.dart';

class StockMovementScreen extends StatefulWidget {
  const StockMovementScreen({super.key});

  @override
  State<StockMovementScreen> createState() => _StockMovementScreenState();
}

class _StockMovementScreenState extends State<StockMovementScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProductService _productService = ProductService();
  final WarehouseService _warehouseService = WarehouseService();
  final Dio dio = Dio();

  bool _isLoading = true;
  bool _isSaving = false;

  List<Product> _products = [];
  List<Warehouse> _warehouses = [];

  Product? _selectedProduct;
  Warehouse? _sourceWarehouse;
  Warehouse? _destinationWarehouse;
  String? _selectedReason = "Inter-branch Transfer";

  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _sourceLocationController = TextEditingController();
  final TextEditingController _destLocationController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  final List<String> _movementReasons = [
    "Inter-branch Transfer",
    "Warehouse Consolidation",
    "Demand Adjustment",
    "Overstock Re-allocation",
    "Return to Primary Storage",
    "Other",
  ];

  @override
  void initState() {
    super.initState();
    _dateController.text = DateTime.now().toIso8601String().split('T').first;
    _loadInitialData();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _sourceLocationController.dispose();
    _destLocationController.dispose();
    _dateController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    try {
      final fetchedProducts = await _productService.getProducts();
      final fetchedWarehouses = await _warehouseService.getWarehouses();

      if (mounted) {
        setState(() {
          _products = fetchedProducts;
          _warehouses = fetchedWarehouses;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackBar("Failed to load initial data: $e", AppColors.error);
      }
    }
  }

  void _onProductSelected(Product? product) {
    if (product == null) return;

    setState(() {
      _selectedProduct = product;
      _quantityController.text = product.stock.toString();
      _sourceLocationController.text =
          product.storageLocation.isNotEmpty ? product.storageLocation : "Main Shelf";

      try {
        _sourceWarehouse = _warehouses.firstWhere(
          (w) => w.id == product.warehouseId || w.name.toLowerCase() == product.storageLocation.toLowerCase(),
        );
      } catch (_) {
        if (_warehouses.isNotEmpty) {
          _sourceWarehouse = _warehouses.first;
        }
      }
    });
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

  Future<void> _submitStockMovement() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedProduct == null) {
      _showSnackBar("Please select a product to transfer", const Color(0xFFD97706));
      return;
    }

    if (_destinationWarehouse == null) {
      _showSnackBar("Please select a destination warehouse", const Color(0xFFD97706));
      return;
    }

    if (_sourceWarehouse != null && _sourceWarehouse!.id == _destinationWarehouse!.id) {
      _showSnackBar("Destination warehouse must be different from source warehouse", const Color(0xFFD97706));
      return;
    }

    final transferQty = int.tryParse(_quantityController.text.trim()) ?? 0;
    if (transferQty <= 0) {
      _showSnackBar("Please enter a valid transfer quantity", const Color(0xFFD97706));
      return;
    }

    if (transferQty > _selectedProduct!.stock) {
      _showSnackBar("Transfer quantity cannot exceed current stock (${_selectedProduct!.stock})", AppColors.error);
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);

    try {
      final newStorageLocation = _destLocationController.text.trim();

      final response = await dio.put(
        "${ApiConfig.baseUrl}/products/${_selectedProduct!.id}",
        data: {
          "warehouseId": _destinationWarehouse!.id,
          "storageLocation": newStorageLocation,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        _selectedProduct!.warehouseId = _destinationWarehouse!.id;
        _selectedProduct!.storageLocation = newStorageLocation;

        if (mounted) {
          _showSnackBar(
            "Stock location moved to ${_destinationWarehouse!.name} ($newStorageLocation)!",
            const Color(0xFF10B981),
          );
          Navigator.pop(context, true);
        }
      } else {
        throw "Server returned status code ${response.statusCode}";
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar("Failed to move stock: $e", AppColors.error);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  InputDecoration _fieldDecoration({String? hint, IconData? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
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

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller, {
    bool isMandatory = false,
    bool isNumber = false,
    IconData? suffixIcon,
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
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            validator: isMandatory ? (v) => (v == null || v.trim().isEmpty) ? 'Required field' : null : null,
            decoration: _fieldDecoration(hint: hint, suffixIcon: suffixIcon),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EEF5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.swap_horiz_rounded, color: AppColors.primary, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Stock Transfer & Relocation",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "Relocate inventory between warehouses or update exact storage rack addresses.",
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.3),
                ),
              ],
            ),
          ),
        ],
      ),
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
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13.5,
                ),
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
                  : const Icon(Icons.swap_horiz, color: Colors.white, size: 18),
              label: Text(
                _isSaving ? 'Executing...' : 'Execute Movement',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13.5,
                ),
              ),
              onPressed: _isSaving ? null : _submitStockMovement,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: "Stock Movement"),
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
                      _buildHeaderBanner(),
                      _buildSectionCard(
                        title: "Select Item & Quantity",
                        icon: Icons.inventory_2_outlined,
                        children: [
                          const Text(
                            "Product *",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12.5,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<Product>(
                            value: _selectedProduct,
                            dropdownColor: Colors.white,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                            hint: const Text(
                              "Select product to move...",
                              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                            ),
                            items: _products.map((p) {
                              return DropdownMenuItem(
                                value: p,
                                child: Text(
                                  "${p.name} (Stock: ${p.stock})",
                                  style: const TextStyle(fontSize: 13),
                                ),
                              );
                            }).toList(),
                            onChanged: _onProductSelected,
                            decoration: _fieldDecoration(),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  "Moving Quantity *",
                                  "e.g. 10",
                                  _quantityController,
                                  isNumber: true,
                                  isMandatory: true,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildTextField(
                                  "Transfer Date *",
                                  "Select date",
                                  _dateController,
                                  readOnly: true,
                                  suffixIcon: Icons.calendar_today_outlined,
                                  onTap: () async {
                                    DateTime? picked = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2024),
                                      lastDate: DateTime(2035),
                                    );
                                    if (picked != null) {
                                      setState(() {
                                        _dateController.text = picked.toIso8601String().split('T').first;
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      _buildSectionCard(
                        title: "Origin & Destination Route",
                        icon: Icons.alt_route_rounded,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.background,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: AppColors.cardBorder),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: const [
                                    Icon(Icons.outbound_outlined, size: 14, color: Color(0xFFD97706)),
                                    SizedBox(width: 6),
                                    Text(
                                      "FROM (Current Origin)",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11,
                                        color: Color(0xFFD97706),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _sourceWarehouse?.name ?? "Current Warehouse",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13.5,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  "Rack/Location: ${_sourceLocationController.text.isNotEmpty ? _sourceLocationController.text : "Unassigned"}",
                                  style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            "Destination Warehouse *",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12.5,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<Warehouse>(
                            value: _destinationWarehouse,
                            dropdownColor: Colors.white,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                            hint: const Text(
                              "Select target warehouse...",
                              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                            ),
                            items: _warehouses.map((w) {
                              return DropdownMenuItem(
                                value: w,
                                child: Text(w.name, style: const TextStyle(fontSize: 13)),
                              );
                            }).toList(),
                            onChanged: (w) => setState(() => _destinationWarehouse = w),
                            decoration: _fieldDecoration(),
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            "Exact Storage Location (Rack/Shelf/Bin) *",
                            "e.g. Rack B-3, Shelf 2",
                            _destLocationController,
                            isMandatory: true,
                          ),
                        ],
                      ),
                      _buildSectionCard(
                        title: "Reason & Remarks",
                        icon: Icons.assignment_outlined,
                        children: [
                          const Text(
                            "Movement Reason *",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12.5,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            value: _selectedReason,
                            dropdownColor: Colors.white,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                            hint: const Text(
                              "Select movement reason...",
                              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                            ),
                            items: _movementReasons.map((r) {
                              return DropdownMenuItem(
                                value: r,
                                child: Text(r, style: const TextStyle(fontSize: 13)),
                              );
                            }).toList(),
                            onChanged: (val) => setState(() => _selectedReason = val),
                            decoration: _fieldDecoration(),
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            "Additional Notes / Authorization",
                            "Enter driver info, transfer slip no., or authorization notes...",
                            _notesController,
                            maxLines: 3,
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