import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/app_user.dart';
import '../utils/api_constants.dart';
import 'auth_service.dart';

class ProfileService {
  final Dio dio = ApiConfig.dio;

  // GET PROFILE
  Future<Map<String, dynamic>> getProfile() async {
    try {
      final response = await dio.get(
        ApiConstants.profile,
        options: Options(
          sendTimeout: const Duration(seconds: 3),
          receiveTimeout: const Duration(seconds: 3),
        ),
      ).timeout(const Duration(seconds: 3));

      if (response.data is Map<String, dynamic>) {
        final data = response.data['data'] ?? response.data;
        if (data is Map<String, dynamic>) {
          return Map<String, dynamic>.from(data);
        }
      }
      return {};
    } catch (e) {
      rethrow;
    }
  }

  // UPDATE PERSONAL PROFILE (Name, Phone, Email)
  Future<Map<String, dynamic>> updatePersonalProfile(Map<String, dynamic> data) async {
    try {
      final response = await dio.put(
        ApiConstants.personalProfile,
        data: data,
        options: Options(
          sendTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
        ),
      ).timeout(const Duration(seconds: 4));

      if (response.data is Map<String, dynamic>) {
        final profileData = response.data['data'] ?? response.data;
        if (profileData is Map<String, dynamic>) {
          // Sync with local cached session
          try {
            final cached = await AuthService().getCachedUser();
            if (cached != null) {
              final updatedUser = AppUser(
                id: cached.id,
                name: data['name']?.toString() ?? cached.name,
                businessName: cached.businessName,
                email: data['email']?.toString() ?? cached.email,
                phone: data['phone']?.toString() ?? cached.phone,
                gstin: cached.gstin,
                address: cached.address,
              );
              final token = await AuthService().getToken();
              if (token != null) {
                await AuthService().saveSession(token, updatedUser);
              }
            }
          } catch (_) {}

          return Map<String, dynamic>.from(profileData);
        }
      }
      return {};
    } catch (e) {
      rethrow;
    }
  }

  // UPDATE BUSINESS PROFILE (Business Name, GSTIN, Trade Type, Address, Bank Details)
  Future<Map<String, dynamic>> updateBusinessProfile(Map<String, dynamic> data) async {
    try {
      final response = await dio.put(
        ApiConstants.businessProfile,
        data: data,
        options: Options(
          sendTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
        ),
      ).timeout(const Duration(seconds: 4));

      if (response.data is Map<String, dynamic>) {
        final profileData = response.data['data'] ?? response.data;
        if (profileData is Map<String, dynamic>) {
          // Sync with local cached session
          try {
            final cached = await AuthService().getCachedUser();
            if (cached != null) {
              final finalAddr = data['businessAddress']?.toString() ??
                  data['address']?.toString() ??
                  cached.address;

              final updatedUser = AppUser(
                id: cached.id,
                name: cached.name,
                businessName: data['businessName']?.toString() ?? cached.businessName,
                email: cached.email,
                phone: cached.phone,
                gstin: data['gstin']?.toString() ?? cached.gstin,
                address: finalAddr,
              );
              final token = await AuthService().getToken();
              if (token != null) {
                await AuthService().saveSession(token, updatedUser);
              }
            }
          } catch (_) {}

          return Map<String, dynamic>.from(profileData);
        }
      }
      return {};
    } catch (e) {
      rethrow;
    }
  }

  // UPDATE PROFILE (General / Legacy)
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await dio.put(
        ApiConstants.profile,
        data: data,
        options: Options(
          sendTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
        ),
      ).timeout(const Duration(seconds: 4));

      if (response.data is Map<String, dynamic>) {
        final profileData = response.data['data'] ?? response.data;
        if (profileData is Map<String, dynamic>) {
          // Sync with local cached session
          try {
            final cached = await AuthService().getCachedUser();
            if (cached != null) {
              final updatedUser = AppUser(
                id: cached.id,
                name: data['name']?.toString() ?? cached.name,
                businessName: data['businessName']?.toString() ?? cached.businessName,
                email: data['email']?.toString() ?? cached.email,
                phone: data['phone']?.toString() ?? cached.phone,
                gstin: data['gstin']?.toString() ?? cached.gstin,
                address: data['address']?.toString() ?? cached.address,
              );
              final token = await AuthService().getToken();
              if (token != null) {
                await AuthService().saveSession(token, updatedUser);
              }
            }
          } catch (_) {}

          return Map<String, dynamic>.from(profileData);
        }
      }
      return {};
    } catch (e) {
      rethrow;
    }
  }

  // DELETE ACCOUNT
  Future<bool> deleteAccount() async {
    try {
      final response = await dio.delete(
        ApiConstants.profile,
        options: Options(
          sendTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
        ),
      ).timeout(const Duration(seconds: 4));

      return response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }
}
