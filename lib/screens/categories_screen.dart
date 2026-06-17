import 'package:flutter/material.dart';
import 'edit_category_screen.dart';
import '../models/category_model.dart';
import '../services/category_service.dart';
import 'add_categories_screen.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() =>
      _CategoriesScreenState();
}

class _CategoriesScreenState
    extends State<CategoriesScreen> {

  List<Category> categories = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    loadCategories();
  }

  Future<void> loadCategories() async {
    try {

      final data =
          await CategoryService()
              .getCategories();

      setState(() {
        categories = data;
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
          "Categories",
        ),

        centerTitle: true,

        backgroundColor:
            Colors.white,

        elevation: 0,

        actions: [

          IconButton(
  onPressed: () async {

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const AddCategoriesScreen(),
      ),
    );

    loadCategories();
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

          : categories.isEmpty

              ? const Center(
                  child: Text(
                    "No Categories Found",
                  ),
                )

              : ListView.builder(
                  padding:
                      const EdgeInsets.all(
                    16,
                  ),

                  itemCount:
                      categories.length,

                  itemBuilder:
                      (context, index) {

                    final category =
                        categories[index];

                    return Container(
                      margin:
                          const EdgeInsets.only(
                        bottom: 12,
                      ),

                      decoration:
                          BoxDecoration(
                        color:
                            Colors.white,

                        borderRadius:
                            BorderRadius.circular(
                          18,
                        ),

                        boxShadow: const [
                          BoxShadow(
                            color:
                                Colors.black12,
                            blurRadius: 8,
                          ),
                        ],
                      ),

                      child: ListTile(

                        leading:
                            const CircleAvatar(
                          backgroundColor:
                              Color(
                            0xFF2F80FF,
                          ),

                          child: Icon(
                            Icons.category,
                            color:
                                Colors.white,
                          ),
                        ),

                        title: Text(
                          category.name,

                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),

                        

                        trailing: Row(
                          mainAxisSize:
                              MainAxisSize.min,

                          children: [

                           IconButton(
  onPressed: () async {

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            EditCategoryScreen(
          category: category,
        ),
      ),
    );

    loadCategories();
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
        title:
            const Text(
          "Delete Category",
        ),

        content:
            Text(
          "Are you sure you want to delete '${category.name}'?",
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
                color:
                    Colors.red,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {

      try {

        await CategoryService()
            .deleteCategory(
          category.id,
        );

        await loadCategories();

        if (context.mounted) {

          ScaffoldMessenger.of(
                  context)
              .showSnackBar(
            const SnackBar(
              content: Text(
                "Category Deleted Successfully",
              ),
            ),
          );
        }

      } catch (e) {

        if (context.mounted) {

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

     floatingActionButton: FloatingActionButton(
  backgroundColor:
      const Color(0xFF2F80FF),

  onPressed: () async {

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const AddCategoriesScreen(),
      ),
    );

    loadCategories();
  },

  child: const Icon(
    Icons.add,
    color: Colors.white,
  ),
),
    );
  }
}