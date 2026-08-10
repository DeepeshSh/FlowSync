import 'package:dio/dio.dart';
import '../models/product_model.dart';
import '../config/api_config.dart';

class ProductService {
  final Dio dio = Dio();

  // GET PRODUCTS
  Future<List<Product>> getProducts() async {
    try {
      final response = await dio.get("${ApiConfig.baseUrl}/products");

      final dynamic responseData = response.data;
      List rawList = [];

      if (responseData is Map<String, dynamic> && responseData.containsKey("data")) {
        rawList = responseData["data"] ?? [];
      } else if (responseData is List) {
        rawList = responseData;
      }

      return rawList.map((e) => Product.fromJson(e as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      print("GET PRODUCTS ERROR: ${e.response?.data ?? e.message}");
      rethrow;
    } catch (e) {
      print("JSON PARSING ERROR IN GET PRODUCTS: $e");
      rethrow;
    }
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
        "${ApiConfig.baseUrl}/products",
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

  // UPDATE PRODUCT (PUT)
  Future<void> updateProduct({
    required String id,
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
      final response = await dio.put(
        "${ApiConfig.baseUrl}/products/$id",
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

      print("UPDATE STATUS : ${response.statusCode}");
      print("UPDATE BODY : ${response.data}");
    } on DioException catch (e) {
      print("UPDATE ERROR : ${e.response?.data ?? e.message}");
      rethrow;
    }
  }

  // UPDATE ONLY PURCHASE PRICE (PUT)
  Future<void> updatePurchasePrice(String id, double newPrice) async {
    try {
      final response = await dio.put(
        "${ApiConfig.baseUrl}/products/$id",
        data: {
          "purchasePrice": newPrice,
          
        },
      );
      print("UPDATE PRICE STATUS : ${response.statusCode}");
      print("UPDATE PRICE BODY : ${response.data}");
    } on DioException catch (e) {
      print("UPDATE PRICE ERROR : ${e.response?.data}");
      rethrow;
    }
  }

// UPDATE ONLY SELLING PRICE (PUT)
  Future<void> updateSellingPrice(String id, double newPrice) async {
    try {
      final response = await dio.put(
        "${ApiConfig.baseUrl}/products/$id",
        data: {
          "sellingPrice": newPrice,
        },
      );
      print("UPDATE SELLING PRICE STATUS : ${response.statusCode}");
      print("UPDATE SELLING PRICE BODY : ${response.data}");
    } on DioException catch (e) {
      print("UPDATE SELLING PRICE ERROR : ${e.response?.data}");
      rethrow;
    }
  }
  
  // UPDATE PRODUCT STOCK (PATCH)
  Future<void> updateProductStock(String id, int syncTotal) async {
    try {
      await dio.patch(
        "${ApiConfig.baseUrl}/products/$id",
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
      "${ApiConfig.baseUrl}/products/$id",
    );
  }
}