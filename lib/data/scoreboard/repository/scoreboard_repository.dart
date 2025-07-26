import 'dart:async';

import 'package:dio/dio.dart';

import 'package:mem_game/data/score/model.dart';

class ScoreboardRepository {
  final _dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:8080/leaderboard',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 5),
    ),
  );

  Future<void> saveScore(Score score) async {
    final response = await _dio.post('/entry', data: score.toJson());
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Failed to save score');
    }
  }

  Future<List<Score>> fetchSortedScores() async {
    final response = await _dio.get('/top');
    final data = response.data as List<dynamic>;

    return data.map((json) => Score.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<void> deleteByUsername(String username) async {
    final response = await _dio.delete('/$username');
    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Failed to delete user');
    }
  }

  Future<Score> fetchScoreByUsername(String username) async {
    final response = await _dio.get('/$username');
    return Score.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Score?> fetchUserWithRank(String username) async {
    try {
      final response = await _dio.get('/position/$username');
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
