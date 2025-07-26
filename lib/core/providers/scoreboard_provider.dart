import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mem_game/core/providers/user_provider.dart';
import 'package:mem_game/data/score/model.dart';
import 'package:mem_game/data/scoreboard/repository/scoreboard_repository.dart';
import 'package:mem_game/features/scoreboard/viewmodel/scoreboard_notifier.dart';

final scoreboardRepositoryProvider = Provider<ScoreboardRepository>((ref) {
  return ScoreboardRepository();
});


final scoreboardViewModelProvider =
    StateNotifierProvider<ScoreboardNotifier, AsyncValue<({List<Score> top10, Score? userScore})>>((ref) {
  final repository = ref.watch(scoreboardRepositoryProvider);
  final username = ref.read(userRepositoryProvider).getUser()?.username;
  return ScoreboardNotifier(repository, username);
});
