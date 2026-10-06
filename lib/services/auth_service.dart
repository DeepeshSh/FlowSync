import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user.dart';
import '../utils/api_constants.dart';

class AuthService {
  static const String _tokenKey = "auth_token";
  static const String _userKey = "auth_user";

  dynamic _safeJsonDecode(String source) {
    try {
      return jsonDecode(source);
    } catch (_) {
      return null;
    }
  }

  static String formatAuthError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return "No user found with this email.";
        case 'wrong-password':
        case 'invalid-credential':
          return "Incorrect password. Please try again.";
        case 'email-already-in-use':
          return "An account already exists with this email.";
        case 'weak-password':
          return "Password should be at least 6 characters.";
        case 'invalid-email':
          return "Please enter a valid email address.";
        case 'server-sleeping':
          return error.message ?? "Server is waking up. Please try again in a few moments.";
        case 'network-request-failed':
          return error.message ?? "Connection error. Please check your internet or server status.";
        default:
          return error.message ?? "Authentication failed.";
      }
    }

    final raw = error.toString().toLowerCase();
    if (raw.contains('user-not-found') || raw.contains('invalid email') || raw.contains('no user found')) {
      return "No user found with this email.";
    }
    if (raw.contains('wrong-password') || raw.contains('invalid-credential') || raw.contains('invalid password')) {
      return "Incorrect password. Please try again.";
    }
    if (raw.contains('email-already-in-use') || raw.contains('email already exists')) {
      return "An account already exists with this email.";
    }
    if (raw.contains('weak-password') || raw.contains('at least 6 characters')) {
      return "Password should be at least 6 characters.";
    }
    if (raw.contains('invalid-email') || raw.contains('valid email')) {
      return "Please enter a valid email address.";
    }

    return error.toString();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> isUserLoggedIn() async {
    try {
      final token = await getToken();
      final user = await getCachedUser();
      return token != null && token.isNotEmpty && user != null;
    } catch (_) {
      return false;
    }
  }

  Future<AppUser> register({
    required String name,
    required String businessName,
    required String email,
    required String password,
    String? phone,
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    if (cleanEmail.isEmpty || !cleanEmail.contains('@')) {
      throw FirebaseAuthException(
        code: 'invalid-email',
        message: "Please enter a valid email address.",
      );
    }

    if (password.length < 6) {
      throw FirebaseAuthException(
        code: 'weak-password',
        message: "Password should be at least 6 characters.",
      );
    }

    try {
      final response = await http
          .post(
            Uri.parse("${ApiConstants.auth}/register"),
            headers: {
              "Content-Type": "application/json",
            },
            body: jsonEncode({
              "name": name.trim(),
              "businessName": businessName.trim(),
              "email": cleanEmail,
              "password": password,
              if (phone != null && phone.trim().isNotEmpty) "phone": phone.trim(),
            }),
          )
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () {
              throw FirebaseAuthException(
                code: 'server-sleeping',
                message: "Render server is booting up. Please wait 30 seconds and retry.",
              );
            },
          );

      final body = _safeJsonDecode(response.body);

      if (response.statusCode != 201 && response.statusCode != 200) {
        final message = (body is Map && body["message"] != null)
            ? body["message"].toString()
            : "Registration Failed (Status ${response.statusCode})";

        if (message.toLowerCase().contains("already exists")) {
          throw FirebaseAuthException(
            code: 'email-already-in-use',
            message: "An account already exists with this email.",
          );
        }

        throw FirebaseAuthException(
          code: 'unknown',
          message: message,
        );
      }

      return await login(email: cleanEmail, password: password);
    } on FirebaseAuthException {
      rethrow;
    } on SocketException catch (e) {
      throw FirebaseAuthException(
        code: 'network-request-failed',
        message: "Cannot reach backend: ${e.message}",
      );
    } on TimeoutException {
      throw FirebaseAuthException(
        code: 'server-sleeping',
        message: "Connection timed out. Server may be spinning up.",
      );
    } catch (e) {
      throw FirebaseAuthException(
        code: 'network-request-failed',
        message: "Error connecting to server: $e",
      );
    }
  }

  Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim().toLowerCase();

    if (cleanEmail.isEmpty || !cleanEmail.contains('@')) {
      throw FirebaseAuthException(
        code: 'invalid-email',
        message: "Please enter a valid email address.",
      );
    }

    try {
      final response = await http
          .post(
            Uri.parse("${ApiConstants.auth}/login"),
            headers: {
              "Content-Type": "application/json",
            },
            body: jsonEncode({
              "email": cleanEmail,
              "password": password,
            }),
          )
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () {
              throw FirebaseAuthException(
                code: 'server-sleeping',
                message: "Backend server is waking up. Please wait 30 seconds and try again.",
              );
            },
          );

      final body = _safeJsonDecode(response.body);

      if (response.statusCode == 200 && body is Map<String, dynamic>) {
        final token = body["token"]?.toString() ?? "";
        final userData = body["user"] ?? body["data"];

        if (userData != null && userData is Map<String, dynamic>) {
          final user = AppUser.fromJson(userData);
          await saveSession(token, user);
          return user;
        }
      }

      final message = (body is Map && body["message"] != null)
          ? body["message"].toString()
          : "Login Failed (Status ${response.statusCode})";

      final lowerMsg = message.toLowerCase();
      if (lowerMsg.contains("invalid email") || response.statusCode == 404) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: "No user found with this email.",
        );
      } else if (lowerMsg.contains("invalid password")) {
        throw FirebaseAuthException(
          code: 'wrong-password',
          message: "Incorrect password. Please try again.",
        );
      }

      throw FirebaseAuthException(
        code: 'invalid-credential',
        message: message,
      );
    } on FirebaseAuthException {
      rethrow;
    } on SocketException catch (e) {
      throw FirebaseAuthException(
        code: 'network-request-failed',
        message: "Network unreachable: ${e.message}",
      );
    } on TimeoutException {
      throw FirebaseAuthException(
        code: 'server-sleeping',
        message: "Connection timed out. Server is waking up, please retry in 30 seconds.",
      );
    } catch (e) {
      throw FirebaseAuthException(
        code: 'network-request-failed',
        message: "Connection failed: $e",
      );
    }
  }

  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveSession(String token, AppUser user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_tokenKey, token);
      await prefs.setString('token', token);
      await prefs.setString(_userKey, jsonEncode(user.toJson()));
      await prefs.setString('user_email', user.email);
    } catch (_) {}
  }

  Future<void> clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove('token');
      await prefs.remove(_userKey);
      await prefs.remove('user_email');
      try {
        await FirebaseAuth.instance.signOut();
        await GoogleSignIn().signOut();
      } catch (_) {}
    } catch (_) {}
  }

  Future<void> logout() async {
    await clearSession();
  }

  Future<AppUser?> getCachedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_userKey);
      if (raw == null || raw.isEmpty) return null;

      final decoded = _safeJsonDecode(raw);
      if (decoded != null && decoded is Map<String, dynamic>) {
        return AppUser.fromJson(decoded);
      }
    } catch (_) {}
    return null;
  }

  Future<AppUser?> fetchCurrentUser() async {
    final token = await getToken();
    if (token == null || token.isEmpty) return getCachedUser();

    try {
      final response = await http
          .get(
            Uri.parse("${ApiConstants.auth}/me"),
            headers: {"Authorization": "Bearer $token"},
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final body = _safeJsonDecode(response.body);
        if (body is Map<String, dynamic>) {
          final userData = body["data"] ?? body["user"];
          if (userData != null && userData is Map<String, dynamic>) {
            final user = AppUser.fromJson(userData);
            await saveSession(token, user);
            return user;
          }
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        await clearSession();
        return null;
      }
    } catch (_) {}

    return getCachedUser();
  }

  // ===========================
  // SIGN IN WITH GOOGLE (SYNCED WITH BACKEND)
  // ===========================

  Future<AppUser?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();

      // Clear previous cached session so account selection dialog opens every time
      await googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      // Sync user with Node backend /api/auth/google
      final response = await http
          .post(
            Uri.parse("${ApiConstants.auth}/google"),
            headers: {"Content-Type": "application/json"},
            body: jsonEncode({
              "email": googleUser.email.trim().toLowerCase(),
              "name": googleUser.displayName ?? "Google User",
            }),
          )
          .timeout(
            const Duration(seconds: 60),
            onTimeout: () {
              throw FirebaseAuthException(
                code: 'server-sleeping',
                message: "Backend server is waking up. Please wait 30 seconds and try again.",
              );
            },
          );

      final body = _safeJsonDecode(response.body);

      if (response.statusCode == 200 && body is Map<String, dynamic>) {
        final token = body["token"]?.toString() ?? "";
        final userData = body["user"] ?? body["data"];

        if (userData != null && userData is Map<String, dynamic>) {
          final appUser = AppUser.fromJson(userData);
          await saveSession(token, appUser);
          return appUser;
        }
      }

      throw FirebaseAuthException(
        code: 'google-sync-failed',
        message: "Failed to authenticate with backend: Status ${response.statusCode}",
      );
    } on FirebaseAuthException {
      rethrow;
    } on SocketException catch (e) {
      throw FirebaseAuthException(
        code: 'network-request-failed',
        message: "Cannot reach backend: ${e.message}",
      );
    } catch (e) {
      throw FirebaseAuthException(
        code: 'unknown',
        message: "Google Sign-In failed: $e",
      );
    }
  }
}