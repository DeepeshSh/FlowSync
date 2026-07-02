import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/sale_model.dart';

class SaleService {

  final Dio dio = Dio(
    BaseOptions(
      baseUrl:
          "${ApiConfig.baseUrl}",
    ),
  );

  Future<List<Sale>>
      getSales() async {

    final response =
        await dio.get(
      "/sales",
    );

    return (response.data as List)
        .map(
          (e) => Sale.fromJson(e),
        )
        .toList();
  }
Future<void> createSale({
  required String saleNumber,
  required String customerName,
  required List<Map<String, dynamic>> items,
  required double totalAmount,
  required String paymentStatus,
}) async {

    await dio.post(
      "/sales",

      data: {
        "saleNumber":
            saleNumber,

        "customerName":
            customerName,

        "items": items,

        "totalAmount":
            totalAmount,

        "paymentStatus":
            paymentStatus,
      },
    );
  }

  Future<void> deleteSale(
    String id,
  ) async {

    await dio.delete(
      "/sales/$id",
    );
  }
}