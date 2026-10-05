import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/party_model.dart';
import '../utils/api_constants.dart';

class PartyService {
  final Dio dio;

  PartyService({Dio? dio}) : dio = dio ?? ApiConfig.dio;

  // FETCH ALL PARTIES (WITH OPTIONAL TYPE & SEARCH)
  Future<List<Party>> getParties({String? type, String? search}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (type != null && type.isNotEmpty && type != 'ALL') {
        queryParams['type'] = type.toUpperCase();
      }
      if (search != null && search.trim().isNotEmpty) {
        queryParams['search'] = search.trim();
      }

      final response = await dio.get(
        ApiConstants.parties,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        options: Options(
          sendTimeout: const Duration(seconds: 3),
          receiveTimeout: const Duration(seconds: 3),
        ),
      ).timeout(const Duration(seconds: 3));

      final data = response.data;
      if (data is Map<String, dynamic> && data.containsKey('parties')) {
        final list = data['parties'] as List? ?? [];
        return list.map((item) => Party.fromJson(item as Map<String, dynamic>)).toList();
      } else if (data is List) {
        return data.map((item) => Party.fromJson(item as Map<String, dynamic>)).toList();
      }
      return [];
    } on DioException catch (_) {
      return [];
    } catch (_) {
      return [];
    }
  }

  // GET PARTY BY ID
  Future<Party?> getPartyById(String id) async {
    if (id.isEmpty) return null;
    try {
      final response = await dio.get(
        '${ApiConstants.parties}/$id',
        options: Options(
          sendTimeout: const Duration(seconds: 3),
          receiveTimeout: const Duration(seconds: 3),
        ),
      ).timeout(const Duration(seconds: 3));

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final partyJson = data['party'] ?? data;
        if (partyJson is Map<String, dynamic>) {
          return Party.fromJson(partyJson);
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // CREATE PARTY
  Future<Party> createParty(Party party) async {
    try {
      final response = await dio.post(
        ApiConstants.parties,
        data: party.toJson(),
        options: Options(
          sendTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
        ),
      ).timeout(const Duration(seconds: 4));

      final data = response.data;
      if (data is Map<String, dynamic>) {
        final partyJson = data['party'] ?? data;
        if (partyJson is Map<String, dynamic>) {
          return Party.fromJson(partyJson);
        }
      }
      return party;
    } on DioException catch (e) {
      final errorMsg = e.response?.data is Map && e.response?.data['message'] != null
          ? e.response?.data['message']
          : (e.message ?? 'Failed to create party');
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Failed to create party: $e');
    }
  }

  // UPDATE PARTY
  Future<Party?> updateParty(String id, Map<String, dynamic> data) async {
    try {
      final response = await dio.put(
        '${ApiConstants.parties}/$id',
        data: data,
        options: Options(
          sendTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
        ),
      ).timeout(const Duration(seconds: 4));

      final resData = response.data;
      if (resData is Map<String, dynamic>) {
        final partyJson = resData['party'] ?? resData;
        if (partyJson is Map<String, dynamic>) {
          return Party.fromJson(partyJson);
        }
      }
      return null;
    } on DioException catch (e) {
      final errorMsg = e.response?.data is Map && e.response?.data['message'] != null
          ? e.response?.data['message']
          : (e.message ?? 'Failed to update party');
      throw Exception(errorMsg);
    } catch (e) {
      throw Exception('Failed to update party: $e');
    }
  }

  // DELETE PARTY
  Future<bool> deleteParty(String id) async {
    try {
      final response = await dio.delete(
        '${ApiConstants.parties}/$id',
        options: Options(
          sendTimeout: const Duration(seconds: 4),
          receiveTimeout: const Duration(seconds: 4),
        ),
      ).timeout(const Duration(seconds: 4));

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Failed to delete party: $e');
    }
  }
}
