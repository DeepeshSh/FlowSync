import 'package:flutter/material.dart';

import '../models/supplier_model.dart';
import '../services/supplier_service.dart';

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
    // Pre-populating existing supplier values into their respective controllers
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

    // Validate if current value fits current drop list selection constraints
    final allowedTerms = ["7 Days", "15 Days", "30 Days", "45 Days", "60 Days"];
    if (allowedTerms.contains(widget.supplier.paymentTerms)) {
      paymentTerms = widget.supplier.paymentTerms;
    }
  }

  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        GestureDetector(
          onTap: () => Navigator.maybePop(context),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: const Icon(
              Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF0F172A),
              size: 16,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Edit Supplier",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Modify supplier profile & trade terms parameters",
                style: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12.5,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14.5,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E293B),
        ),
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: const TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 14.5,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 14,
          ),
          prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 20),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: maxLines > 1 ? 16 : 14,
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownField({
    required String value,
    required String label,
    required IconData icon,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        onChanged: onChanged,
        style: const TextStyle(
          color: Color(0xFF0F172A),
          fontSize: 14.5,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 14,
          ),
          prefixIcon: Icon(icon, color: const Color(0xFF94A3B8), size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF94A3B8)),
        items: items.map((String val) {
          return DropdownMenuItem<String>(
            value: val,
            child: Text(val),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildStatusToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.015),
            blurRadius: 8,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text(
          "Supplier Profile Status",
          style: TextStyle(
            color: Color(0xFF0F172A),
            fontSize: 14.5,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          isActive ? "Active (Listed on Operations)" : "Inactive (Hidden/Suspended)",
          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
        activeColor: const Color(0xFF10B981),
        value: isActive,
        onChanged: (bool value) {
          setState(() {
            isActive = value;
          });
        },
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: isLoading
            ? null
            : () async {
                if (supplierNameController.text.trim().isEmpty ||
                    phoneController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Supplier Name and Phone are required"),
                    ),
                  );
                  return;
                }

                try {
                  setState(() {
                    isLoading = true;
                  });

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
                    openingBalance: double.tryParse(
                          openingBalanceController.text,
                        ) ??
                        0,
                    isActive: isActive,
                  );

                  await SupplierService().updateSupplier(updatedSupplier);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Supplier Updated Successfully"),
                      ),
                    );
                    Navigator.pop(context, true);
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(e.toString()),
                    ),
                  );
                } finally {
                  if (mounted) {
                    setState(() {
                      isLoading = false;
                    });
                  }
                }
              },
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.save_rounded, color: Colors.white, size: 20),
        label: Text(
          isLoading ? "Updating..." : "Update Supplier",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF10B981), // Shared green styling asset
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Gradient Flow Configuration matching Add Screen
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFE2EAF2),
                    Color(0xFFF1F5F9),
                    Colors.white,
                  ],
                  stops: [0.0, 0.35, 0.7],
                ),
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
                  _buildHeader(),
                  const SizedBox(height: 24),

                  // SECTION 1: Supplier Information
                  _buildSectionTitle("Supplier Details"),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: supplierNameController,
                    label: "Supplier Name *",
                    icon: Icons.business,
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    controller: companyNameController,
                    label: "Company Name",
                    icon: Icons.storefront,
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    controller: contactPersonController,
                    label: "Contact Person",
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    controller: phoneController,
                    label: "Phone Number *",
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    controller: emailController,
                    label: "Email",
                    icon: Icons.email,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    controller: gstController,
                    label: "GST Number",
                    icon: Icons.receipt_long,
                  ),

                  const SizedBox(height: 28),

                  // SECTION 2: Address & Payment Details
                  _buildSectionTitle("Address & Payments"),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: addressController,
                    label: "Address",
                    icon: Icons.location_on,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    controller: cityController,
                    label: "City",
                    icon: Icons.location_city,
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    controller: stateController,
                    label: "State",
                    icon: Icons.map,
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    controller: pincodeController,
                    label: "Pincode",
                    icon: Icons.pin_drop,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 14),
                  _buildDropdownField(
                    value: paymentTerms,
                    label: "Payment Terms",
                    icon: Icons.schedule,
                    items: const ["7 Days", "15 Days", "30 Days", "45 Days", "60 Days"],
                    onChanged: (value) {
                      if (value == null) return;
                      setState(() {
                        paymentTerms = value;
                      });
                    },
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    controller: openingBalanceController,
                    label: "Opening Balance",
                    icon: Icons.currency_rupee,
                    keyboardType: TextInputType.number,
                  ),
                  const SizedBox(height: 14),
                  _buildStatusToggle(),

                  const SizedBox(height: 36),
                  _buildSaveButton(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ],
      ),
    );
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
}