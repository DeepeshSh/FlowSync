import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../utils/api_constants.dart';
import 'notification_service.dart';

class MovementService {
  final Dio dio;

  MovementService({Dio? dio}) : dio = dio ?? ApiConfig.dio;

  /// Records an inventory movement (STOCK_IN, STOCK_OUT, DAMAGE, RETURN, ADJUSTMENT)
  Future<Map<String, dynamic>> recordMovement({
    required String productId,
    required String type,
    required int quantity,
    String? productName,
    String? reason,
    String? reference,
  }) async {
    try {
      final response = await dio.post(
        ApiConstants.movements,
        data: {
          'productId': productId,
          'type': type,
          'quantity': quantity,
          if (reason != null && reason.trim().isNotEmpty) 'reason': reason.trim(),
          if (reference != null && reference.trim().isNotEmpty) 'reference': reference.trim(),
        },
        options: Options(
          sendTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
        ),
      ).timeout(const Duration(seconds: 4));

      final Map<String, dynamic> result = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : {'success': true, 'data': response.data};

      final updatedStockRaw = result['updatedStock'];
      final int? updatedStock = updatedStockRaw is int
          ? updatedStockRaw
          : (updatedStockRaw as num?)?.toInt();

      if (type == 'DAMAGE') {
        NotificationService().showAuditNotification(
          title: "Damage Incident Logged",
          body: "$quantity units of ${productName ?? 'Item'} logged: ${reason ?? 'Physical damage'}",
        );
      } else if (type == 'STOCK_IN') {
        NotificationService().showAuditNotification(
          title: "Stock Inward Logged",
          body: "+$quantity units received for ${productName ?? 'Item'}.",
        );
      } else if (type == 'STOCK_OUT') {
        NotificationService().showAuditNotification(
          title: "Stock Outward Dispatched",
          body: "-$quantity units dispatched for ${productName ?? 'Item'}.",
        );
      }

      if ((type == 'STOCK_OUT' || type == 'DAMAGE') &&
          updatedStock != null &&
          updatedStock < 10 &&
          productName != null &&
          productName.isNotEmpty) {
        NotificationService().showLowStockAlert(
          productName: productName,
          remainingStock: updatedStock,
        );
      }

      return result;
    } on DioException catch (e) {
      final errorMsg = e.response?.data is Map && e.response?.data['message'] != null
          ? e.response?.data['message']
          : (e.message ?? 'Network error recording movement');
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Failed to record movement: $e');
    }
  }

  /// Fetches movement audit ledger history for a product sorted by timestamp descending
  Future<List<dynamic>> getProductMovements(String productId) async {
    if (productId.isEmpty) return [];
    try {
      final response = await dio.get(
        '${ApiConstants.movements}/product/$productId',
        options: Options(
          sendTimeout: const Duration(seconds: 2),
          receiveTimeout: const Duration(seconds: 2),
        ),
      ).timeout(const Duration(seconds: 2));

      final data = response.data;
      if (data is Map<String, dynamic> && data.containsKey('movements')) {
        return data['movements'] as List<dynamic>;
      } else if (data is List) {
        return data;
      }
      return [];
    } on DioException catch (_) {
      // In offline / test mode, return empty list gracefully
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Fetches all inventory movements / master logs
  Future<List<dynamic>> getAllMovements({int limit = 100}) async {
    try {
      final response = await dio.get(
        ApiConstants.allMovements,
        queryParameters: {'limit': limit},
        options: Options(
          sendTimeout: const Duration(seconds: 3),
          receiveTimeout: const Duration(seconds: 3),
        ),
      ).timeout(const Duration(seconds: 3));

      final data = response.data;
      if (data is Map<String, dynamic> && data.containsKey('movements')) {
        return data['movements'] as List<dynamic>;
      } else if (data is List) {
        return data;
      }
      return [];
    } on DioException catch (_) {
      return [];
    } catch (_) {
      return [];
    }
  }

  /// Fetches all damaged products movements
  Future<List<dynamic>> getDamagedProducts({int limit = 100}) async {
    try {
      final response = await dio.get(
        ApiConstants.damagedMovements,
        queryParameters: {'limit': limit},
        options: Options(
          sendTimeout: const Duration(seconds: 3),
          receiveTimeout: const Duration(seconds: 3),
        ),
      ).timeout(const Duration(seconds: 3));

      final data = response.data;
      if (data is Map<String, dynamic> && data.containsKey('movements')) {
        return data['movements'] as List<dynamic>;
      } else if (data is List) {
        return data;
      }
      return [];
    } on DioException catch (_) {
      return [];
    } catch (_) {
      return [];
    }
  }
}
