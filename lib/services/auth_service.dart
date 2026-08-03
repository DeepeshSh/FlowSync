import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../config/api_config.dart';
import '../models/app_user.dart';

class AuthService {
  static const String _tokenKey = "auth_token";
  static const String _userKey = "auth_user";

  // ===========================
  // REGISTER
  // ===========================

  Future<void> register({
    required String name,
    required String businessName,
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/auth/register"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "name": name,
        "businessName": businessName,
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode != 201) {
      final body = jsonDecode(response.body);

      throw Exception(
        body["message"] ?? "Registration Failed",
      );
    }
  }

  // ===========================
  // LOGIN
  // ===========================

  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse("${ApiConfig.baseUrl}/auth/login"),
      headers: {
        "Content-Type": "application/json",
      },
      body: jsonEncode({
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      final token = body["token"];

      final user = AppUser.fromJson(
        body["user"],
      );

      await saveSession(
        token,
        user,
      );

      return user;
    }

    final body = jsonDecode(response.body);

    throw Exception(
      body["message"] ?? "Login Failed",
    );
  }

  // ===========================
  // TOKEN
  // ===========================

  Future<String?> getToken() async {
    final prefs =
        await SharedPreferences.getInstance();

    return prefs.getString(_tokenKey);
  }

  // ===========================
  // SAVE SESSION
  // ===========================

  Future<void> saveSession(
    String token,
    AppUser user,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(
      _tokenKey,
      token,
    );

    await prefs.setString(
      _userKey,
      jsonEncode(user.toJson()),
    );
  }

  // ===========================
  // LOGOUT
  // ===========================

  Future<void> clearSession() async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }

  // ===========================
  // CACHED USER
  // ===========================

  Future<AppUser?> getCachedUser() async {
    final prefs =
        await SharedPreferences.getInstance();

    final raw =
        prefs.getString(_userKey);

    if (raw == null) {
      return null;
    }

    try {
      return AppUser.fromJson(
        jsonDecode(raw),
      );
    } catch (_) {
      return null;
    }
  }

  // ===========================
  // GET CURRENT USER
  // ===========================

  Future<AppUser?> fetchCurrentUser() async {
    final token = await getToken();

    if (token == null) {
      return getCachedUser();
    }

    try {
      final response = await http.get(
        Uri.parse(
          "${ApiConfig.baseUrl}/auth/me",
        ),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final body =
            jsonDecode(response.body);

        final user = AppUser.fromJson(
          body["data"],
        );

        await saveSession(
          token,
          user,
        );

        return user;
      }
    } catch (_) {}

    return getCachedUser();
  }
}