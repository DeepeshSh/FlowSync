import 'package:flutter/material.dart';
import '../services/warehouse_service.dart';

class AddWarehouseScreen extends StatefulWidget {
  const AddWarehouseScreen({super.key});

  @override
  State<AddWarehouseScreen> createState() =>
      _AddWarehouseScreenState();
}

class _AddWarehouseScreenState
    extends State<AddWarehouseScreen> {

  final WarehouseService
      warehouseService =
      WarehouseService();

  final nameController =
      TextEditingController();

  final codeController =
      TextEditingController();

 final addressController =
    TextEditingController();

final cityController =
    TextEditingController();

final contactPersonController =
    TextEditingController();

  final phoneController =
      TextEditingController();

  final notesController =
      TextEditingController();

  bool isLoading = false;

  Future<void> saveWarehouse() async {

    if (nameController.text
        .trim()
        .isEmpty) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Warehouse Name is required",
          ),
        ),
      );

      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
await warehouseService
    .createWarehouse(
  name: nameController.text.trim(),
  code: codeController.text.trim(),
  address: addressController.text.trim(),
  city: cityController.text.trim(),
  contactPerson:
      contactPersonController.text.trim(),
  phone: phoneController.text.trim(),
  notes: notesController.text.trim(),
);

      if (mounted) {

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              "Warehouse Added Successfully",
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

    } finally {

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  InputDecoration fieldDecoration(
      String label,
      IconData icon) {

    return InputDecoration(

      labelText: label,

      prefixIcon: Icon(
        icon,
        color:
            const Color(
          0xFF2F80FF,
        ),
      ),

      filled: true,
      fillColor: Colors.white,

      border: OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(
          18,
        ),

        borderSide: BorderSide.none,
      ),

      enabledBorder:
          OutlineInputBorder(
        borderRadius:
            BorderRadius.circular(
          18,
        ),

        borderSide:
            BorderSide(
          color:
              Colors.grey.shade300,
        ),
      ),
    );
  }

  @override
  Widget build(
      BuildContext context) {

    return Scaffold(

      backgroundColor:
          const Color(
        0xFFF5F7FC,
      ),

      appBar: AppBar(
        elevation: 0,

        backgroundColor:
            Colors.white,

        title: const Text(
          "Add Warehouse",
          style: TextStyle(
            color:
                Color(
              0xFF0B1245,
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
                  28,
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

                children: [

                  TextField(
                    controller:
                        nameController,

                    decoration:
                        fieldDecoration(
                      "Warehouse Name *",
                      Icons.warehouse_outlined,
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  TextField(
                    controller:
                        codeController,

                    decoration:
                        fieldDecoration(
                      "Warehouse Code",
                      Icons.qr_code,
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  TextField(
                    controller:
                        addressController,

                    maxLines: 3,

                    decoration:
                        fieldDecoration(
                      "Address",
                      Icons.location_on_outlined,
                    ),
                  ),


const SizedBox(
  height: 16,
),

TextField(
  controller: cityController,

  decoration: fieldDecoration(
    "City",
    Icons.location_city_outlined,
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
    Icons.person_outline,
  ),
),

                  const SizedBox(
                    height: 16,
                  ),

                  TextField(
                    controller:
                        phoneController,

                    keyboardType:
                        TextInputType.phone,

                    decoration:
                        fieldDecoration(
                      "Phone Number",
                      Icons.phone_outlined,
                    ),
                  ),

                  const SizedBox(
                    height: 16,
                  ),

                  TextField(
                    controller:
                        notesController,

                    maxLines: 4,

                    decoration:
                        fieldDecoration(
                      "Notes",
                      Icons.note_alt_outlined,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(
              height: 30,
            ),

            SizedBox(
              width:
                  double.infinity,

              height: 58,

              child: ElevatedButton(

                onPressed:
                    isLoading
                        ? null
                        : saveWarehouse,

                style:
                    ElevatedButton
                        .styleFrom(

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

                child: isLoading

                    ? const CircularProgressIndicator(
                        color:
                            Colors.white,
                      )

                    : const Row(

                        mainAxisAlignment:
                            MainAxisAlignment.center,

                        children: [

                          Icon(
                            Icons.save_outlined,
                            color:
                                Colors.white,
                          ),

                          SizedBox(
                            width: 10,
                          ),

                          Text(
                            "Save Warehouse",

                            style:
                                TextStyle(
                              color:
                                  Colors.white,

                              fontSize: 16,

                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
              ),
            ),

            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}