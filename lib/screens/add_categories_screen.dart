import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../services/category_service.dart';

class AddCategoriesScreen extends StatefulWidget {
  const AddCategoriesScreen({super.key});

  @override
  State<AddCategoriesScreen> createState() =>
      _AddCategoriesScreenState();
}

class _AddCategoriesScreenState
    extends State<AddCategoriesScreen> {

  final CategoryService categoryService =
      CategoryService();

  final categoryNameController =
      TextEditingController();

  final notesController =
      TextEditingController();

  List<Category> categories = [];

  String? selectedParentCategory;
  String? selectedUnit;

  bool isFragile = false;
  bool isReturnable = false;

  bool isLoading = false;

  @override
  void initState() {
    super.initState();
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

  Future<void> addCategory() async {

    if (categoryNameController.text
        .trim()
        .isEmpty) {

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            "Category name is required",
          ),
        ),
      );

      return;
    }

    setState(() {
      isLoading = true;
    });

    try {

      await categoryService
          .createCategory(
        name:
            categoryNameController.text
                .trim(),

        parentCategoryId:
            selectedParentCategory,

        unit:
            selectedUnit ?? "",

        isFragile:
            isFragile,

        isReturnable:
            isReturnable,

        notes:
            notesController.text.trim(),
      );

      if (mounted) {

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              "Category Added Successfully",
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
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor:
          const Color(0xFFF5F7FC),

      appBar: AppBar(
        title:
            const Text("Add Category"),
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
              value:
                  selectedParentCategory,

              decoration:
                  fieldDecoration(
                "Parent Category",
              ),

              items: [

                const DropdownMenuItem(
                  value: null,
                  child: Text("None"),
                ),

                ...categories.map(
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

            /// Unit Dropdown
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
                      value ??
                          false;
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
                      value ??
                          false;
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

            /// Save Button
            SizedBox(
              width:
                  double.infinity,

              height: 55,

              child: ElevatedButton(
                onPressed:
                    isLoading
                        ? null
                        : addCategory,

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
                        color: Colors
                            .white,
                      )
                    : const Text(
                        "Save Category",
                        style:
                            TextStyle(
                          color: Colors
                              .white,
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