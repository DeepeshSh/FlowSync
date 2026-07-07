import 'package:flutter/material.dart';

import '../models/customer_model.dart';
import '../services/customer_service.dart';

class EditCustomerScreen extends StatefulWidget {
  final Customer customer;

  const EditCustomerScreen({
    super.key,
    required this.customer,
  });

  @override
  State<EditCustomerScreen> createState() => _EditCustomerScreenState();
}

class _EditCustomerScreenState extends State<EditCustomerScreen> {
  late TextEditingController customerNameController;
  late TextEditingController contactPersonController;
  late TextEditingController phoneController;
  late TextEditingController emailController;
  late TextEditingController gstController;
  late TextEditingController addressController;
  late TextEditingController cityController;
  late TextEditingController stateController;
  late TextEditingController pincodeController;
  late TextEditingController creditLimitController;
  late TextEditingController openingBalanceController;

  bool isActive = true;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    customerNameController = TextEditingController(
      text: widget.customer.customerName,
    );
    contactPersonController = TextEditingController(
      text: widget.customer.contactPerson,
    );
    phoneController = TextEditingController(
      text: widget.customer.phone,
    );
    emailController = TextEditingController(
      text: widget.customer.email,
    );
    gstController = TextEditingController(
      text: widget.customer.gstNumber,
    );
    addressController = TextEditingController(
      text: widget.customer.address,
    );
    cityController = TextEditingController(
      text: widget.customer.city,
    );
    stateController = TextEditingController(
      text: widget.customer.state,
    );
    pincodeController = TextEditingController(
      text: widget.customer.pincode,
    );
    creditLimitController = TextEditingController(
      text: widget.customer.creditLimit.toString(),
    );
    openingBalanceController = TextEditingController(
      text: widget.customer.openingBalance.toString(),
    );

    isActive = widget.customer.isActive;
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
                "Edit Customer",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              SizedBox(height: 4),
              Text(
                "Modify customer profile & ledger accounts parameters",
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
          "Customer Profile Status",
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

  Future<void> updateCustomer() async {
    if (customerNameController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Customer Name and Phone are required"),
        ),
      );
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      await CustomerService().updateCustomer(
        id: widget.customer.id,
        customerName: customerNameController.text.trim(),
        contactPerson: contactPersonController.text.trim(),
        phone: phoneController.text.trim(),
        email: emailController.text.trim(),
        gstNumber: gstController.text.trim(),
        address: addressController.text.trim(),
        city: cityController.text.trim(),
        state: stateController.text.trim(),
        pincode: pincodeController.text.trim(),
        creditLimit: double.tryParse(creditLimitController.text) ?? 0,
        openingBalance: double.tryParse(openingBalanceController.text) ?? 0,
        isActive: isActive,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Customer Updated Successfully"),
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
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: isLoading ? null : updateCustomer,
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
          isLoading ? "Updating..." : "Update Customer",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF10B981),
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

                  // SECTION 1: Customer Information
                  _buildSectionTitle("Customer Details"),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: customerNameController,
                    label: "Customer Name *",
                    icon: Icons.person,
                  ),
                  const SizedBox(height: 14),
                  _buildTextField(
                    controller: contactPersonController,
                    label: "Contact Person",
                    icon: Icons.assignment_ind,
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

                  // SECTION 2: Address & Financial Details
                  _buildSectionTitle("Address & Finance"),
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
                  _buildTextField(
                    controller: creditLimitController,
                    label: "Credit Limit",
                    icon: Icons.credit_card,
                    keyboardType: TextInputType.number,
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
    customerNameController.dispose();
    contactPersonController.dispose();
    phoneController.dispose();
    emailController.dispose();
    gstController.dispose();
    addressController.dispose();
    cityController.dispose();
    stateController.dispose();
    pincodeController.dispose();
    creditLimitController.dispose();
    openingBalanceController.dispose();
    super.dispose();
  }
}