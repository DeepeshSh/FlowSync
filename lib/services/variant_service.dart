import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../models/variant_model.dart';

class VariantService {
  final Dio dio = Dio();

  Future<List<Variant>> getVariants() async {
    final response = await dio.get(
      "${ApiConfig.baseUrl}/variants",
    );

    final List data = response.data["data"];

    return data
        .map((e) => Variant.fromJson(e))
        .toList();
  }

  
Future<List<Variant>> getVariantsByProduct(
  String productId,
) async {

  print("Product ID = $productId");

  final url =
      "${ApiConfig.baseUrl}/variants/product/$productId";

  print("URL = $url");

  final response = await dio.get(url);

  final List data = response.data["data"];

  return data
      .map((e) => Variant.fromJson(e))
      .toList();
}
  Future<List<Variant>> getVariantsByWarehouse(
    String warehouseId,
  ) async {
    final response = await dio.get(
      "${ApiConfig.baseUrl}/variants/warehouse/$warehouseId",
    );

    final List data = response.data["data"];

    return data
        .map((e) => Variant.fromJson(e))
        .toList();
  }

  Future<Variant> getVariant(
    String id,
  ) async {
    final response = await dio.get(
      "${ApiConfig.baseUrl}/variants/$id",
    );

    return Variant.fromJson(
      response.data["data"],
    );
  }

  Future<void> createVariant({
    required String productId,
    required String variantName,
    required String sku,
    required String barcode,
    required String warehouseId,
    required String storageLocation,
    required int stock,
    required int reservedStock,
    required int lowStockThreshold,
    required double purchasePrice,
    required double sellingPrice,
    required double mrp,
    required double gstPercentage,
    required String imageUrl,
    required bool isActive,
  }) async {
    await dio.post(
      "${ApiConfig.baseUrl}/variants",
      data: {
        "productId": productId,
        "variantName": variantName,
        "sku": sku,
        "barcode": barcode,
        "warehouseId": warehouseId,
        "storageLocation": storageLocation,
        "stock": stock,
        "reservedStock": reservedStock,
        "lowStockThreshold": lowStockThreshold,
        "purchasePrice": purchasePrice,
        "sellingPrice": sellingPrice,
        "mrp": mrp,
        "gstPercentage": gstPercentage,
        "imageUrl": imageUrl,
        "isActive": isActive,
      },
    );
  }

  Future<void> updateVariant({
    required String id,
    required String variantName,
    required String sku,
    required String barcode,
    required String warehouseId,
    required String storageLocation,
    required int stock,
    required int reservedStock,
    required int lowStockThreshold,
    required double purchasePrice,
    required double sellingPrice,
    required double mrp,
    required double gstPercentage,
    required String imageUrl,
    required bool isActive,
  }) async {
    await dio.put(
      "${ApiConfig.baseUrl}/variants/$id",
      data: {
        "variantName": variantName,
        "sku": sku,
        "barcode": barcode,
        "warehouseId": warehouseId,
        "storageLocation": storageLocation,
        "stock": stock,
        "reservedStock": reservedStock,
        "lowStockThreshold": lowStockThreshold,
        "purchasePrice": purchasePrice,
        "sellingPrice": sellingPrice,
        "mrp": mrp,
        "gstPercentage": gstPercentage,
        "imageUrl": imageUrl,
        "isActive": isActive,
      },
    );
  }

  Future<void> deleteVariant(
    String id,
  ) async {
    await dio.delete(
      "${ApiConfig.baseUrl}/variants/$id",
    );
  }
}