import 'dart:convert';
import 'package:http/http.dart' as http;

import 'package:dio/dio.dart';
import '../models/dashboard_summary.dart';
import '/config/api_config.dart';
class DashboardService {

final Dio dio = Dio();

Future<DashboardSummary>
getDashboardSummary() async {

final response =
await dio.get(
"${ApiConfig.baseUrl}/dashboard/summary",
);

return DashboardSummary.fromJson(
response.data["data"],
);

}

}