import 'package:flutter/material.dart';

import '../models/supplier_model.dart';
import '../services/supplier_service.dart';

class EditSupplierScreen extends StatefulWidget {
  final Supplier supplier;

  const EditSupplierScreen({
    super.key,
    required this.supplier,
  });

  @override
  State<EditSupplierScreen> createState() =>
      _EditSupplierScreenState();
}

class _EditSupplierScreenState
    extends State<EditSupplierScreen> {

  late TextEditingController
      supplierNameController;

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
      openingBalanceController;

  String paymentTerms = "";

  bool isActive = true;

  @override
  void initState() {
    super.initState();

    supplierNameController =
        TextEditingController(
      text:
          widget.supplier.supplierName,
    );

    contactPersonController =
        TextEditingController(
      text:
          widget.supplier.contactPerson,
    );

    phoneController =
        TextEditingController(
      text: widget.supplier.phone,
    );

    emailController =
        TextEditingController(
      text: widget.supplier.email,
    );

    gstController =
        TextEditingController(
      text:
          widget.supplier.gstNumber,
    );

    addressController =
        TextEditingController(
      text:
          widget.supplier.address,
    );

    cityController =
        TextEditingController(
      text: widget.supplier.city,
    );

    stateController =
        TextEditingController(
      text:
          widget.supplier.state,
    );

    pincodeController =
        TextEditingController(
      text:
          widget.supplier.pincode,
    );

    openingBalanceController =
        TextEditingController(
      text: widget
          .supplier
          .openingBalance
          .toString(),
    );

    paymentTerms =
        widget.supplier.paymentTerms;

    isActive =
        widget.supplier.isActive;
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

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F7FC),

      appBar: AppBar(
        title:
            const Text(
          "Edit Supplier",
        ),
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(16),

        child: Column(
          children: [

            TextField(
              controller:
                  supplierNameController,
              decoration:
                  fieldDecoration(
                "Supplier Name",
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
              decoration:
                  fieldDecoration(
                "Phone Number",
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller:
                  emailController,
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
              decoration:
                  fieldDecoration(
                "Pincode",
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller:
                  openingBalanceController,
              decoration:
                  fieldDecoration(
                "Opening Balance",
              ),
            ),

            const SizedBox(height: 16),

            DropdownButtonFormField<
                String>(
              value:
                  paymentTerms,

              decoration:
                  fieldDecoration(
                "Payment Terms",
              ),

              items: const [

                DropdownMenuItem(
                  value:
                      "Cash",
                  child:
                      Text("Cash"),
                ),

                DropdownMenuItem(
                  value:
                      "7 Days",
                  child:
                      Text("7 Days"),
                ),

                DropdownMenuItem(
                  value:
                      "15 Days",
                  child:
                      Text("15 Days"),
                ),

                DropdownMenuItem(
                  value:
                      "30 Days",
                  child:
                      Text("30 Days"),
                ),
              ],

              onChanged: (value) {
                setState(() {
                  paymentTerms =
                      value ?? "";
                });
              },
            ),

            const SizedBox(height: 10),

            SwitchListTile(
              value: isActive,

              title: const Text(
                "Active Supplier",
              ),

              onChanged: (value) {
                setState(() {
                  isActive = value;
                });
              },
            ),

            const SizedBox(height: 24),

            SizedBox(
              width:
                  double.infinity,

              height: 55,

              child: ElevatedButton(
               onPressed: () async {

  try {

    await SupplierService()
        .updateSupplier(

      id: widget.supplier.id,

      supplierName:
          supplierNameController.text,

      contactPerson:
          contactPersonController.text,

      phone:
          phoneController.text,

      email:
          emailController.text,

      gstNumber:
          gstController.text,

      address:
          addressController.text,

      city:
          cityController.text,

      state:
          stateController.text,

      pincode:
          pincodeController.text,

      paymentTerms:
          paymentTerms,

      openingBalance:
          double.tryParse(
                openingBalanceController.text,
              ) ??
              0,

      isActive:
          isActive,
    );

    if (context.mounted) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Supplier Updated Successfully",
          ),
        ),
      );

      Navigator.pop(context);
    }

  } catch (e) {

    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content:
            Text(e.toString()),
      ),
    );
  }
},

                style:
                    ElevatedButton
                        .styleFrom(
                  backgroundColor:
                      const Color(
                    0xFF2F80FF,
                  ),
                ),

                child: const Text(
                  "Update Supplier",

                  style: TextStyle(
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
