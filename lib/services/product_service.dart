import 'package:dio/dio.dart';
import '../models/product_model.dart';

class ProductService {
  final Dio dio = Dio();

  // GET PRODUCTS
  Future<List<Product>> getProducts() async {
    final response = await dio.get("http://10.0.2.2:5000/api/products");

    final List data = response.data["data"];

    return data
        .map((e) => Product.fromJson(e))
        .toList();
  }

  // ADD PRODUCT
  Future<void> addProduct({
    required String name,
    required String sku,
    required String brandName,
    required String category,
    required String warehouseId,
    required String storageLocation,
    required String unit,
    required int stock,
    required int lowStockThreshold,
    required double purchasePrice,
    required double sellingPrice,
    required String hsnCode,
    required String barcode,
    required String description,
    required double length,
    required double width,
    required double height,
    required String dimensionUnit,
    required bool fragile,
    required double gstPercentage,
    required double mrp,
    required String supplierName,
    required double amountPaid,
    required double outstandingBalance,
    required String purchaseDate,
    required String imageUrl,
  }) async {
    try {
      final response = await dio.post(
        "http://10.0.2.2:5000/api/products",
        data: {
          "name": name,
          "sku": sku,
          "brandName": brandName,
          "category": category,
          "warehouseId": warehouseId,
          "storageLocation": storageLocation,
          "unit": unit,
          "stock": stock,
          "lowStockThreshold": lowStockThreshold,
          "purchasePrice": purchasePrice,
          "sellingPrice": sellingPrice,
          "hsnCode": hsnCode,
          "barcode": barcode,
          "description": description,
          "dimensions": {
            "length": length,
            "width": width,
            "height": height,
            "unit": dimensionUnit,
          },
          "fragile": fragile,
          "gstPercentage": gstPercentage,
          "mrp": mrp,
          "supplierName": supplierName,
          "amountPaid": amountPaid,
          "outstandingBalance": outstandingBalance,
          "purchaseDate": purchaseDate,
          "imageUrl": imageUrl,
          "isActive": true,
          "hasVariants": false,
        },
      );

      print("STATUS : ${response.statusCode}");
      print("BODY : ${response.data}");
    } on DioException catch (e) {
      print("STATUS : ${e.response?.statusCode}");
      print("ERROR : ${e.response?.data}");
      rethrow;
    }
  }

  // UPDATE PRODUCT
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

  // UPDATE PRODUCT STOCK (PATCH)
  Future<void> updateProductStock(String id, int syncTotal) async {
    try {
      await dio.patch(
        "http://10.0.2.2:5000/api/products/$id",
        data: {
          "stock": syncTotal,
        },
      );
    } on DioException catch (e) {
      print("STOCK UPDATE ERROR : ${e.response?.data}");
      rethrow;
    }
  }

  // DELETE PRODUCT
  Future<void> deleteProduct(String id) async {
    await dio.delete(
      "http://10.0.2.2:5000/api/products/$id",
    );
  }
}