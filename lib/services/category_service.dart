import 'package:dio/dio.dart';
import '../models/category_model.dart';

class CategoryService {

  final Dio dio = Dio();

  final String baseUrl =
      "http://10.0.2.2:5000";

  Future<List<Category>>
      getCategories() async {

    final response =
        await dio.get(
      "$baseUrl/api/categories",
    );

    return (response.data as List)
        .map(
          (e) => Category.fromJson(e),
        )
        .toList();
  }

  Future<void> createCategory({
    required String name,
    required String description,
  }) async {

    await dio.post(
      "$baseUrl/api/categories",

      data: {
        "name": name,
        "description":
            description,
      },
    );
  }
}