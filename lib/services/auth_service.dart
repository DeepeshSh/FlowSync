import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_user.dart';
import '../utils/api_constants.dart';



class AuthService {
  static const String _tokenKey = "auth_token";
  static const String _userKey = "auth_user";

  // Helper for safe JSON decoding
  dynamic _safeJsonDecode(String source) {
    try {
      return jsonDecode(source);
    } catch (_) {
      return null;
    }
  }

  /// Maps Firebase Auth codes and backend error patterns to user-friendly messages
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
        default:
          return error.message ?? "Authentication failed. Please check your connection.";
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

    return "Authentication failed. Please check your connection.";
  }

  // ===========================
  // PASSWORD RESET
  // ===========================

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email.trim());
    } catch (e) {
      rethrow;
    }
  }

  // ===========================
  // IS LOGGED IN CHECK
  // ===========================

  Future<bool> isUserLoggedIn() async {
    try {
      final token = await getToken();
      final user = await getCachedUser();
      return token != null && token.isNotEmpty && user != null;
    } catch (_) {
      return false;
    }
  }

  // ===========================
  // REGISTER
  // ===========================

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
      final response = await http.post(
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

      // Automatically authenticate session upon successful registration
      return await login(email: cleanEmail, password: password);
    } on FirebaseAuthException {
      rethrow;
    } catch (e) {
      throw FirebaseAuthException(
        code: 'network-request-failed',
        message: "Authentication failed. Please check your connection.",
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
    final cleanEmail = email.trim().toLowerCase();

    if (cleanEmail.isEmpty || !cleanEmail.contains('@')) {
      throw FirebaseAuthException(
        code: 'invalid-email',
        message: "Please enter a valid email address.",
      );
    }

    try {
      final response = await http.post(
        Uri.parse("${ApiConstants.auth}/login"),
        headers: {
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "email": cleanEmail,
          "password": password,
        }),
      );

      final body = _safeJsonDecode(response.body);

      if (response.statusCode == 200 && body is Map<String, dynamic>) {
        final token = body["token"]?.toString() ?? "";
        final userData = body["user"] ?? body["data"];

        if (userData != null && userData is Map<String, dynamic>) {
          final user = AppUser.fromJson(userData);

          await saveSession(
            token,
            user,
          );

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
    } catch (e) {
      throw FirebaseAuthException(
        code: 'network-request-failed',
        message: "Authentication failed. Please check your connection.",
      );
    }
  }

  // ===========================
  // TOKEN
  // ===========================

  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (_) {
      return null;
    }
  }

  // ===========================
  // SAVE SESSION
  // ===========================

  Future<void> saveSession(
    String token,
    AppUser user,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString(
        _tokenKey,
        token,
      );

      await prefs.setString(
        _userKey,
        jsonEncode(user.toJson()),
      );
    } catch (_) {}
  }

  // ===========================
  // LOGOUT / CLEAR
  // ===========================

  Future<void> clearSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await prefs.remove(_tokenKey);
      await prefs.remove(_userKey);
    } catch (_) {}
  }

  Future<void> logout() async {
    await clearSession();
  }

  // ===========================
  // CACHED USER
  // ===========================

  Future<AppUser?> getCachedUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final raw = prefs.getString(_userKey);

      if (raw == null || raw.isEmpty) {
        return null;
      }

      final decoded = _safeJsonDecode(raw);

      if (decoded != null && decoded is Map<String, dynamic>) {
        return AppUser.fromJson(decoded);
      }
    } catch (_) {}

    return null;
  }

  // ===========================
  // GET CURRENT USER
  // ===========================

  Future<AppUser?> fetchCurrentUser() async {
    final token = await getToken();

    if (token == null || token.isEmpty) {
      return getCachedUser();
    }

    try {
      final response = await http.get(
        Uri.parse(
          "${ApiConstants.auth}/me",
        ),
        headers: {
          "Authorization": "Bearer $token",
        },
      );

      if (response.statusCode == 200) {
        final body = _safeJsonDecode(response.body);

        if (body is Map<String, dynamic>) {
          final userData = body["data"] ?? body["user"];

          if (userData != null && userData is Map<String, dynamic>) {
            final user = AppUser.fromJson(userData);

            await saveSession(
              token,
              user,
            );

            return user;
          }
        }
      } else if (response.statusCode == 401 || response.statusCode == 403) {
        // Expired or invalid token -> clear stale session
        await clearSession();
        return null;
      }
    } catch (_) {}

    return getCachedUser();
  }

  // ===========================
  // SIGN IN WITH GOOGLE
  // ===========================

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);
      final String? idToken = await userCredential.user?.getIdToken();
      if (idToken != null) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', idToken);
        await prefs.setString('user_email', userCredential.user?.email ?? '');
      }
      return userCredential;
    } catch (e) {
      rethrow;
    }
  }
}