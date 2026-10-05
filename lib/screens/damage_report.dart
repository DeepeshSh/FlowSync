import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';
import '../utils/app_theme.dart';
import '../widgets/custom_app_bar.dart';

class DamageReportScreen extends StatefulWidget {
  const DamageReportScreen({super.key});

  @override
  State<DamageReportScreen> createState() => _DamageReportScreenState();
}

class _DamageReportScreenState extends State<DamageReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProductService _productService = ProductService();

  bool _isLoading = true;
  bool _isSaving = false;

  List<Product> _products = [];
  Product? _selectedProduct;

  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _customCauseController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  String? _selectedCause;
  String _selectedSeverity = "Medium";

  final List<String> _damageCauses = [
    "Transit / Handling Damage",
    "Water / Moisture Exposure",
    "Expired / Spoiled",
    "Manufacturing Defect",
    "Storage / Shelf Failure",
    "Other"
  ];

  final List<String> _severityLevels = ["Low", "Medium", "Critical"];

  @override
  void initState() {
    super.initState();
    _dateController.text = DateTime.now().toIso8601String().split('T').first;
    _loadProducts();
  }

  @override
  void dispose() {
    _quantityController.dispose();
    _dateController.dispose();
    _customCauseController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _loadProducts() async {
    try {
      final fetchedProducts = await _productService.getProducts();
      if (mounted) {
        setState(() {
          _products = fetchedProducts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showSnackBar("Failed to load products: $e", AppColors.error);
      }
    }
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

  Future<void> _submitDamageReport() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProduct == null) {
      _showSnackBar("Please select a product first", const Color(0xFFD97706));
      return;
    }

    final damagedQty = int.tryParse(_quantityController.text.trim()) ?? 0;
    if (damagedQty <= 0) {
      _showSnackBar("Please enter a valid damaged quantity", const Color(0xFFD97706));
      return;
    }

    if (damagedQty > _selectedProduct!.stock) {
      _showSnackBar(
        "Damaged quantity cannot exceed available stock (${_selectedProduct!.stock})",
        AppColors.error,
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);

    try {
      final newStockTotal = _selectedProduct!.stock - damagedQty;

      await _productService.updateProductStock(_selectedProduct!.id, newStockTotal);

      _selectedProduct!.stock = newStockTotal;

      if (mounted) {
        _showSnackBar(
          "Damage report logged & stock updated to $newStockTotal Pcs!",
          const Color(0xFF10B981),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar("Failed to submit report: $e", AppColors.error);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  InputDecoration _buildInputDecoration(String hint, {IconData? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 13),
      suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: AppColors.textSecondary, size: 18) : null,
      fillColor: Colors.white,
      filled: true,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
          const SizedBox(height: 12),
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
            decoration: _buildInputDecoration(hint, suffixIcon: suffixIcon),
          ),
        ],
      ),
    );
  }

  Widget _buildNoticeBanner() {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFFECACA)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.report_problem_outlined, color: Color(0xFFEF4444), size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Stock Deduction Notice",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF991B1B),
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  "Submitting this form will permanently subtract reported damaged units from your live inventory.",
                  style: TextStyle(fontSize: 12, color: Color(0xFFB91C1C), height: 1.3),
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
                  : const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
              label: Text(
                _isSaving ? 'Submitting...' : 'Deduct & Submit',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13.5,
                ),
              ),
              onPressed: _isSaving ? null : _submitDamageReport,
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
      appBar: const CustomAppBar(title: "Report Damaged Stock"),
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
                      _buildNoticeBanner(),
                      _buildSectionCard(
                        title: "Select Item & Location",
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
                              "Select product...",
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
                            onChanged: (p) {
                              setState(() {
                                _selectedProduct = p;
                                _locationController.text = p?.storageLocation ?? "";
                              });
                            },
                            decoration: _buildInputDecoration("Select item"),
                          ),
                          const SizedBox(height: 12),
                          _buildTextField(
                            "Storage Location / Rack",
                            "Location e.g. Shelf A-2",
                            _locationController,
                            readOnly: true,
                          ),
                        ],
                      ),
                      _buildSectionCard(
                        title: "Damage Quantities & Date",
                        icon: Icons.warning_amber_rounded,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: _buildTextField(
                                  "Damaged Quantity *",
                                  "e.g. 5",
                                  _quantityController,
                                  isNumber: true,
                                  isMandatory: true,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildTextField(
                                  "Report Date *",
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
                          if (_selectedProduct != null) ...[
                            Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFFBEB),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFFDE68A)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.info_outline, size: 14, color: Color(0xFFD97706)),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Current Available Stock: ${_selectedProduct!.stock} Units",
                                    style: const TextStyle(
                                      color: Color(0xFFD97706),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const Text(
                            "Damage Severity",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12.5,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: _severityLevels.map((lvl) {
                              bool isSelected = _selectedSeverity == lvl;
                              Color activeColor;
                              Color activeBorder;
                              Color activeBg;

                              if (lvl == "Critical") {
                                activeBg = const Color(0xFFFEF2F2);
                                activeBorder = const Color(0xFFFECACA);
                                activeColor = const Color(0xFFEF4444);
                              } else if (lvl == "Medium") {
                                activeBg = const Color(0xFFFFFBEB);
                                activeBorder = const Color(0xFFFDE68A);
                                activeColor = const Color(0xFFD97706);
                              } else {
                                activeBg = const Color(0xFFECFDF5);
                                activeBorder = const Color(0xFFA7F3D0);
                                activeColor = const Color(0xFF10B981);
                              }

                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 3),
                                  child: InkWell(
                                    onTap: () => setState(() => _selectedSeverity = lvl),
                                    borderRadius: BorderRadius.circular(6),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(vertical: 9),
                                      decoration: BoxDecoration(
                                        color: isSelected ? activeBg : AppColors.background,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: isSelected ? activeBorder : AppColors.cardBorder,
                                        ),
                                      ),
                                      child: Text(
                                        lvl,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: isSelected ? activeColor : AppColors.textSecondary,
                                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                          fontSize: 12.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                      ),
                      _buildSectionCard(
                        title: "Cause & Detailed Description",
                        icon: Icons.assignment_outlined,
                        children: [
                          const Text(
                            "Primary Cause *",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12.5,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          DropdownButtonFormField<String>(
                            value: _selectedCause,
                            dropdownColor: Colors.white,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w500,
                            ),
                            hint: const Text(
                              "Select probable cause...",
                              style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                            ),
                            items: _damageCauses.map((cause) {
                              return DropdownMenuItem(
                                value: cause,
                                child: Text(cause, style: const TextStyle(fontSize: 13)),
                              );
                            }).toList(),
                            onChanged: (val) => setState(() => _selectedCause = val),
                            decoration: _buildInputDecoration("Select cause"),
                          ),
                          const SizedBox(height: 12),
                          if (_selectedCause == "Other") ...[
                            _buildTextField(
                              "Specify Custom Reason *",
                              "Type custom cause...",
                              _customCauseController,
                              isMandatory: true,
                            ),
                          ],
                          _buildTextField(
                            "Detailed Description / Notes",
                            "Provide notes on how the damage occurred or condition...",
                            _descriptionController,
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