import 'package:dio/dio.dart';

import 'package:mem_game/core/network/safe_request.dart';

class HealthService {
  HealthService(this._dio, this._baseUrl);
  final Dio _dio;
  final String _baseUrl;

  Future<void> checkDatabaseHealth() async {
    await safeRequest(() async {
      final response = await _dio.get('$_baseUrl/health/db');
      return response;
    });
  }

  Future<void> checkBackendStatus() async {
    await safeRequest(() async {
      final response = await _dio.get('$_baseUrl/actuator/health', options: Options(extra: {'auth': false}));

      return response;
    });
  }
}
