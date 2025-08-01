import 'dart:async';

import 'package:dio/dio.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mem_game/core/error/app_exceptions.dart';
import 'package:mem_game/core/error/dio_exception_mapper.dart';
import 'package:mem_game/core/providers/dio_provider.dart';
import 'package:mem_game/core/providers/env_provider.dart';

import 'package:mem_game/data/score/model.dart';

class ScoreboardRepository {
  ScoreboardRepository(this.ref);

  final Ref ref;
  Dio get _dio => ref.read(dioProvider);

  Future<void> saveScore(Score score) async {
    final response = await _dio.post('/entry', data: score.toJson());
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to save score');
    }
  }

  Future<List<Score>> fetchSortedScores() async {
    final baseUrl = ref.read(envConfigProvider).baseUrl;

    try {
      final response = await _dio.get('$baseUrl/leaderboard/top', options: Options(extra: {'auth': false}));

      final data = response.data as List<dynamic>;
      return data.map((json) => Score.fromJson(json as Map<String, dynamic>)).toList();
    } on DioException catch (e) {
      throw AppExceptionMapper.fromDioException(e);
    } catch (e) {
      throw const UnknownException();
    }
  }

  Future<Score?> fetchUserWithRank(String username) async {
    final baseUrl = ref.read(envConfigProvider).baseUrl;
    try {
      final response = await _dio.get(
        '$baseUrl/leaderboard/position/$username',
        options: Options(extra: {'auth': false}),
      );

      return Score.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      } else {
        rethrow;
      }
    }
  }
}
