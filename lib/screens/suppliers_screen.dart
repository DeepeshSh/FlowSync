import 'package:flutter/material.dart';

import '../models/supplier_model.dart';
import '../services/supplier_service.dart';
import 'add_supplier_screen.dart';

class SuppliersScreen extends StatefulWidget {
  const SuppliersScreen({super.key});

  @override
  State<SuppliersScreen> createState() =>
      _SuppliersScreenState();
}

class _SuppliersScreenState
    extends State<SuppliersScreen> {

  List<Supplier> suppliers = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadSuppliers();
  }

  Future<void> loadSuppliers() async {

    try {

      final data =
          await SupplierService()
              .getSuppliers();

      setState(() {
        suppliers = data;
        isLoading = false;
      });

    } catch (e) {

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
          "Suppliers",
        ),

        actions: [

          IconButton(
            onPressed: () async {

              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const AddSupplierScreen(),
                ),
              );

              loadSuppliers();
            },

            icon: const Icon(
              Icons.add,
            ),
          ),
        ],
      ),

      body: isLoading

          ? const Center(
              child:
                  CircularProgressIndicator(),
            )

          : suppliers.isEmpty

              ? const Center(
                  child: Text(
                    "No Suppliers Found",
                  ),
                )

              : ListView.builder(
                  padding:
                      const EdgeInsets.all(
                    16,
                  ),

                  itemCount:
                      suppliers.length,

                  itemBuilder:
                      (context, index) {

                    final supplier =
                        suppliers[index];

                    return Card(
                      margin:
                          const EdgeInsets.only(
                        bottom: 12,
                      ),

                      shape:
                          RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(
                          18,
                        ),
                      ),

                      child: ListTile(

                        leading:
                            const CircleAvatar(
                          backgroundColor:
                              Color(
                            0xFF2F80FF,
                          ),

                          child: Icon(
                            Icons.local_shipping,
                            color:
                                Colors.white,
                          ),
                        ),

                        title: Text(
                          supplier.supplierName,
                        ),

                        subtitle: Text(
                          supplier.phone,
                        ),

                        trailing:
                            IconButton(
                          onPressed: () {

                            // Edit Later
                          },

                          icon: const Icon(
                            Icons.edit,
                            color:
                                Colors.blue,
                          ),
                        ),
                      ),
                    );
                  },
                ),

      floatingActionButton:
          FloatingActionButton(
        backgroundColor:
            const Color(0xFF2F80FF),

        onPressed: () async {

          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const AddSupplierScreen(),
            ),
          );

          loadSuppliers();
        },

        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}