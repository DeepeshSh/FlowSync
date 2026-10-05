import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/invoice_model.dart';
import '../utils/api_constants.dart';

import 'notification_service.dart';

class InvoiceService {
  final Dio dio;

  InvoiceService({Dio? dio}) : dio = dio ?? ApiConfig.dio;

  // FETCH ALL INVOICES WITH OPTIONAL FILTERS
  Future<List<Invoice>> getInvoices({String? type, String? paymentStatus}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (type != null && type.isNotEmpty && type != 'ALL') {
        queryParams['type'] = type.toUpperCase();
      }
      if (paymentStatus != null && paymentStatus.isNotEmpty) {
        queryParams['paymentStatus'] = paymentStatus.toUpperCase();
      }

      final response = await dio.get(
        ApiConstants.invoices,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        options: Options(
          sendTimeout: const Duration(seconds: 3),
          receiveTimeout: const Duration(seconds: 3),
        ),
      ).timeout(const Duration(seconds: 3));

      final data = response.data;
      if (data is Map<String, dynamic> && data.containsKey('invoices')) {
        final list = data['invoices'] as List? ?? [];
        return list.map((item) => Invoice.fromJson(item as Map<String, dynamic>)).toList();
      } else if (data is List) {
        return data.map((item) => Invoice.fromJson(item as Map<String, dynamic>)).toList();
      }
      return [];
    } on DioException catch (_) {
      return [];
    } catch (_) {
      return [];
    }
  }

  // GET SINGLE INVOICE
  Future<Invoice?> getInvoiceById(String id) async {
    if (id.isEmpty) return null;
    try {
      final response = await dio.get(
        '${ApiConstants.invoices}/$id',
        options: Options(
          sendTimeout: const Duration(seconds: 3),
          receiveTimeout: const Duration(seconds: 3),
        ),
      ).timeout(const Duration(seconds: 3));

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final invoiceJson = data['invoice'] ?? data;
        if (invoiceJson is Map<String, dynamic>) {
          return Invoice.fromJson(invoiceJson);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // CREATE INVOICE
  Future<Invoice> createInvoice(Map<String, dynamic> data) async {
    try {
      final response = await dio.post(
        ApiConstants.invoices,
        data: data,
        options: Options(
          sendTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
        ),
      ).timeout(const Duration(seconds: 4));

      final resData = response.data;
      Invoice invoice;
      if (resData is Map<String, dynamic>) {
        final invoiceJson = resData['invoice'] ?? resData;
        if (invoiceJson is Map<String, dynamic>) {
          invoice = Invoice.fromJson(invoiceJson);
        } else {
          invoice = Invoice.fromJson(data);
        }
      } else {
        invoice = Invoice.fromJson(data);
      }

      NotificationService().showAuditNotification(
        title: invoice.isSale ? "Sales Invoice Created" : "Purchase Bill Created",
        body: "${invoice.invoiceNumber} for ${invoice.partyName} (₹${invoice.grandTotal.toStringAsFixed(2)})",
      );

      return invoice;
    } on DioException catch (e) {
      final errorMsg = e.response?.data is Map && e.response?.data['message'] != null
          ? e.response?.data['message']
          : (e.message ?? 'Failed to create invoice');
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Failed to create invoice: $e');
    }
  }
}
