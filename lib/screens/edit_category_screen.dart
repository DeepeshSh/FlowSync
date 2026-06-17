import 'package:flutter/material.dart';

import '../models/category_model.dart';
import '../services/category_service.dart';

class EditCategoryScreen extends StatefulWidget {
  final Category category;

  const EditCategoryScreen({
    super.key,
    required this.category,
  });

  @override
  State<EditCategoryScreen> createState() =>
      _EditCategoryScreenState();
}

class _EditCategoryScreenState
    extends State<EditCategoryScreen> {

  final CategoryService categoryService =
      CategoryService();

  late TextEditingController
      categoryNameController;

  late TextEditingController
      notesController;

  List<Category> categories = [];

  String? selectedParentCategory;
  String? selectedUnit;

  bool isFragile = false;
  bool isReturnable = false;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    categoryNameController =
        TextEditingController(
      text: widget.category.name,
    );

    notesController =
        TextEditingController(
      text: widget.category.notes,
    );

    selectedParentCategory =
        widget.category.parentCategoryId;

    selectedUnit =
        widget.category.unit;

    isFragile =
        widget.category.isFragile;

    isReturnable =
        widget.category.isReturnable;

    loadCategories();
  }

  Future<void> loadCategories() async {
    try {

      categories =
          await categoryService
              .getCategories();

      if (mounted) {
        setState(() {});
      }

    } catch (e) {
      debugPrint(e.toString());
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
    categoryNameController.dispose();
    notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F7FC),

      appBar: AppBar(
        title:
            const Text("Edit Category"),

        elevation: 0,
      ),

      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(16),

        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            /// Category Name

            TextField(
              controller:
                  categoryNameController,

              decoration:
                  fieldDecoration(
                "Category Name *",
              ),
            ),

            const SizedBox(
              height: 16,
            ),

            /// Parent Category

            DropdownButtonFormField<
                String>(
              value: categories.any(
        (c) =>
            c.id ==
            selectedParentCategory)
    ? selectedParentCategory
    : null,
              decoration:
                  fieldDecoration(
                "Parent Category",
              ),

              items: [

                const DropdownMenuItem(
                  value: null,
                  child: Text("None"),
                ),

                ...categories
                    .where(
                      (category) =>
                          category.id !=
                          widget.category.id,
                    )
                    .map(
                      (category) =>
                          DropdownMenuItem(
                        value:
                            category.id,

                        child: Text(
                          category.name,
                        ),
                      ),
                    ),
              ],

              onChanged: (value) {
                setState(() {
                  selectedParentCategory =
                      value;
                });
              },
            ),

            const SizedBox(
              height: 16,
            ),

            /// Unit

            DropdownButtonFormField<
                String>(
              value: selectedUnit,

              decoration:
                  fieldDecoration(
                "Unit of Measurement",
              ),

              items: const [

                DropdownMenuItem(
                  value:
                      "Piece (pcs)",
                  child: Text(
                    "Piece (pcs)",
                  ),
                ),

                DropdownMenuItem(
                  value: "Box",
                  child:
                      Text("Box"),
                ),

                DropdownMenuItem(
                  value:
                      "Packet",
                  child: Text(
                    "Packet",
                  ),
                ),

                DropdownMenuItem(
                  value:
                      "Meter",
                  child: Text(
                    "Meter",
                  ),
                ),

                DropdownMenuItem(
                  value: "Feet",
                  child:
                      Text("Feet"),
                ),

                DropdownMenuItem(
                  value: "Kg",
                  child:
                      Text("Kg"),
                ),

                DropdownMenuItem(
                  value: "Liter",
                  child:
                      Text("Liter"),
                ),

                DropdownMenuItem(
                  value: "Set",
                  child:
                      Text("Set"),
                ),
              ],

              onChanged: (value) {
                setState(() {
                  selectedUnit =
                      value;
                });
              },
            ),

            const SizedBox(
              height: 16,
            ),

            /// Fragile

            CheckboxListTile(
              value: isFragile,

              title: const Text(
                "Fragile Category",
              ),

              contentPadding:
                  EdgeInsets.zero,

              onChanged: (value) {
                setState(() {
                  isFragile =
                      value ?? false;
                });
              },
            ),

            /// Returnable

            CheckboxListTile(
              value:
                  isReturnable,

              title: const Text(
                "Returnable Category",
              ),

              contentPadding:
                  EdgeInsets.zero,

              onChanged: (value) {
                setState(() {
                  isReturnable =
                      value ?? false;
                });
              },
            ),

            const SizedBox(
              height: 8,
            ),

            /// Notes

            TextField(
              controller:
                  notesController,

              maxLines: 4,

              decoration:
                  fieldDecoration(
                "Notes",
              ),
            ),

            const SizedBox(
              height: 24,
            ),

            /// Update Button

            SizedBox(
              width:
                  double.infinity,

              height: 55,

              child: ElevatedButton(
                onPressed:
                    isLoading
                        ? null
                        : () {

                            // TODO:
                            // Update Category API

                          },

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
                        "Update Category",

                        style:
                            TextStyle(
                          color:
                              Colors.white,

                          fontWeight:
                              FontWeight
                                  .bold,
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