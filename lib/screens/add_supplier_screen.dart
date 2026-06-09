import 'package:flutter/material.dart';

import '../services/supplier_service.dart';

class AddSupplierScreen extends StatefulWidget {
  const AddSupplierScreen({super.key});

  @override
  State<AddSupplierScreen> createState() =>
      _AddSupplierScreenState();
}

class _AddSupplierScreenState
    extends State<AddSupplierScreen> {

  final supplierNameController =
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

  final openingBalanceController =
      TextEditingController();

  String paymentTerms =
      "30 Days";

  bool isLoading = false;

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(

      backgroundColor:
          const Color(
        0xFFF5F7FC,
      ),

      appBar: AppBar(
        elevation: 0,

        backgroundColor:
            Colors.transparent,

        title: const Text(
          "Add Supplier",
          style: TextStyle(
            color: Color(
              0xFF1B2559,
            ),
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),

      body: SingleChildScrollView(

        padding:
            const EdgeInsets.all(
          20,
        ),

        child: Column(
          children: [
                        Container(
              padding:
                  const EdgeInsets.all(
                20,
              ),

              decoration:
                  BoxDecoration(
                color:
                    Colors.white,

                borderRadius:
                    BorderRadius.circular(
                  24,
                ),

                boxShadow: const [
                  BoxShadow(
                    color:
                        Colors.black12,
                    blurRadius: 10,
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [

                  const Text(
                    "Supplier Information",

                    style:
                        TextStyle(
                      fontSize: 20,

                      fontWeight:
                          FontWeight.bold,

                      color:
                          Color(
                        0xFF1B2559,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  // SUPPLIER NAME

                  TextField(
                    controller:
                        supplierNameController,

                    decoration:
                        InputDecoration(
                      labelText:
                          "Supplier Name *",

                      prefixIcon:
                          const Icon(
                        Icons.business,
                      ),

                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  // CONTACT PERSON

                  TextField(
                    controller:
                        contactPersonController,

                    decoration:
                        InputDecoration(
                      labelText:
                          "Contact Person",

                      prefixIcon:
                          const Icon(
                        Icons.person,
                      ),

                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  // PHONE

                  TextField(
                    controller:
                        phoneController,

                    keyboardType:
                        TextInputType.phone,

                    decoration:
                        InputDecoration(
                      labelText:
                          "Phone Number *",

                      prefixIcon:
                          const Icon(
                        Icons.phone,
                      ),

                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  // EMAIL

                  TextField(
                    controller:
                        emailController,

                    keyboardType:
                        TextInputType.emailAddress,

                    decoration:
                        InputDecoration(
                      labelText:
                          "Email",

                      prefixIcon:
                          const Icon(
                        Icons.email,
                      ),

                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  // GST

                  TextField(
                    controller:
                        gstController,

                    decoration:
                        InputDecoration(
                      labelText:
                          "GST Number",

                      prefixIcon:
                          const Icon(
                        Icons.receipt_long,
                      ),

                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 20,
            ),
                        Container(
              padding:
                  const EdgeInsets.all(
                20,
              ),

              decoration:
                  BoxDecoration(
                color:
                    Colors.white,

                borderRadius:
                    BorderRadius.circular(
                  24,
                ),

                boxShadow: const [
                  BoxShadow(
                    color:
                        Colors.black12,
                    blurRadius: 10,
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,

                children: [

                  const Text(
                    "Address & Payment Details",

                    style:
                        TextStyle(
                      fontSize: 20,

                      fontWeight:
                          FontWeight.bold,

                      color:
                          Color(
                        0xFF1B2559,
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  // ADDRESS

                  TextField(
                    controller:
                        addressController,

                    maxLines: 3,

                    decoration:
                        InputDecoration(
                      labelText:
                          "Address",

                      prefixIcon:
                          const Padding(
                        padding:
                            EdgeInsets.only(
                          bottom: 45,
                        ),

                        child: Icon(
                          Icons.location_on,
                        ),
                      ),

                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  // CITY

                  TextField(
                    controller:
                        cityController,

                    decoration:
                        InputDecoration(
                      labelText:
                          "City",

                      prefixIcon:
                          const Icon(
                        Icons.location_city,
                      ),

                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  // STATE

                  TextField(
                    controller:
                        stateController,

                    decoration:
                        InputDecoration(
                      labelText:
                          "State",

                      prefixIcon:
                          const Icon(
                        Icons.map,
                      ),

                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  // PINCODE

                  TextField(
                    controller:
                        pincodeController,

                    keyboardType:
                        TextInputType.number,

                    decoration:
                        InputDecoration(
                      labelText:
                          "Pincode",

                      prefixIcon:
                          const Icon(
                        Icons.pin_drop,
                      ),

                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 20,
                  ),

                  // PAYMENT TERMS

                  DropdownButtonFormField<String>(

                    value:
                        paymentTerms,

                    decoration:
                        InputDecoration(
                      labelText:
                          "Payment Terms",

                      prefixIcon:
                          const Icon(
                        Icons.schedule,
                      ),

                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          16,
                        ),
                      ),
                    ),

                    items: const [

                      DropdownMenuItem(
                        value:
                            "7 Days",

                        child:
                            Text(
                          "7 Days",
                        ),
                      ),

                      DropdownMenuItem(
                        value:
                            "15 Days",

                        child:
                            Text(
                          "15 Days",
                        ),
                      ),

                      DropdownMenuItem(
                        value:
                            "30 Days",

                        child:
                            Text(
                          "30 Days",
                        ),
                      ),

                      DropdownMenuItem(
                        value:
                            "45 Days",

                        child:
                            Text(
                          "45 Days",
                        ),
                      ),

                      DropdownMenuItem(
                        value:
                            "60 Days",

                        child:
                            Text(
                          "60 Days",
                        ),
                      ),
                    ],

                    onChanged:
                        (value) {

                      if (value ==
                          null) {
                        return;
                      }

                      setState(() {
                        paymentTerms =
                            value;
                      });
                    },
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  // OPENING BALANCE

                  TextField(
                    controller:
                        openingBalanceController,

                    keyboardType:
                        TextInputType.number,

                    decoration:
                        InputDecoration(
                      labelText:
                          "Opening Balance",

                      prefixIcon:
                          const Icon(
                        Icons.currency_rupee,
                      ),

                      border:
                          OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(
                          16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 24,
            ),
                        SizedBox(
              width: double.infinity,
              height: 58,

              child: ElevatedButton.icon(

                onPressed: isLoading
                    ? null
                    : () async {

                        if (supplierNameController
                                .text
                                .trim()
                                .isEmpty ||
                            phoneController
                                .text
                                .trim()
                                .isEmpty) {

                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(
                            const SnackBar(
                              content: Text(
                                "Supplier Name and Phone are required",
                              ),
                            ),
                          );

                          return;
                        }

                        try {

                          setState(() {
                            isLoading = true;
                          });

                          await SupplierService()
                              .createSupplier(

                            supplierName:
                                supplierNameController.text.trim(),

                            contactPerson:
                                contactPersonController.text.trim(),

                            phone:
                                phoneController.text.trim(),

                            email:
                                emailController.text.trim(),

                            gstNumber:
                                gstController.text.trim(),

                            address:
                                addressController.text.trim(),

                            city:
                                cityController.text.trim(),

                            state:
                                stateController.text.trim(),

                            pincode:
                                pincodeController.text.trim(),

                            paymentTerms:
                                paymentTerms,

                            openingBalance:
                                double.tryParse(
                                      openingBalanceController.text,
                                    ) ??
                                    0,
                          );

                          if (context.mounted) {

                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Supplier Added Successfully",
                                ),
                              ),
                            );

                            Navigator.pop(
                              context,
                              true,
                            );
                          }
                        } catch (e) {

                          ScaffoldMessenger.of(
                            context,
                          ).showSnackBar(
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
                      },

                icon: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,

                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.save,
                        color: Colors.white,
                      ),

                label: Text(
                  isLoading
                      ? "Saving..."
                      : "Save Supplier",

                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      const Color(
                    0xFF2F80FF,
                  ),

                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      18,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(
              height: 40,
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {

    supplierNameController.dispose();

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