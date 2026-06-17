import 'package:flutter/material.dart';

import '../models/customer_model.dart';
import '../services/customer_service.dart';
import 'add_customer_screen.dart';
import 'edit_customer_screen.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() =>
      _CustomersScreenState();
}

class _CustomersScreenState
    extends State<CustomersScreen> {

List<Customer> customers = [];

  bool isLoading = true;

  @override
 void initState() {
  super.initState();
  loadCustomers();
}

Future<void> loadCustomers() async {

    try {

      final data =
          await CustomerService()
    .getCustomers();
      setState(() {
       customers = data;
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
          "Customers",
        ),

        actions: [

          IconButton(
            onPressed: () async {

              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                     const AddCustomerScreen() ,
                ),
              );

            loadCustomers();
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

          :customers.isEmpty

              ? const Center(
                  child: Text(
                    "No Customers Found",
                  ),
                )

              : ListView.builder(
                  padding:
                      const EdgeInsets.all(
                    16,
                  ),

                itemCount: customers.length,

                  itemBuilder:
                      (context, index) {

                    final customer =
    customers[index];

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
                        Icons.person    ,
                            color:
                                Colors.white,
                          ),
                        ),

                      title: Text(
  customer.customerName,
),

                       subtitle: Text(
  customer.phone,
),

                        trailing: Row(
  mainAxisSize: MainAxisSize.min,

  children: [

    IconButton(
      onPressed: () async {

        await Navigator.push(
          context,

          MaterialPageRoute(
            builder: (_) =>
                EditCustomerScreen(
              customer: customer,
            ),
          ),
        );

        loadCustomers();
      },

      icon: const Icon(
        Icons.edit,
        color: Colors.blue,
      ),
    ),

    IconButton(
      onPressed: () async {

        final confirm =
            await showDialog<bool>(
          context: context,

          builder: (context) =>
              AlertDialog(
            title: const Text(
              "Delete Customer",
            ),

            content: Text(
              "Are you sure you want to delete '${customer.customerName}'?",
            ),

            actions: [

              TextButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                    false,
                  );
                },

                child:
                    const Text(
                  "Cancel",
                ),
              ),

              TextButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                    true,
                  );
                },

                child:
                    const Text(
                  "Delete",
                  style: TextStyle(
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        );

        if (confirm == true) {

          try {

            await CustomerService()
                .deleteCustomer(
              customer.id,
            );

            await loadCustomers();

            if (context.mounted) {

              ScaffoldMessenger.of(
                      context)
                  .showSnackBar(
                const SnackBar(
                  content: Text(
                    "Customer Deleted Successfully",
                  ),
                ),
              );
            }

          } catch (e) {

            ScaffoldMessenger.of(
                    context)
                .showSnackBar(
              SnackBar(
                content:
                    Text(
                  e.toString(),
                ),
              ),
            );
          }
        }
      },

      icon: const Icon(
        Icons.delete,
        color: Colors.red,
      ),
    ),
  ],
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
                  const AddCustomerScreen(),
            ),
          );

        loadCustomers();
        },

        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }
}