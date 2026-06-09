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

  required String brandName,
  required String storageLocation,
    required String unit,
  required int lowStockThreshold,
    required String imageUrl,


}) async {

  await dio.post(
    "http://10.0.2.2:5000/api/products",

    data: {
  "name": name,
  "sku": sku,

  "brandName": brandName,

  "storageLocation": storageLocation,

  "unit": unit,

  "lowStockThreshold": lowStockThreshold,

  "imageUrl": imageUrl,

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

  required String brandName,
  required String storageLocation,
  required String unit,

  required int stock,
  required int lowStockThreshold,

  required double purchasePrice,
  required double sellingPrice,

  required String imageUrl,
}) async {
    await dio.put(
      "http://10.0.2.2:5000/api/products/$id",

      data: {
  "name": name,
  "sku": sku,

  "brandName": brandName,

  "storageLocation": storageLocation,

  "unit": unit,

  "stock": stock,

  "lowStockThreshold": lowStockThreshold,

  "purchasePrice": purchasePrice,

  "sellingPrice": sellingPrice,

  "imageUrl": imageUrl,
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
