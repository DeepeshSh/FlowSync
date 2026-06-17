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
  State<EditCustomerScreen> createState() =>
      _EditCustomerScreenState();
}

class _EditCustomerScreenState
    extends State<EditCustomerScreen> {

  late TextEditingController
      customerNameController;

  late TextEditingController
      contactPersonController;

  late TextEditingController
      phoneController;

  late TextEditingController
      emailController;

  late TextEditingController
      gstController;

  late TextEditingController
      addressController;

  late TextEditingController
      cityController;

  late TextEditingController
      stateController;

  late TextEditingController
      pincodeController;

  late TextEditingController
      creditLimitController;

  late TextEditingController
      openingBalanceController;

  bool isActive = true;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    customerNameController =
        TextEditingController(
      text:
          widget.customer.customerName,
    );

    contactPersonController =
        TextEditingController(
      text:
          widget.customer.contactPerson,
    );

    phoneController =
        TextEditingController(
      text:
          widget.customer.phone,
    );

    emailController =
        TextEditingController(
      text:
          widget.customer.email,
    );

    gstController =
        TextEditingController(
      text:
          widget.customer.gstNumber,
    );

    addressController =
        TextEditingController(
      text:
          widget.customer.address,
    );

    cityController =
        TextEditingController(
      text:
          widget.customer.city,
    );

    stateController =
        TextEditingController(
      text:
          widget.customer.state,
    );

    pincodeController =
        TextEditingController(
      text:
          widget.customer.pincode,
    );

    creditLimitController =
        TextEditingController(
      text: widget
          .customer
          .creditLimit
          .toString(),
    );

    openingBalanceController =
        TextEditingController(
      text: widget
          .customer
          .openingBalance
          .toString(),
    );

    isActive =
        widget.customer.isActive;
  }

  InputDecoration fieldDecoration(
      String label) {
    return InputDecoration(
      labelText: label,

      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(
          14,
        ),
      ),
    );
  }

  Future<void> updateCustomer() async {

    setState(() {
      isLoading = true;
    });

    try {

      await CustomerService()
          .updateCustomer(

        id: widget.customer.id,

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
                  creditLimitController
                      .text,
                ) ??
                0,

        openingBalance:
            double.tryParse(
                  openingBalanceController
                      .text,
                ) ??
                0,

        isActive:
            isActive,
      );

      if (mounted) {

        ScaffoldMessenger.of(
                context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              "Customer Updated Successfully",
            ),
          ),
        );

        Navigator.pop(context);
      }

    } catch (e) {

      ScaffoldMessenger.of(
              context)
          .showSnackBar(
        SnackBar(
          content:
              Text(e.toString()),
        ),
      );
    }

    if (mounted) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F7FC),

      appBar: AppBar(
        title: const Text(
          "Edit Customer",
        ),
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
                "Customer Name",
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            TextField(
              controller:
                  contactPersonController,
              decoration:
                  fieldDecoration(
                "Contact Person",
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            TextField(
              controller:
                  phoneController,
              decoration:
                  fieldDecoration(
                "Phone Number",
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            TextField(
              controller:
                  emailController,
              decoration:
                  fieldDecoration(
                "Email",
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            TextField(
              controller:
                  gstController,
              decoration:
                  fieldDecoration(
                "GST Number",
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            TextField(
              controller:
                  addressController,
              decoration:
                  fieldDecoration(
                "Address",
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            TextField(
              controller:
                  cityController,
              decoration:
                  fieldDecoration(
                "City",
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            TextField(
              controller:
                  stateController,
              decoration:
                  fieldDecoration(
                "State",
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            TextField(
              controller:
                  pincodeController,
              decoration:
                  fieldDecoration(
                "Pincode",
              ),
            ),

            const SizedBox(
              height: 16,
            ),

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

            const SizedBox(
              height: 16,
            ),

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

            const SizedBox(
              height: 10,
            ),

            SwitchListTile(
              value:
                  isActive,

              title: const Text(
                "Active Customer",
              ),

              onChanged: (value) {
                setState(() {
                  isActive = value;
                });
              },
            ),

            const SizedBox(
              height: 24,
            ),

            SizedBox(
              width:
                  double.infinity,

              height: 55,

              child: ElevatedButton(
                onPressed:
                    isLoading
                        ? null
                        : updateCustomer,

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
                        "Update Customer",
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