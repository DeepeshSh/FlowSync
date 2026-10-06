// lib/config/api_config.dart
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../utils/api_constants.dart';

class ApiConfig {
  static const String baseUrl = ApiConstants.baseUrl;

  static final Dio dio = _createDio();

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 45), // Allows Render to wake up
        receiveTimeout: const Duration(seconds: 45),
        sendTimeout: const Duration(seconds: 45),
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final prefs = await SharedPreferences.getInstance();
            final token = prefs.getString("auth_token") ?? prefs.getString("token");
            if (token != null && token.isNotEmpty) {
              options.headers["Authorization"] = "Bearer $token";
            }
          } catch (_) {}
          return handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401) {
            try {
              final prefs = await SharedPreferences.getInstance();
              await prefs.remove("auth_token");
              await prefs.remove("token");
              await prefs.remove("user_data");
              await prefs.remove("user_email");
            } catch (_) {}
          }
          return handler.next(error);
        },
      ),
    );

    return dio;
  }
}