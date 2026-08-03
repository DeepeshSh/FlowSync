import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/sale_model.dart';

class SaleService {
  final Dio dio = Dio(BaseOptions(baseUrl: "${ApiConfig.baseUrl}"));

  Future<List<Sale>> getSales() async {
    final response = await dio.get("/sales");

    return (response.data as List).map((e) => Sale.fromJson(e)).toList();
  }

  Future<void> createSale({
    required String saleNumber,
    required String customerName,
    required List<dynamic>
    items, // Fixed: Changed from List<Map<String, dynamic>> to List<dynamic> to prevent Dart runtime type crashes
    required double totalAmount,
    required String paymentStatus,
  }) async {
    // Map the Flutter UI keys safely to match what your Mongoose Schema expects
    final normalizedItems = items.map((item) {
      // Safely cast the dynamic item element into a Map interface
      final Map<dynamic, dynamic> itemMap = item as Map;
      return {
        "productId": itemMap["productId"],
        "productName": itemMap["productName"],
        "quantity": itemMap["quantity"],
        "sellingPrice":
            itemMap["rate"] ??
            itemMap["sellingPrice"] ??
            0.0, // Maps 'rate' -> 'sellingPrice'
        "total":
            itemMap["amount"] ??
            itemMap["total"] ??
            0.0, // Maps 'amount' -> 'total'
      };
    }).toList();

    final body = {
      "saleNumber": saleNumber,
      "customerName": customerName,
      "items": normalizedItems,
      "totalAmount": totalAmount,
      "paymentStatus": paymentStatus,
    };

    print("REQUEST BODY:");
    print(body);

    Future<void> deleteSale(String id) async {
      await dio.delete("/sales/$id");
    }
  }
}
