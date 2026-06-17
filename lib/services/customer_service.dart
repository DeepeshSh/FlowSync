import 'package:dio/dio.dart';

import '../models/customer_model.dart';

class CustomerService {

  final Dio dio = Dio(
    BaseOptions(
      baseUrl:
          "http://10.0.2.2:5000/api",
    ),
  );

  Future<List<Customer>>
      getCustomers() async {

    final response =
        await dio.get(
      "/customers",
    );

    return (response.data as List)
        .map(
          (e) => Customer.fromJson(e),
        )
        .toList();
  }

  Future<void> createCustomer({
    required String customerName,
    required String contactPerson,
    required String phone,
    required String email,
    required String gstNumber,
    required String address,
    required String city,
    required String state,
    required String pincode,
    required double creditLimit,
    required double openingBalance,
  }) async {

    await dio.post(
      "/customers",

      data: {
        "customerName":
            customerName,

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

        "pincode":
            pincode,

        "creditLimit":
            creditLimit,

        "openingBalance":
            openingBalance,
      },
    );
  }

  Future<void> deleteCustomer(
    String id,
  ) async {

    await dio.delete(
      "/customers/$id",
    );
  }
Future<void> updateCustomer({
  required String id,
  required String customerName,
  required String contactPerson,
  required String phone,
  required String email,
  required String gstNumber,
  required String address,
  required String city,
  required String state,
  required String pincode,
  required double creditLimit,
  required double openingBalance,
  required bool isActive,
}) async {

  await dio.put(
    "/customers/$id",

    data: {
      "customerName": customerName,
      "contactPerson": contactPerson,
      "phone": phone,
      "email": email,
      "gstNumber": gstNumber,
      "address": address,
      "city": city,
      "state": state,
      "pincode": pincode,
      "creditLimit": creditLimit,
      "openingBalance": openingBalance,
      "isActive": isActive,
    },
  );
}
}