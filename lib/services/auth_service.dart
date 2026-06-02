import 'package:dio/dio.dart';

class AuthService {
  final Dio dio = Dio();

  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {

  print("EMAIL: $email");
print("PASSWORD: $password");

final response = await dio.post(
  "http://10.0.2.2:5000/api/auth/login",
  data: {
    "email": email.trim(),
    "password": password,
  },
);

print(response.data);

    return response.data;
  }
}