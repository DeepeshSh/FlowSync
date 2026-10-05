import 'package:flutter/material.dart';

import '../models/customer_model.dart';
import '../services/customer_service.dart';
import '../utils/app_theme.dart';
import '../widgets/custom_app_bar.dart';

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

    setState(() => isLoading = true);

    try {
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Customer Updated Successfully"),
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
        title: "Edit Customer",
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
                    "Customer Details",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: customerNameController,
                    label: "Customer Name *",
                    icon: Icons.person_outline_rounded,
                  ),
                  const SizedBox(height: 12),
                  _buildTextField(
                    controller: contactPersonController,
                    label: "Contact Person",
                    icon: Icons.badge_outlined,
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
                    "Address & Finance",
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
                  _buildTextField(
                    controller: creditLimitController,
                    label: "Credit Limit",
                    icon: Icons.credit_card_outlined,
                    keyboardType: TextInputType.number,
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
                        "Customer Profile Status",
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
                onPressed: isLoading ? null : updateCustomer,
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
                        "Update Customer",
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