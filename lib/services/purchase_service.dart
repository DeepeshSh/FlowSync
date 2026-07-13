import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/purchase_model.dart';

class PurchaseService {
  final Dio dio = Dio(BaseOptions(
    baseUrl: ApiConfig.baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));

  /// Fetches all historic purchase orders from the backend
  Future<List<Purchase>> getPurchases() async {
    try {
      final response = await dio.get("/purchases");
      // Check for a valid successful response and that data is a List
      if (response.statusCode == 200 && response.data is List) {
        return (response.data as List).map((e) => Purchase.fromJson(e)).toList();
      }
      return [];
    } on DioException catch (e) {
      throw Exception(e.message ?? "Failed to fetch purchase orders history.");
    }
  }

  /// Creates a new purchase ledger/order entry
  /// Matches the structured Map payload submitted from AddPurchaseScreen
  Future<void> createPurchase(Map<String, dynamic> purchaseData) async {
    try {
      final response = await dio.post(
        "/purchases",
        data: purchaseData,
      );
      
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception("Server returned unexpected status code: ${response.statusCode}");
      }
    } on DioException catch (e) {
      String? serverMessage;
      
      // Safely check if data is an extraction-ready Map before accessing fields
      if (e.response?.data is Map<String, dynamic>) {
        serverMessage = e.response?.data['message']?.toString();
      }
      
      // Fallback chain to standard error messages
      serverMessage ??= e.message;
      throw Exception(serverMessage ?? "Failed to submit purchase transaction.");
    }
  }

  /// Cancels or deletes a purchase item by its primary database entry ID
  Future<void> deletePurchase(String id) async {
    try {
      final response = await dio.delete("/purchases/$id");
      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception("Server rejected delete execution flag.");
      }
    } on DioException catch (e) {
      throw Exception(e.message ?? "Failed to delete target purchase log.");
    }
  }
}