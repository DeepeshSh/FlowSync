import 'package:dio/dio.dart';
import '../config/api_config.dart';

class AuthService {
  final Dio dio = Dio();


Future<Map<String, dynamic>> register({
  required String name,
  required String businessName,
  required String email,
  required String password,
}) async {

  final response = await dio.post(
    "${ApiConfig.baseUrl}/auth/register",

    data: {
      "name": name,
      "businessName": businessName,
      "email": email,
      "password": password,
    },
  );

  return response.data;
}


  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {

  print("EMAIL: $email");
print("PASSWORD: $password");

final response = await dio.post(
  "${ApiConfig.baseUrl}/auth/login",
  data: {
    "email": email.trim(),
    "password": password,
  },
);

print(response.data);

    return response.data;
  }
}