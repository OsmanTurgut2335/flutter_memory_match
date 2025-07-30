import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mem_game/core/network/token_interceptor.dart';
import 'package:mem_game/core/providers/env_provider.dart';

final dioProvider = Provider<Dio>((ref) {
  final env = ref.read(envConfigProvider);
  final dio = Dio(
    BaseOptions(
      baseUrl: env.baseUrl, 
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
      contentType:   'application/json',
    ),
  );
  dio.interceptors.add(TokenInterceptor(dio: dio, baseUrl: env.baseUrl, apiKey: env.apiKey));

  return dio;
});
