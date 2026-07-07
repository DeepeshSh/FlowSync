import 'package:dio/dio.dart';
import '../models/category_model.dart';
import '../config/api_config.dart';

class CategoryService {
  final Dio dio = Dio();
  final String baseUrl = "${ApiConfig.baseUrl}/categories";

  Future<List<Category>> getCategories() async {
    final response = await dio.get(baseUrl);
    return (response.data as List)
        .map((e) => Category.fromJson(e))
        .toList();
  }

  Future<void> createCategory({
    required String name,
    String? parentCategoryId,
    required String unit,
    required bool isFragile,
    required bool isReturnable,
    required String notes,
  }) async {
    await dio.post(
      "$baseUrl/api/categories",
      data: {
        "name": name,
        "parentCategoryId": parentCategoryId,
        "unit": unit,
        "isFragile": isFragile,
        "isReturnable": isReturnable,
        "notes": notes,
      },
    );
  }

  /// Updates an existing category profile configuration parameters via PUT request
  Future<void> updateCategory(Category category) async {
    await dio.put(
      "$baseUrl/api/categories/${category.id}",
      data: {
        "name": category.name,
        "parentCategoryId": category.parentCategoryId,
        "unit": category.unit,
        "isFragile": category.isFragile,
        "isReturnable": category.isReturnable,
        "notes": category.notes,
      },
    );
  }

  Future<void> deleteCategory(String id) async {
    await dio.delete(
      "$baseUrl/api/categories/$id",
    );
  }
}