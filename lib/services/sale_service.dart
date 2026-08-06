import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../models/sale_model.dart';

class SaleService {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  /// Fetch all sales
  Future<List<Sale>> getSales() async {
    try {
      final response = await dio.get("/sales");

      if (response.statusCode == 200) {
        if (response.data is List) {
          return (response.data as List)
              .map((e) => Sale.fromJson(e))
              .toList();
        }

        if (response.data is Map &&
            response.data["data"] is List) {
          return (response.data["data"] as List)
              .map((e) => Sale.fromJson(e))
              .toList();
        }
      }

      return [];
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ??
            e.message ??
            "Failed to fetch sales.",
      );
    }
  }

  /// Create Sale
  Future<void> createSale(
    Map<String, dynamic> saleData,
  ) async {
    try {
      // Convert UI item keys to backend schema keys
      if (saleData["items"] != null) {
        saleData["items"] =
            (saleData["items"] as List).map((item) {
          final Map<dynamic, dynamic> itemMap =
              item as Map;

          return {
            "productId": itemMap["productId"],
            "productName":
                itemMap["productName"],
            "quantity":
                itemMap["quantity"],
            "sellingPrice":
                itemMap["sellingPrice"] ??
                    itemMap["rate"] ??
                    0.0,
            "total":
                itemMap["total"] ??
                    itemMap["amount"] ??
                    0.0,
          };
        }).toList();
      }

      final response = await dio.post(
        "/sales",
        data: saleData,
      );

      if (response.statusCode != 200 &&
          response.statusCode != 201) {
        throw Exception(
          "Unexpected server response (${response.statusCode})",
        );
      }
    } on DioException catch (e) {
      String? serverMessage;

      if (e.response?.data is Map<String, dynamic>) {
        serverMessage =
            e.response?.data["message"]?.toString();
      }

      throw Exception(
        serverMessage ??
            e.message ??
            "Failed to create sale.",
      );
    }
  }

  /// Get Sale By Id
  Future<Sale> getSaleById(
    String id,
  ) async {
    try {
      final response = await dio.get(
        "/sales/$id",
      );

      if (response.statusCode == 200) {
        if (response.data is Map &&
            response.data["data"] != null) {
          return Sale.fromJson(
            response.data["data"],
          );
        }

        return Sale.fromJson(
          response.data,
        );
      }

      throw Exception("Sale not found.");
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ??
            e.message ??
            "Failed to fetch sale.",
      );
    }
  }

  /// Delete Sale
  Future<void> deleteSale(
    String id,
  ) async {
    try {
      final response = await dio.delete(
        "/sales/$id",
      );

      if (response.statusCode != 200 &&
          response.statusCode != 204) {
        throw Exception(
          "Failed to delete sale.",
        );
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ??
            e.message ??
            "Failed to delete sale.",
      );
    }
  }
}