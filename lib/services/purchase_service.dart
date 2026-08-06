import 'package:dio/dio.dart';

import '../config/api_config.dart';
import '../models/purchase_model.dart';

class PurchaseService {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
    ),
  );

  /// Fetch all Purchase Orders
  Future<List<Purchase>> getPurchases() async {
    try {
      final response = await dio.get("/purchases");

      if (response.statusCode == 200) {
        if (response.data is List) {
          return (response.data as List)
              .map((e) => Purchase.fromJson(e))
              .toList();
        }

        if (response.data is Map &&
            response.data["data"] is List) {
          return (response.data["data"] as List)
              .map((e) => Purchase.fromJson(e))
              .toList();
        }
      }

      return [];
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ??
            e.message ??
            "Failed to fetch purchase orders.",
      );
    }
  }

  /// Create Purchase Order
  Future<void> createPurchase(
    Map<String, dynamic> purchaseData,
  ) async {
    try {
      final response = await dio.post(
        "/purchases",
        data: purchaseData,
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
            "Failed to create purchase.",
      );
    }
  }

  /// Get Purchase By Id
  Future<Purchase> getPurchaseById(
    String id,
  ) async {
    try {
      final response = await dio.get(
        "/purchases/$id",
      );

      if (response.statusCode == 200) {
        if (response.data is Map &&
            response.data["data"] != null) {
          return Purchase.fromJson(
            response.data["data"],
          );
        }

        return Purchase.fromJson(
          response.data,
        );
      }

      throw Exception(
        "Purchase not found.",
      );
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ??
            e.message ??
            "Failed to fetch purchase.",
      );
    }
  }

  /// Update Purchase
  Future<void> updatePurchase(
    String id,
    Map<String, dynamic> purchaseData,
  ) async {
    try {
      final response = await dio.put(
        "/purchases/$id",
        data: purchaseData,
      );

      if (response.statusCode != 200) {
        throw Exception(
          "Failed to update purchase.",
        );
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ??
            e.message ??
            "Failed to update purchase.",
      );
    }
  }

  /// Delete Purchase
  Future<void> deletePurchase(
    String id,
  ) async {
    try {
      final response = await dio.delete(
        "/purchases/$id",
      );

      if (response.statusCode != 200 &&
          response.statusCode != 204) {
        throw Exception(
          "Failed to delete purchase.",
        );
      }
    } on DioException catch (e) {
      throw Exception(
        e.response?.data["message"] ??
            e.message ??
            "Failed to delete purchase.",
      );
    }
  }
}