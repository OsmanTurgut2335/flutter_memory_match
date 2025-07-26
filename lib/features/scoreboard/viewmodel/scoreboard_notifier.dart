import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mem_game/data/score/model.dart';
import 'package:mem_game/data/scoreboard/repository/scoreboard_repository.dart';

class ScoreboardNotifier extends StateNotifier<AsyncValue<({List<Score> top10, Score? userScore})>> {
  ScoreboardNotifier(this.repository, this.username) : super(const AsyncValue.loading()) {
    fetchSortedScores();
  }

  final ScoreboardRepository repository;
  final String? username;

  Future<void> fetchSortedScores() async {
    try {
      state = const AsyncValue.loading();

      final top10Raw = await repository.fetchSortedScores();

      final top10 =
          top10Raw.asMap().entries.map((entry) {
            final i = entry.key;
            final score = entry.value;
            return score.copyWith(rank: i + 1);
          }).toList();

      Score? userScore;

      if (username != null && top10.every((score) => score.username != username)) {
        userScore = await repository.fetchUserWithRank(username!);
      }

      state = AsyncValue.data((top10: top10, userScore: userScore));
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> refresh() async {
    await fetchSortedScores();
  }

  Future<void> saveScore(Score score) async {
    await repository.saveScore(score);
    await fetchSortedScores();
  }

  Future<void> deleteByUsername(String username) async {
    await repository.deleteByUsername(username);
    await fetchSortedScores();
  }

  Future<Score> fetchScoreByUsername(String username) async {
    return repository.fetchScoreByUsername(username);
  }
}
