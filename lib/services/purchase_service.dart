import 'package:dio/dio.dart';

import '../models/purchase_model.dart';

class PurchaseService {
  final Dio dio = Dio(BaseOptions(baseUrl: "http://10.0.2.2:5000/api"));

  Future<List<Purchase>> getPurchases() async {
    final response = await dio.get("/purchases");

    return (response.data as List).map((e) => Purchase.fromJson(e)).toList();
  }

  Future<void> createPurchase({
  required String purchaseNumber,
  required String supplierName,
  required List<dynamic> items,
  required double totalAmount,
  required String paymentStatus,
}) async {

  await dio.post(
    "/purchases",

    data: {
      "purchaseNumber": purchaseNumber,

      "supplierName": supplierName,

      "items": items,

      "totalAmount": totalAmount,

      "paymentStatus": paymentStatus,
    },
  );
}
    

  Future<void> deletePurchase(String id) async {
    await dio.delete("/purchases/$id");
  }
}
