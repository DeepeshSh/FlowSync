import 'package:dio/dio.dart';
import '../models/product_model.dart';
import '../config/api_config.dart';
import '../utils/api_constants.dart';
import 'notification_service.dart';

class ProductService {
  final Dio dio = ApiConfig.dio;
  Dio get _dio => dio;

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

      NotificationService().showAuditNotification(
        title: "Product Created",
        body: "$name ($sku) registered with stock of $stock $unit.",
      );
      if (stock < lowStockThreshold) {
        NotificationService().showLowStockAlert(
          productName: name,
          remainingStock: stock,
        );
      }
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

      NotificationService().showAuditNotification(
        title: "Product Updated",
        body: "$name ($sku) details updated. Current stock: $stock $unit.",
      );
      if (stock <= lowStockThreshold) {
        NotificationService().showLowStockAlert(
          productName: name,
          remainingStock: stock,
        );
      }
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
  
  // UPDATE PRODUCT STOCK (PUT instead of PATCH)
  Future<void> updateProductStock(String id, int syncTotal) async {
    try {
      final response = await dio.put(
        "${ApiConfig.baseUrl}/products/$id",
        data: {
          "stock": syncTotal,
        },
      );
      print("STOCK UPDATE STATUS : ${response.statusCode}");
      print("STOCK UPDATE BODY : ${response.data}");

      NotificationService().showAuditNotification(
        title: "Stock Level Adjusted",
        body: "Inventory item stock synchronized to $syncTotal units.",
      );
      if (syncTotal < 10) {
        NotificationService().showLowStockAlert(
          productName: "Inventory Item",
          remainingStock: syncTotal,
        );
      }
    } on DioException catch (e) {
      print("STOCK UPDATE ERROR : ${e.response?.data ?? e.message}");
      rethrow;
    }
  }

  // DELETE PRODUCT
  Future<bool> deleteProduct(String id) async {
    try {
      final response = await _dio.delete('${ApiConstants.products}/$id');
      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  // GET INVENTORY STATS
  Future<Map<String, dynamic>> getInventoryStats() async {
    try {
      final response = await dio.get("${ApiConstants.products}/stats/summary");
      if (response.data is Map<String, dynamic>) {
        final data = response.data['stats'] ?? response.data['data'] ?? response.data;
        if (data is Map<String, dynamic>) {
          return Map<String, dynamic>.from(data);
        }
      }
    } catch (_) {
      // Fallback: calculate stats locally from getProducts()
    }

    try {
      final products = await getProducts();
      int totalProducts = products.length;
      int totalStock = 0;
      int lowStockCount = 0;
      int outOfStockCount = 0;
      double totalValue = 0.0;

      for (final p in products) {
        final stock = p.stock;
        final price = p.sellingPrice > 0 ? p.sellingPrice : p.purchasePrice;
        totalStock += stock;
        totalValue += stock * price;

        if (stock == 0) {
          outOfStockCount++;
        } else if (stock < 10) {
          lowStockCount++;
        }
      }

      return {
        'totalProducts': totalProducts,
        'totalStock': totalStock,
        'lowStockCount': lowStockCount,
        'outOfStockCount': outOfStockCount,
        'totalValue': totalValue,
      };
    } catch (_) {
      return {
        'totalProducts': 0,
        'totalStock': 0,
        'lowStockCount': 0,
        'outOfStockCount': 0,
        'totalValue': 0.0,
      };
    }
  }
}