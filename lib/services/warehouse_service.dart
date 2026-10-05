import 'package:dio/dio.dart';
import '../models/warehouse_model.dart';
import '../config/api_config.dart';

class WarehouseService {
  final Dio dio = ApiConfig.dio;

  // Since ApiConfig.dio already has baseUrl configured, use relative paths to avoid duplicating the URL string
  final String relativeUrl = "/warehouses";

  Future<List<Warehouse>> getWarehouses() async {
    try {
      final response = await dio.get(relativeUrl);

      print("WAREHOUSES RESPONSE:");
      print(response.data);

      final dynamic responseData = response.data;
      List<dynamic> rawList = [];

      // Unpack standardized backend "data" envelope safely
      if (responseData is Map<String, dynamic> && responseData.containsKey("data")) {
        rawList = responseData["data"] is List ? responseData["data"] : [];
      } else if (responseData is List) {
        rawList = responseData;
      }

      return rawList.map((json) => Warehouse.fromJson(json)).toList();
    } on DioException catch (e) {
      print("GET WAREHOUSES DIO ERROR: ${e.response?.data ?? e.message}");
      rethrow;
    } catch (e) {
      print("GET WAREHOUSES PARSING ERROR: $e");
      rethrow;
    }
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
    try {
      final response = await dio.post(
        relativeUrl,
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
      print("WAREHOUSE CREATED:");
      print(response.data);
    } catch (e) {
      print("CREATE WAREHOUSE ERROR: $e");
      rethrow;
    }
  }

  Future<void> updateWarehouse({
    required String id, // Added mandatory ID parameter to fix the original endpoint bug
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
    try {
      // Switched from POST to PUT and added target item ID resource path identifier
      final response = await dio.put(
        "$relativeUrl/$id",
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
      print("WAREHOUSE UPDATED:");
      print(response.data);
    } catch (e) {
      print("UPDATE WAREHOUSE ERROR: $e");
      rethrow;
    }
  }

  Future<void> deleteWarehouse(String id) async {
    try {
      await dio.delete("$relativeUrl/$id");
    } catch (e) {
      print("DELETE WAREHOUSE ERROR: $e");
      rethrow;
    }
  }
}