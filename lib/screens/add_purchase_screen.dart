import 'package:flutter/material.dart';

class AddPurchaseScreen extends StatelessWidget {
  const AddPurchaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Purchase"),
      ),

      body: const Center(
        child: Text(
          "Add Purchase Screen",
        ),
      ),
    );
  }
}