import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/supplier_model.dart';

class SupplierService {
  final Dio dio = Dio(BaseOptions(baseUrl: ApiConfig.baseUrl));

  Future<List<Supplier>> getSuppliers() async {
    final response = await dio.get("/suppliers");
    return (response.data as List).map((e) => Supplier.fromJson(e)).toList();
  }

  Future<void> createSupplier({
    required String supplierName,
    required String companyName, // Added parameter based on screen requirements
    required String contactPerson,
    required String phone,
    required String email,
    required String gstNumber,
    required String address,
    required String city,
    required String state,
    required String pincode,
    required String paymentTerms,
    required double openingBalance,
  }) async {
    await dio.post(
      "/suppliers",
      data: {
        "supplierName": supplierName,
        "companyName": companyName, // Added to database body keys
        "contactPerson": contactPerson,
        "phone": phone,
        "email": email,
        "gstNumber": gstNumber,
        "address": address,
        "city": city,
        "state": state,
        "pincode": pincode,
        "paymentTerms": paymentTerms,
        "openingBalance": openingBalance,
        "isActive": true, // Default to active on creation
      },
    );
  }

  Future<void> deleteSupplier(String id) async {
    await dio.delete("/suppliers/$id");
  }

  Future<void> updateSupplier(Supplier supplier) async {
    await dio.put(
      "/suppliers/${supplier.id}",
      data: {
        "supplierName": supplier.name, // Fixed: Corrected case-sensitivity typo from 'Name' to 'name'
        "companyName": supplier.companyName, // Added to keep company info in sync on update
        "contactPerson": supplier.contactPerson,
        "phone": supplier.phone,
        "email": supplier.email,
        "gstNumber": supplier.gstNumber,
        "address": supplier.address,
        "city": supplier.city,
        "state": supplier.state,
        "pincode": supplier.pincode,
        "paymentTerms": supplier.paymentTerms,
        "openingBalance": supplier.openingBalance,
        "isActive": supplier.isActive,
      },
    );
  }
}