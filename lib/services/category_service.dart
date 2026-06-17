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
      "parentCategoryId":
          parentCategoryId,
      "unit": unit,
      "isFragile": isFragile,
      "isReturnable":
          isReturnable,
      "notes": notes,
    },
  );
}

Future<void> deleteCategory(
  String id,
) async {

  await dio.delete(
    "$baseUrl/api/categories/$id",
  );
}

}