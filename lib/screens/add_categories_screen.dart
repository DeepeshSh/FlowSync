


import 'package:flutter/material.dart';
import '../models/category_model.dart';
import '../services/category_service.dart';

class AddCategoriesScreen extends StatefulWidget {
  const AddCategoriesScreen({super.key});

  @override
  State<AddCategoriesScreen> createState() => _AddCategoriesScreenState();
}

class _AddCategoriesScreenState extends State<AddCategoriesScreen> {
  final CategoryService categoryService = CategoryService();

  final TextEditingController categoryNameController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

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
      categories = await categoryService.getCategories();
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> addCategory() async {
    if (categoryNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Category name is required"),
        ),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await categoryService.createCategory(
        name: categoryNameController.text.trim(),
        parentCategoryId: selectedParentCategory,
        unit: selectedUnit ?? "",
        isFragile: isFragile,
        isReturnable: isReturnable,
        notes: notesController.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Category Added Successfully"),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [ 
              // HEADER
             
              SizedBox(
                height: 140,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    // Back Button
                    Positioned(
                      top: 20,
                      left: 20,
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 10,
                             
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: Color(0xFF0B1245),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ),

                    // Title
                    const Positioned(
                      top: 34,
                      left: 95,
                      child: Text(
                        "Add Category",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF0B1245),
                        ),
                      ),
                    ),

                    // Store Image
                    Positioned(
                      top: 0,
                      right: 10,
                      child: Image.asset(
                        "lib/assets/images/homeimage (2).png",
                        height: 130,
                      ),
                    ),

                    // Paper Plane
                    Positioned(
                      top: 35,
                      right: -5,
                      child: Image.asset(
                        "lib/assets/images/paper_plane.png",
                        width: 85,
                      ),
                    ),
                  ],
                ),
              ),

              // ===================================
              // FORM SECTION
              // ===================================
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    // =========================
                    // CATEGORY NAME CARD
                    // =========================
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF2FF),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Icon(
                              Icons.sell_outlined,
                              color: Color(0xFF2F80FF),
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                RichText(
                                  text: const TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "Category Name ",
                                        style: TextStyle(
                                          color: Color(0xFF0B1245),
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      TextSpan(
                                        text: "*",
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontSize: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: categoryNameController,
                                  decoration: InputDecoration(
                                    hintText: "Enter category name",
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 18,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(18),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // =========================
                    // PARENT CATEGORY CARD
                    // =========================
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF2FF),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Icon(
                              Icons.account_tree_outlined,
                              color: Color(0xFF2F80FF),
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Parent Category",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0B1245),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                DropdownButtonFormField<String>(
                                  value: selectedParentCategory,
                                  decoration: InputDecoration(
                                    hintText: "Select parent category",
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 18,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(18),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                  ),
                                  items: [
                                    const DropdownMenuItem<String>(
                                      value: "",
                                      child: Text("None"),
                                    ),
                                    ...categories.map(
                                      (category) => DropdownMenuItem(
                                        value: category.id,
                                        child: Text(category.name),
                                      ),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      selectedParentCategory = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // =========================
                    // UNIT CARD
                    // =========================
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF2FF),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Icon(
                              Icons.straighten,
                              color: Color(0xFF2F80FF),
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Unit of Measurement",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0B1245),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                DropdownButtonFormField<String>(
                                  value: selectedUnit,
                                  decoration: InputDecoration(
                                    hintText: "Select unit",
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 18,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(18),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                  ),
                                  items: const [
                                    DropdownMenuItem(
                                      value: "Piece (pcs)",
                                      child: Text("Piece (pcs)"),
                                    ),
                                    DropdownMenuItem(
                                      value: "Box",
                                      child: Text("Box"),
                                    ),
                                    DropdownMenuItem(
                                      value: "Packet",
                                      child: Text("Packet"),
                                    ),
                                    DropdownMenuItem(
                                      value: "Meter",
                                      child: Text("Meter"),
                                    ),
                                    DropdownMenuItem(
                                      value: "Feet",
                                      child: Text("Feet"),
                                    ),
                                    DropdownMenuItem(
                                      value: "Kg",
                                      child: Text("Kg"),
                                    ),
                                    DropdownMenuItem(
                                      value: "Liter",
                                      child: Text("Liter"),
                                    ),
                                    DropdownMenuItem(
                                      value: "Set",
                                      child: Text("Set"),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      selectedUnit = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // =========================
                    // FRAGILE + RETURNABLE CARD
                    // =========================
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // FRAGILE
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Container(
                                  width: 58,
                                  height: 58,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEAF2FF),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: const Icon(
                                    Icons.wine_bar_outlined,
                                    color: Color(0xFF2F80FF),
                                    size: 30,
                                  ),
                                ),
                                const SizedBox(width: 18),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Fragile Category",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        "Handle with extra care",
                                        style: TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: isFragile,
                                  activeColor: const Color(0xFF2F80FF),
                                  onChanged: (value) {
                                    setState(() {
                                      isFragile = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            height: 1,
                            color: Colors.grey.shade200,
                          ),
                          // RETURNABLE
                          Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              children: [
                                Container(
                                  width: 58,
                                  height: 58,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEAF2FF),
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                  child: const Icon(
                                    Icons.replay_circle_filled_outlined,
                                    color: Color(0xFF2F80FF),
                                    size: 30,
                                  ),
                                ),
                                const SizedBox(width: 18),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Returnable Category",
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        "Products can be returned",
                                        style: TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Switch(
                                  value: isReturnable,
                                  activeColor: const Color(0xFF2F80FF),
                                  onChanged: (value) {
                                    setState(() {
                                      isReturnable = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 22),

                    // =========================
                    // NOTES CARD
                    // =========================
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(28),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEAF2FF),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Icon(
                              Icons.note_alt_outlined,
                              color: Color(0xFF2F80FF),
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 18),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Notes",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF0B1245),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: notesController,
                                  maxLines: 1,
                                  decoration: InputDecoration(
                                    hintText: "Enter notes (optional)",
                                    filled: true,
                                    fillColor: Colors.white,
                                    contentPadding: const EdgeInsets.all(18),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(18),
                                      borderSide: BorderSide(
                                        color: Colors.grey.shade300,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // =========================
                    // SAVE BUTTON
                    // =========================
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: isLoading ? null : addCategory,
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.zero,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: Ink(
                          width: double.infinity,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Color(0xFF2F80FF),
                                Color(0xFF5B9DFF),
                              ],
                            ),
                            borderRadius: BorderRadius.all(
                              Radius.circular(20),
                            ),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            child: isLoading
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.save_outlined,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        "Save Category",
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // =========================
                    // FOOTER
                    // =========================
                    SizedBox(
                      height: 90,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            left: 0,
                            right: 0,
                            bottom: 0,
                            child: ClipPath(
                              clipper: WaveClipper(),
                              child: Container(
                                height: 55,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFFDFF8EF),
                                      Color(0xFFEAF7F3),
                                      Color(0xFFD6F3EA),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
  left: 0,
  right: 0,
  bottom: 0,

  child: ClipPath(
    clipper: WaveClipper(),

    child: Container(
      height: 60,
      decoration: const BoxDecoration(
  gradient: LinearGradient(
    colors: [
      Color(0xFFDFF8EF),
      Color(0xFFEAF7F3),
      Color(0xFFD6F3EA),
    ],
  ),
),
    ),
  ),
),

 Positioned(
        left: -5,
        bottom: 0,

        child: Image.asset(
          "lib/assets/images/grass-removebg-preview.png",
          height: 80,
        ),
      ),

      // RIGHT GEARS

      Positioned(
        right: 5,
        bottom: -30,

        child: Image.asset(
          "lib/assets/images/gears-removebg-preview.png",
          height: 150,
        ),
      ),

                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ], // <-- CLOSED: main Column children list
          ),
        ),
      ),
    );
  }
}

// =========================
// WAVE CLIPPER
// =========================
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, 25);
    path.quadraticBezierTo(
      size.width * 0.15,
      0,
      size.width * 0.30,
      20,
    );
    path.quadraticBezierTo(
      size.width * 0.45,
      40,
      size.width * 0.60,
      15,
    );
    path.quadraticBezierTo(
      size.width * 0.75,
      -5,
      size.width,
      25,
    );
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) {
    return false;
  }
}

