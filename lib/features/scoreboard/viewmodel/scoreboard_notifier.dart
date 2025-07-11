import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mem_game/data/score/model.dart';
import 'package:mem_game/data/scoreboard/repository/scoreboard_repository.dart';

class ScoreboardNotifier extends StateNotifier<AsyncValue<List<Score>>> {
  ScoreboardNotifier(this.repository) : super(const AsyncValue.loading()) {
    fetchSortedScores();
  }

  final ScoreboardRepository repository;


  Future<void> fetchSortedScores() async {
    try {
      state = const AsyncValue.loading();
      final scores = await repository.fetchSortedScores();
      state = AsyncValue.data(scores);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
  Future<void> saveScore(Score score) async {
    await repository.saveScore(score);
    await fetchSortedScores();
  }

  Future<void> deleteByUsername(String username) async {
    await repository.deleteByUsername(username);
    await fetchSortedScores();
  }
}
