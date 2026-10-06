import 'package:flutter/material.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../utils/app_theme.dart';

class SignupBusinessDetailsScreen extends StatefulWidget {
  final String? initialEmail;
  final String? initialName;
  final String? initialPhone;

  const SignupBusinessDetailsScreen({
    super.key,
    this.initialEmail,
    this.initialName,
    this.initialPhone,
  });

  @override
  State<SignupBusinessDetailsScreen> createState() =>
      _SignupBusinessDetailsScreenState();
}

class _SignupBusinessDetailsScreenState
    extends State<SignupBusinessDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _businessNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _gstinController = TextEditingController();

  String _selectedTrade = 'Wholesaler';
  final List<Map<String, dynamic>> _tradeOptions = [
    {'label': 'Wholesaler', 'icon': Icons.warehouse_rounded},
    {'label': 'Retailer', 'icon': Icons.storefront_rounded},
    {'label': 'Distributor', 'icon': Icons.local_shipping_rounded},
    {'label': 'Contractor', 'icon': Icons.engineering_rounded},
  ];

  bool _isSaving = false;
  String? _serverError;

  @override
  void initState() {
    super.initState();
    if (widget.initialPhone != null && widget.initialPhone!.isNotEmpty) {
      _phoneController.text = widget.initialPhone!;
    }
  }

  @override
  void dispose() {
    _businessNameController.dispose();
    _phoneController.dispose();
    _gstinController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData prefixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13.5),
      prefixIcon: Icon(
        prefixIcon,
        color: const Color(0xFF2563EB),
        size: 20,
      ),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    );
  }

  Widget _buildFieldTitle(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13.5,
          color: Color(0xFF0F172A),
        ),
      ),
    );
  }

  Widget _buildTradeChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _tradeOptions.map((opt) {
        final isSelected = _selectedTrade == opt['label'];
        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            setState(() => _selectedTrade = opt['label'] as String);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
                width: isSelected ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  opt['icon'] as IconData,
                  size: 16,
                  color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF64748B),
                ),
                const SizedBox(width: 6),
                Text(
                  opt['label'] as String,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF334155),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Future<void> _submitBusinessDetails() async {
    setState(() => _serverError = null);

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isSaving = true);

    try {
      final businessName = _businessNameController.text.trim();
      final phone = _phoneController.text.trim();
      final gstin = _gstinController.text.trim().toUpperCase();

      final profileService = ProfileService();

      await profileService.updateBusinessProfile({
        'businessName': businessName,
        'tradeType': _selectedTrade,
        'gstin': gstin,
      });

      if (phone.isNotEmpty) {
        await profileService.updatePersonalProfile({
          if (widget.initialName != null) 'name': widget.initialName,
          if (widget.initialEmail != null) 'email': widget.initialEmail,
          'phone': phone,
        });
      }

      final authService = AuthService();
      final token = await authService.getToken() ?? "";
      final current = await authService.getCachedUser();
      if (current != null) {
        final updatedUser = AppUser(
          id: current.id,
          name: current.name.isNotEmpty ? current.name : (widget.initialName ?? ""),
          businessName: businessName,
          email: current.email.isNotEmpty ? current.email : (widget.initialEmail ?? ""),
          phone: phone.isNotEmpty ? phone : current.phone,
          gstin: gstin.isNotEmpty ? gstin : current.gstin,
          address: current.address,
        );
        await authService.saveSession(token, updatedUser);
      }

      if (!mounted) return;

      if (Navigator.canPop(context)) {
        Navigator.pop(context, true);
      } else {
        Navigator.pushReplacementNamed(context, '/dashboard');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _serverError = "Failed to save: ${e.toString().replaceFirst("Exception: ", "")}";
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: Stack(
        children: [
          // Background soft circles
          Positioned(
            top: -240,
            left: -200,
            child: Container(
              width: 500,
              height: 380,
              decoration: const BoxDecoration(
                color: Color(0xFFE8EEF5),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: -120,
            right: -150,
            child: Container(
              width: 350,
              height: 260,
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 195, 212, 238),
                shape: BoxShape.circle,
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),

                  // Header Bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: const Color(0xFFBFDBFE)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.verified_rounded, size: 16, color: Color(0xFF2563EB)),
                            SizedBox(width: 6),
                            Text(
                              "Step 2 of 2: Business Profile",
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                          ],
                        ),
                      ),
                      RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: "Flow",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            TextSpan(
                              text: "Sync",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF2563EB),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Title & Subtitle
                  const Text(
                    "Setup Your Firm",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    "Configure your tax invoices, receipts, and inventory stock ledger.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF64748B),
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: 44,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Main Card Form
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_serverError != null) ...[
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFEF2F2),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFFFECACA)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.error_outline_rounded, color: AppColors.error, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _serverError!,
                                      style: const TextStyle(fontSize: 12.5, color: AppColors.error),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                          ],

                          _buildFieldTitle("Business / Firm Name *"),
                          TextFormField(
                            controller: _businessNameController,
                            textInputAction: TextInputAction.next,
                            style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
                            decoration: _inputDecoration(
                              hint: "e.g. Royal Sanitary Stores",
                              prefixIcon: Icons.storefront_rounded,
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return "Please enter your business or firm name";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          _buildFieldTitle("Contact Phone Number *"),
                          TextFormField(
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
                            decoration: _inputDecoration(
                              hint: "e.g. +91 98765 43210",
                              prefixIcon: Icons.phone_rounded,
                            ),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return "Contact phone number is required";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),

                          _buildFieldTitle("Trade Classification *"),
                          _buildTradeChips(),
                          const SizedBox(height: 18),

                          _buildFieldTitle("GSTIN / Tax ID (Optional)"),
                          TextFormField(
                            controller: _gstinController,
                            textCapitalization: TextCapitalization.characters,
                            textInputAction: TextInputAction.done,
                            style: const TextStyle(fontSize: 14, color: Color(0xFF0F172A)),
                            decoration: _inputDecoration(
                              hint: "e.g. 24AAAAA0000A1Z5",
                              prefixIcon: Icons.receipt_long_rounded,
                            ),
                          ),
                          const SizedBox(height: 26),

                          // Submit Action Button
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _isSaving ? null : _submitBusinessDetails,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF2563EB),
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: _isSaving
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: const [
                                        Text(
                                          "Complete Setup & Enter",
                                          style: TextStyle(
                                            fontSize: 15.5,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Icon(Icons.arrow_forward_rounded, size: 18),
                                      ],
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.shield_outlined, size: 15, color: Color(0xFF94A3B8)),
                        SizedBox(width: 6),
                        Text(
                          "Your data is end-to-end encrypted",
                          style: TextStyle(
                            fontSize: 12,
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}