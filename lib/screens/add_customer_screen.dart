import 'package:flutter/material.dart';

import '../services/customer_service.dart';

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  State<AddCustomerScreen> createState() =>
      _AddCustomerScreenState();
}

class _AddCustomerScreenState
    extends State<AddCustomerScreen> {

  final CustomerService customerService =
      CustomerService();

  final customerNameController =
      TextEditingController();

  final contactPersonController =
      TextEditingController();

  final phoneController =
      TextEditingController();

  final emailController =
      TextEditingController();

  final gstController =
      TextEditingController();

  final addressController =
      TextEditingController();

  final cityController =
      TextEditingController();

  final stateController =
      TextEditingController();

  final pincodeController =
      TextEditingController();

  final creditLimitController =
      TextEditingController();

  final openingBalanceController =
      TextEditingController();

  bool isLoading = false;

  Future<void> saveCustomer() async {

    if (customerNameController.text
        .trim()
        .isEmpty) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Customer Name is required",
          ),
        ),
      );

      return;
    }

    if (phoneController.text
        .trim()
        .isEmpty) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Phone Number is required",
          ),
        ),
      );

      return;
    }

    setState(() {
      isLoading = true;
    });

    try {

      await customerService
          .createCustomer(
        customerName:
            customerNameController.text
                .trim(),

        contactPerson:
            contactPersonController.text
                .trim(),

        phone:
            phoneController.text
                .trim(),

        email:
            emailController.text
                .trim(),

        gstNumber:
            gstController.text
                .trim(),

        address:
            addressController.text
                .trim(),

        city:
            cityController.text
                .trim(),

        state:
            stateController.text
                .trim(),

        pincode:
            pincodeController.text
                .trim(),

        creditLimit:
            double.tryParse(
                  creditLimitController.text,
                ) ??
                0,

        openingBalance:
            double.tryParse(
                  openingBalanceController.text,
                ) ??
                0,
      );

      if (mounted) {

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              "Customer Added Successfully",
            ),
          ),
        );

        Navigator.pop(context);
      }

    } catch (e) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            e.toString(),
          ),
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

  InputDecoration fieldDecoration(
      String label) {
    return InputDecoration(
      labelText: label,

      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(14),
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

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F7FC),

      appBar: AppBar(
        title:
            const Text("Add Customer"),
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(16),

        child: Column(
          children: [

            TextField(
              controller:
                  customerNameController,

              decoration:
                  fieldDecoration(
                "Customer Name *",
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller:
                  contactPersonController,

              decoration:
                  fieldDecoration(
                "Contact Person",
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller:
                  phoneController,

              keyboardType:
                  TextInputType.phone,

              decoration:
                  fieldDecoration(
                "Phone Number *",
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller:
                  emailController,

              keyboardType:
                  TextInputType.emailAddress,

              decoration:
                  fieldDecoration(
                "Email",
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller:
                  gstController,

              decoration:
                  fieldDecoration(
                "GST Number",
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller:
                  addressController,

              maxLines: 2,

              decoration:
                  fieldDecoration(
                "Address",
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller:
                  cityController,

              decoration:
                  fieldDecoration(
                "City",
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller:
                  stateController,

              decoration:
                  fieldDecoration(
                "State",
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller:
                  pincodeController,

              keyboardType:
                  TextInputType.number,

              decoration:
                  fieldDecoration(
                "Pincode",
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller:
                  creditLimitController,

              keyboardType:
                  TextInputType.number,

              decoration:
                  fieldDecoration(
                "Credit Limit",
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller:
                  openingBalanceController,

              keyboardType:
                  TextInputType.number,

              decoration:
                  fieldDecoration(
                "Opening Balance",
              ),
            ),

            const SizedBox(height: 30),

            SizedBox(
              width:
                  double.infinity,

              height: 55,

              child: ElevatedButton(
                onPressed:
                    isLoading
                        ? null
                        : saveCustomer,

                style:
                    ElevatedButton
                        .styleFrom(
                  backgroundColor:
                      const Color(
                    0xFF2F80FF,
                  ),
                ),

                child: isLoading

                    ? const CircularProgressIndicator(
                        color:
                            Colors.white,
                      )

                    : const Text(
                        "Save Customer",
                        style:
                            TextStyle(
                          color:
                              Colors.white,

                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}