import 'package:flutter/material.dart';

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

  List<Category> filteredCategories = [];

  bool isLoading = true;

  final TextEditingController
      searchController =
          TextEditingController();

  int totalProducts = 0;

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

      filteredCategories = data;

      isLoading = false;
    });

  } catch (e) {

    setState(() {
      isLoading = false;
    });
  }
}
void searchCategories(
  String query,
) {

  setState(() {

    filteredCategories =
        categories.where(
      (category) {

        return category.name
            .toLowerCase()
            .contains(
              query.toLowerCase(),
            );

      },
    ).toList();
  });
}
Widget buildHeaderCard() {

  return Container(

    padding: const EdgeInsets.fromLTRB(
      16,
      10,
      16,
      10,
    ),

    decoration: BoxDecoration(

      gradient:
          const LinearGradient(
        colors: [
          Color(0xFF143D7A),
          Color(0xFF1E5CB3),
        ],
      ),

      borderRadius:
          BorderRadius.circular(22),
    ),

    child: Row(

      children: [

        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              const Text(
                "Total Categories",

                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              Text(
                categories.length
                    .toString(),

                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ],
          ),
        ),

        Padding(
          padding:
              const EdgeInsets.only(
            top: 6,
          ),

          child: Container(
            width: 1,
            height: 80,
            color: Colors.white24,
          ),
        ),

        Expanded(
          child: Padding(
            padding:
                const EdgeInsets.only(
              left: 16,
            ),

            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,

              children: [

                const Text(
                  "Total Products",

                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  totalProducts
                      .toString(),

                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
Widget buildCategoryCard(
  Category category,
) {

  return Container(

    margin: const EdgeInsets.only(
      bottom: 14,
    ),

    padding: const EdgeInsets.all(
      16,
    ),

    decoration: BoxDecoration(

      color: Colors.white,

      borderRadius:
          BorderRadius.circular(
        20,
      ),

      boxShadow: const [
        BoxShadow(
          color: Colors.black12,
          blurRadius: 8,
        ),
      ],
    ),

    child: Row(

      crossAxisAlignment:
          CrossAxisAlignment.start,

      children: [

        // CATEGORY ICON

        Container(

          width: 58,
          height: 58,

          decoration: BoxDecoration(

            color:
                const Color(
              0xFFEAF4FF,
            ),

            borderRadius:
                BorderRadius.circular(
              18,
            ),
          ),

          child: const Icon(
            Icons.category_outlined,

            color:
                Color(
              0xFF2F80FF,
            ),

            size: 28,
          ),
        ),

        const SizedBox(
          width: 14,
        ),

        // DETAILS

        Expanded(

          child: Column(

            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              Text(
                category.name,

                style:
                    const TextStyle(

                  fontSize: 17,

                  fontWeight:
                      FontWeight.bold,

                  color:
                      Color(
                    0xFF1B2559,
                  ),
                ),
              ),

              const SizedBox(
                height: 3,
              ),

              Text(

                category.notes.isEmpty
                    ? "No description available"
                    : category.notes,

                maxLines: 1,

                overflow:
                    TextOverflow
                        .ellipsis,

                style:
                    TextStyle(

                  fontSize: 13,

                  color:
                      Colors.grey
                          .shade600,
                ),
              ),

              const SizedBox(
                height: 10,
              ),

              Row(

                children: [

                  Icon(
                    Icons.inventory_2_outlined,

                    size: 15,

                    color:
                        Colors.grey
                            .shade600,
                  ),

                  const SizedBox(
                    width: 4,
                  ),

                  Text(

                    "0 Products",

                    style:
                        TextStyle(

                      color:
                          Colors.grey
                              .shade700,

                      fontWeight:
                          FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        Column(

          children: [

            PopupMenuButton(

              icon: const Icon(
                Icons.more_vert,
                color:
                    Color(
                  0xFF1B2559,
                ),
              ),

              itemBuilder:
                  (context) => [],
            ),

            const SizedBox(
              height: 18,
            ),

            const Icon(
              Icons.chevron_right,

              color: Color(
                0xFF1B2559,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
@override
Widget build(
  BuildContext context,
) {

  return Scaffold(

    backgroundColor:
        const Color(0xFFF5F7FC),

    appBar: AppBar(

      backgroundColor:
          const Color(0xFFF5F7FC),

      elevation: 0,

      title: const Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,

        children: [

          Text(
            "Categories",

            style: TextStyle(
              color: Color(0xFF1B2559),
              fontSize: 24,
              fontWeight:
                  FontWeight.bold,
            ),
          ),

          Text(
            "Manage product categories",

            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    ),
body: isLoading

    ? const Center(
        child:
            CircularProgressIndicator(),
      )

    : SingleChildScrollView(

        padding:
            const EdgeInsets.all(
          20,
        ),

        child: Column(

          children: [

            buildHeaderCard(),

            const SizedBox(
              height: 20,
            ),

            TextField(

              controller:
                  searchController,

              onChanged:
                  searchCategories,

              decoration:
                  InputDecoration(

                hintText:
                    "Search category...",

                prefixIcon:
                    const Icon(
                  Icons.search,
                ),

                filled: true,

                fillColor:
                    Colors.white,

                border:
                    OutlineInputBorder(

                  borderRadius:
                      BorderRadius.circular(
                    16,
                  ),

                  borderSide:
                      BorderSide.none,
                ),
              ),
            ),

            const SizedBox(
              height: 18,
            ),
            filteredCategories.isEmpty

    ? Container(

        padding:
            const EdgeInsets.all(
          40,
        ),

        child:
            const Column(

          children: [

            Icon(
              Icons.category_outlined,

              size: 70,

              color:
                  Colors.grey,
            ),

            SizedBox(
              height: 12,
            ),

            Text(
              "No Categories Found",

              style: TextStyle(
                fontSize: 18,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ],
        ),
      )

    : ListView.builder(

        shrinkWrap: true,

        physics:
            const NeverScrollableScrollPhysics(),

        itemCount:
            filteredCategories
                .length,

        itemBuilder:
            (context, index) {

          final category =
              filteredCategories[
                  index];

          return buildCategoryCard(
            category,
          );
        },
      ),
                ],
        ),
      ),

floatingActionButton:
    FloatingActionButton.extended(

  backgroundColor:
      const Color(
    0xFF143D7A,
  ),

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
    color: Colors.white,
  ),

  label: const Text(
    "Add Category",

    style: TextStyle(
      color: Colors.white,
    ),
  ),
),
);
}

}