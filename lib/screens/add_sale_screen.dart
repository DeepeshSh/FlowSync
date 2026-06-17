import 'package:flutter/material.dart';

class AddSaleScreen extends StatefulWidget {
  const AddSaleScreen({super.key});

  @override
  State<AddSaleScreen> createState() =>
      _AddSaleScreenState();
}

class _AddSaleScreenState
    extends State<AddSaleScreen> {

  final saleNumberController =
      TextEditingController();

  final customerController =
      TextEditingController();

  String paymentStatus =
      "Pending";

  @override
  void initState() {
    super.initState();

    saleNumberController.text =
        "INV-${DateTime.now().millisecondsSinceEpoch}";
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F7FC),

      appBar: AppBar(
        title:
            const Text("New Sale"),

        centerTitle: true,
      ),

      body: SingleChildScrollView(

        padding:
            const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            const Text(
              "Sale Information",
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            TextField(
              controller:
                  saleNumberController,

              readOnly: true,

              decoration:
                  const InputDecoration(
                labelText:
                    "Invoice Number",

                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            TextField(
              controller:
                  customerController,

              decoration:
                  const InputDecoration(
                labelText:
                    "Customer Name",

                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            DropdownButtonFormField<
                String>(
              value:
                  paymentStatus,

              decoration:
                  const InputDecoration(
                labelText:
                    "Payment Status",

                border:
                    OutlineInputBorder(),
              ),

              items: const [

                DropdownMenuItem(
                  value: "Paid",
                  child:
                      Text("Paid"),
                ),

                DropdownMenuItem(
                  value: "Pending",
                  child:
                      Text("Pending"),
                ),

                DropdownMenuItem(
                  value:
                      "Partially Paid",
                  child: Text(
                    "Partially Paid",
                  ),
                ),
              ],

              onChanged: (value) {

                if (value == null)
                  return;

                setState(() {
                  paymentStatus =
                      value;
                });
              },
            ),

            const SizedBox(
              height: 24,
            ),

            const Text(
              "Products",
              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            Container(
              width:
                  double.infinity,

              padding:
                  const EdgeInsets.all(
                20,
              ),

              decoration:
                  BoxDecoration(
                color: Colors.white,

                borderRadius:
                    BorderRadius.circular(
                  16,
                ),
              ),

              child: const Center(
                child: Text(
                  "Products Section Coming Next",
                ),
              ),
            ),

            const SizedBox(
              height: 30,
            ),

            SizedBox(
              width:
                  double.infinity,

              height: 55,

              child: ElevatedButton(
                onPressed: () {},

                style:
                    ElevatedButton
                        .styleFrom(
                  backgroundColor:
                      Colors.green,
                ),

                child: const Text(
                  "Save Sale",
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