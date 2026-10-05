import 'package:flutter/material.dart';

import '../models/supplier_model.dart';
import '../services/supplier_service.dart';
import '../utils/app_theme.dart';
import '../widgets/custom_app_bar.dart';

class EditSupplierScreen extends StatefulWidget {
  final Supplier supplier;

  const EditSupplierScreen({super.key, required this.supplier});

  @override
  State<EditSupplierScreen> createState() => _EditSupplierScreenState();
}

class _EditSupplierScreenState extends State<EditSupplierScreen> {
  final supplierNameController = TextEditingController();
  final companyNameController = TextEditingController();
  final contactPersonController = TextEditingController();
  final phoneController = TextEditingController();
  final emailController = TextEditingController();
  final gstController = TextEditingController();
  final addressController = TextEditingController();
  final cityController = TextEditingController();
  final stateController = TextEditingController();
  final pincodeController = TextEditingController();
  final openingBalanceController = TextEditingController();

  String paymentTerms = "30 Days";
  bool isActive = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    supplierNameController.text = widget.supplier.name;
    companyNameController.text = widget.supplier.companyName;
    contactPersonController.text = widget.supplier.contactPerson;
    phoneController.text = widget.supplier.phone;
    emailController.text = widget.supplier.email;
    gstController.text = widget.supplier.gstNumber;
    addressController.text = widget.supplier.address;
    cityController.text = widget.supplier.city;
    stateController.text = widget.supplier.state;
    pincodeController.text = widget.supplier.pincode;
    openingBalanceController.text = widget.supplier.openingBalance.toString();
    isActive = widget.supplier.isActive;

    final allowedTerms = ["7 Days", "15 Days", "30 Days", "45 Days", "60 Days"];
    if (allowedTerms.contains(widget.supplier.paymentTerms)) {
      paymentTerms = widget.supplier.paymentTerms;
    }
  }

  @override
  void dispose() {
    supplierNameController.dispose();
    companyNameController.dispose();
    contactPersonController.dispose();
    phoneController.dispose();
    emailController.dispose();
    gstController.dispose();
    addressController.dispose();
    cityController.dispose();
    stateController.dispose();
    pincodeController.dispose();
    openingBalanceController.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(
        color: AppColors.textMuted,
        fontSize: 13,
      ),
      prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 18),
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 14),
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      decoration: _fieldDecoration(label, icon),
    );
  }

  Widget _buildDropdownField({
    required String value,
    required String label,
    required IconData icon,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      onChanged: onChanged,
      dropdownColor: Colors.white,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      decoration: _fieldDecoration(label, icon),
      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.textSecondary),
      items: items.map((String val) {
        return DropdownMenuItem<String>(
          value: val,
          child: Text(val, style: const TextStyle(fontSize: 13)),
        );
      }).toList(),
    );
  }

  Future<void> _updateSupplier() async {
    if (supplierNameController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Supplier Name and Phone are required"),
        ),
      );
      return;
    }

    setState(() => isLoading = true);

    try {
      final updatedSupplier = Supplier(
        id: widget.supplier.id,
        supplierName: supplierNameController.text.trim(),
        companyName: companyNameController.text.trim(),
        contactPerson: contactPersonController.text.trim(),
        phone: phoneController.text.trim(),
        email: emailController.text.trim(),
        gstNumber: gstController.text.trim(),
        address: addressController.text.trim(),
        city: cityController.text.trim(),
        state: stateController.text.trim(),
        pincode: pincodeController.text.trim(),
        paymentTerms: paymentTerms,
        openingBalance: double.tryParse(openingBalanceController.text) ?? 0,
        isActive: isActive,
      );

      await SupplierService().updateSupplier(updatedSupplier);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Supplier Updated Successfully"),
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: "Edit Supplier",
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Supplier Details",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: supplierNameController,
                    label: "Supplier Name *",
                    icon: Icons.business_outlined,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: companyNameController,
                    label: "Company Name",
                    icon: Icons.storefront_outlined,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: contactPersonController,
                    label: "Contact Person",
                    icon: Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: phoneController,
                    label: "Phone Number *",
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: emailController,
                    label: "Email",
                    icon: Icons.mail_outline_rounded,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: gstController,
                    label: "GST Number",
                    icon: Icons.receipt_long_outlined,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    "Address & Payments",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: addressController,
                    label: "Address",
                    icon: Icons.location_on_outlined,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: cityController,
                    label: "City",
                    icon: Icons.location_city_outlined,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: stateController,
                    label: "State",
                    icon: Icons.map_outlined,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: pincodeController,
                    label: "Pincode",
                    icon: Icons.pin_drop_outlined,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  _buildDropdownField(
                    value: paymentTerms,
                    label: "Payment Terms",
                    icon: Icons.schedule_outlined,
                    items: const ["7 Days", "15 Days", "30 Days", "45 Days", "60 Days"],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        paymentTerms = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: openingBalanceController,
                    label: "Opening Balance",
                    icon: Icons.currency_rupee_rounded,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: SwitchListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
                      title: const Text(
                        "Supplier Profile Status",
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      subtitle: Text(
                        isActive ? "Active (Listed on Operations)" : "Inactive (Hidden/Suspended)",
                        style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                      ),
                      activeColor: AppColors.primary,
                      value: isActive,
                      onChanged: (bool value) {
                        setState(() {
                          isActive = value;
                        });
                      },
                    ),
                  ),
                ],
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
                onPressed: isLoading ? null : _updateSupplier,
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
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        "Update Supplier",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
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