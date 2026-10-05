import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/dashboard_summary.dart';
import '/config/api_config.dart';

class DashboardService {
  static const String _cacheKey = "cached_dashboard_summary";

  final Dio dio = ApiConfig.dio;

  /// Loads cached dashboard summary instantly from local storage
  Future<DashboardSummary?> getCachedSummary() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final rawJson = prefs.getString(_cacheKey);
      if (rawJson != null && rawJson.isNotEmpty) {
        final decoded = jsonDecode(rawJson);
        return DashboardSummary.fromJson(decoded);
      }
    } catch (e) {
      print("CACHE READ ERROR IN DASHBOARD SERVICE: $e");
    }
    return null;
  }

  /// Fetches fresh dashboard summary from backend API and updates local cache
  Future<DashboardSummary> getDashboardSummary() async {
    try {
      final response = await dio.get(
        "${ApiConfig.baseUrl}/dashboard/summary",
      );

      final dynamic responseData = response.data;
      Map<String, dynamic> summaryData = {};

      if (responseData is Map<String, dynamic> && responseData.containsKey("data")) {
        summaryData = responseData["data"] ?? {};
      } else if (responseData is Map<String, dynamic>) {
        summaryData = responseData;
      }

      // Save fresh summary data to device cache
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_cacheKey, jsonEncode(summaryData));
      } catch (cacheError) {
        print("CACHE WRITE ERROR IN DASHBOARD SERVICE: $cacheError");
      }

      return DashboardSummary.fromJson(summaryData);
    } on DioException catch (e) {
      print("GET DASHBOARD SUMMARY ERROR: ${e.response?.data ?? e.message}");
      rethrow;
    } catch (e) {
      print("PARSING ERROR IN DASHBOARD SERVICE: $e");
      rethrow;
    }
  }
}