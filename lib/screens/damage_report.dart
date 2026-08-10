import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

class DamageReportScreen extends StatefulWidget {
  const DamageReportScreen({super.key});

  @override
  State<DamageReportScreen> createState() => _DamageReportScreenState();
}

class _DamageReportScreenState extends State<DamageReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final ProductService _productService = ProductService();

  // State flags
  bool _isLoading = true;
  bool _isSaving = false;

  // Data
  List<Product> _products = [];
  Product? _selectedProduct;
  String? _selectedVariant = "Standard";

  // Controllers
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _customCauseController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  // Dropdown States
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
        _showSnackBar("Failed to load products: $e", Colors.red);
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
      _showSnackBar("Please select a product first", Colors.orange);
      return;
    }

    final damagedQty = int.tryParse(_quantityController.text.trim()) ?? 0;
    if (damagedQty <= 0) {
      _showSnackBar("Please enter a valid damaged quantity", Colors.orange);
      return;
    }

    if (damagedQty > _selectedProduct!.stock) {
      _showSnackBar("Damaged quantity cannot exceed available stock (${_selectedProduct!.stock})", Colors.red);
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);

    try {
      // 1. Calculate remaining stock
      final newStockTotal = _selectedProduct!.stock - damagedQty;

      // 2. Call PUT request with updated stock count
      await _productService.updateProductStock(_selectedProduct!.id, newStockTotal);

      // 3. Mutate local model stock
      _selectedProduct!.stock = newStockTotal;

      if (mounted) {
        _showSnackBar("Damage report logged & stock updated to $newStockTotal Pcs!", Colors.green);
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar("Failed to submit report: $e", Colors.red);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFFF5F7FC),
        body: Center(child: CircularProgressIndicator(color: Color(0xFF2563EB))),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFF1B2559), size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Report Damaged Stock",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1B2559),
          ),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildHeaderBanner(),
                          const SizedBox(height: 20),
                          
                          // Section 1: Item & Location Details
                          _buildSectionCard(
                            title: "1. Select Item & Location",
                            icon: Icons.inventory_2_outlined,
                            accentColor: const Color(0xFF2563EB),
                            children: [
                              // Product Dropdown
                              const Text("Product *", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF334155))),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<Product>(
                                value: _selectedProduct,
                                hint: const Text("Select product...", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
                                items: _products.map((p) {
                                  return DropdownMenuItem(
                                    value: p,
                                    child: Text("${p.name} (Stock: ${p.stock})", style: const TextStyle(fontSize: 14)),
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
                              const SizedBox(height: 14),

                              // Storage Location Auto-filled
                              _buildTextField("Storage Location / Rack", "Location e.g. Shelf A-2", _locationController, readOnly: true),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Section 2: Damage Metrics
                          _buildSectionCard(
                            title: "2. Damage Quantities & Date",
                            icon: Icons.warning_amber_rounded,
                            accentColor: const Color(0xFFEF4444),
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
                                          setState(() => _dateController.text = picked.toIso8601String().split('T').first);
                                        }
                                      },
                                    ),
                                  ),
                                ],
                              ),

                              // Available Stock Reminder Callout
                              if (_selectedProduct != null) ...[
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF7ED),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: const Color(0xFFFFEDD5)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.info_outline, size: 16, color: Colors.orange),
                                      const SizedBox(width: 8),
                                      Text(
                                        "Current Available Stock: ${_selectedProduct!.stock} Units",
                                        style: const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],

                              // Severity Level Selector
                              const Text("Damage Severity", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF334155))),
                              const SizedBox(height: 6),
                              Row(
                                children: _severityLevels.map((lvl) {
                                  bool isSelected = _selectedSeverity == lvl;
                                  return Expanded(
                                    child: GestureDetector(
                                      onTap: () => setState(() => _selectedSeverity = lvl),
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(horizontal: 4),
                                        padding: const EdgeInsets.symmetric(vertical: 10),
                                        decoration: BoxDecoration(
                                          color: isSelected ? const Color(0xFFEF4444) : const Color(0xFFF8FAFC),
                                          borderRadius: BorderRadius.circular(10),
                                          border: Border.all(color: isSelected ? Colors.transparent : const Color(0xFFE2E8F0)),
                                        ),
                                        child: Text(
                                          lvl,
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: isSelected ? Colors.white : const Color(0xFF475569),
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Section 3: Cause & Clear Description
                          _buildSectionCard(
                            title: "3. Cause & Detailed Description",
                            icon: Icons.assignment_outlined,
                            accentColor: const Color(0xFF2563EB),
                            children: [
                              const Text("Primary Cause *", style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF334155))),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                value: _selectedCause,
                                hint: const Text("Select probable cause...", style: TextStyle(color: Color(0xFF94A3B8), fontSize: 14)),
                                items: _damageCauses.map((cause) {
                                  return DropdownMenuItem(
                                    value: cause,
                                    child: Text(cause, style: const TextStyle(fontSize: 14)),
                                  );
                                }).toList(),
                                onChanged: (val) => setState(() => _selectedCause = val),
                                decoration: _buildInputDecoration("Select cause"),
                              ),
                              const SizedBox(height: 12),

                              // If "Other" is selected, render Custom Cause Text Box
                              if (_selectedCause == "Other") ...[
                                _buildTextField("Specify Custom Reason *", "Type custom cause...", _customCauseController, isMandatory: true),
                                const SizedBox(height: 12),
                              ],

                              _buildTextField(
                                "Detailed Description / Notes",
                                "Provide notes on how the damage occurred or condition...",
                                _descriptionController,
                                maxLines: 3,
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
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
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Color(0xFFEF4444)),
                          SizedBox(height: 16),
                          Text("Deducting Stock & Logging Report...", style: TextStyle(fontWeight: FontWeight.bold)),
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

  Widget _buildHeaderBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFEE2E2)),
      ),
      child: const Row(
        children: [
          Icon(Icons.report_problem_rounded, color: Color(0xFFEF4444), size: 36),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Stock Deduction Notice",
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF991B1B)),
                ),
                SizedBox(height: 2),
                Text(
                  "Submitting this form will permanently subtract reported damaged units from your live inventory.",
                  style: TextStyle(fontSize: 12, color: Color(0xFFB91C1C), height: 1.3),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color accentColor,
    required List<Widget> children,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: accentColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: accentColor),
              ),
            ],
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(height: 1, color: Color(0xFFF1F5F9)),
          ),
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
          Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF334155))),
          const SizedBox(height: 6),
          TextFormField(
            controller: controller,
            readOnly: readOnly,
            onTap: onTap,
            maxLines: maxLines,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            validator: isMandatory ? (v) => (v == null || v.trim().isEmpty) ? 'Required field' : null : null,
            decoration: _buildInputDecoration(hint, suffixIcon: suffixIcon),
          ),
        ],
      ),
    );
  }

  InputDecoration _buildInputDecoration(String hint, {IconData? suffixIcon}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
      suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: const Color(0xFF94A3B8), size: 18) : null,
      fillColor: Colors.white,
      filled: true,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: Color(0xFFE2E8F0))),
    );
  }

  Widget _buildBottomStickyActions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 48),
                side: const BorderSide(color: Color(0xFF64748B)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B), fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(0, 48),
                backgroundColor: const Color(0xFFEF4444),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
              label: const Text('Deduct & Submit', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              onPressed: _submitDamageReport,
            ),
          ),
        ],
      ),
    );
  }
}