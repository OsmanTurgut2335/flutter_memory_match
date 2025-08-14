import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mem_game/core/providers/dio_provider.dart';
import 'package:mem_game/core/providers/env_provider.dart';
import 'package:mem_game/core/services/health_service.dart';

final healthServiceProvider = Provider<HealthService>((ref) {
  final dio = ref.read(dioProvider);
  final baseUrl = ref.read(envConfigProvider).baseUrl;

  return HealthService(dio,baseUrl);
});
