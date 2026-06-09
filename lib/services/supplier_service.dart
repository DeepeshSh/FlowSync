import 'package:dio/dio.dart';

import '../models/supplier_model.dart';

class SupplierService {
  final Dio dio = Dio(
    BaseOptions(
      baseUrl:
          "http://YOUR_IP:5000/api",
    ),
  );

  Future<List<Supplier>>
      getSuppliers() async {

    final response =
        await dio.get(
      "/suppliers",
    );

    return (response.data as List)
        .map(
          (e) =>
              Supplier.fromJson(e),
        )
        .toList();
  }

  Future<void> createSupplier({
    required String supplierName,
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
        "supplierName":
            supplierName,

        "contactPerson":
            contactPerson,

        "phone": phone,

        "email": email,

        "gstNumber":
            gstNumber,

        "address":
            address,

        "city": city,

        "state": state,

        "pincode": pincode,

        "paymentTerms":
            paymentTerms,

        "openingBalance":
            openingBalance,
      },
    );
  }

  Future<void> deleteSupplier(
    String id,
  ) async {

    await dio.delete(
      "/suppliers/$id",
    );
  }
}