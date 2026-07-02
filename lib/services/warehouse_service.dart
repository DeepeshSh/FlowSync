import 'package:dio/dio.dart';
import '../models/warehouse_model.dart';
import '../config/api_config.dart';

class WarehouseService {
  final Dio dio = Dio();

  final String baseUrl =
      "${ApiConfig.baseUrl}/warehouses";

  Future<List<Warehouse>>
      getWarehouses() async {

    final response =
    await dio.get(baseUrl);

print(
  "WAREHOUSES RESPONSE:",
);

print(response.data);

    return (response.data as List)
        .map(
          (json) =>
              Warehouse.fromJson(json),
        )
        .toList();
  }

  Future<void> createWarehouse({
  required String name,
  required String code,
  required String address,
  required String city,
  required String contactPerson,
  required String phone,
  required String warehouseType,
  required String notes,
  bool isActive = true,
}) async {

final response =
    await dio.post(
  baseUrl,

    data: {
      "name": name,
      "code": code,
      "address": address,
      "city": city,
      "contactPerson": contactPerson,
      "phone": phone,
      "warehouseType": warehouseType,
      "isActive": isActive,
      "notes": notes,
    },
  );
  print(
  "WAREHOUSE CREATED:",
);

print(response.data);
}
  Future<void> updateWarehouse({
   
  required String name,
  required String code,
  required String address,
  required String city,
  required String contactPerson,
  required String phone,
  required String warehouseType,
  required String notes,
  bool isActive = true,
}) async {

  await dio.post(
    baseUrl,

    data: {
      "name": name,
      "code": code,
      "address": address,
      "city": city,
      "contactPerson": contactPerson,
      "phone": phone,
      "warehouseType": warehouseType,
      "isActive": isActive,
      "notes": notes,
    },
  );
}

  Future<void> deleteWarehouse(
    String id,
  ) async {

    await dio.delete(
      "$baseUrl/$id",
    );
  }
}