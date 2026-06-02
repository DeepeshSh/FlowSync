import 'package:dio/dio.dart';
import '../models/product_model.dart';

class ProductService {
  final Dio dio = Dio();

  // GET PRODUCTS
  Future<List<Product>> getProducts() async {
    final response = await dio.get("http://10.0.2.2:5000/api/products");

    return (response.data as List).map((e) => Product.fromJson(e)).toList();
  }

  // ADD PRODUCT
  Future<void> addProduct({
  required String name,
  required String sku,
  required int stock,
  required double purchasePrice,
  required double sellingPrice,
  required String category,
}) async {

  await dio.post(
    "http://10.0.2.2:5000/api/products",

    data: {
      "name": name,
      "sku": sku,
      "stock": stock,
      "purchasePrice": purchasePrice,
      "sellingPrice": sellingPrice,
      "category": category,
    },
  );
}

  Future<void> updateProduct({
    required String id,
    required String name,
    required String sku,
    required int stock,
    required double purchasePrice,
    required double sellingPrice,
  }) async {
    await dio.put(
      "http://10.0.2.2:5000/api/products/$id",

      data: {
        "name": name,
        "sku": sku,
        "stock": stock,
        "purchasePrice": purchasePrice,
        "sellingPrice": sellingPrice,
      },
    );
  }

  Future<void> deleteProduct(
  String id,
) async {

  await dio.delete(
    "http://10.0.2.2:5000/api/products/$id",
  );
}
}
