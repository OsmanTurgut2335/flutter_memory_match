import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mem_game/data/score/model.dart';
import 'package:mem_game/data/scoreboard/repository/scoreboard_repository.dart';
import 'package:mem_game/features/scoreboard/viewmodel/scoreboard_notifier.dart';

final scoreboardRepositoryProvider = Provider<ScoreboardRepository>((ref) {
  return ScoreboardRepository();
});


final scoreboardViewModelProvider = StateNotifierProvider<ScoreboardNotifier, Score?>((
  ref,
) {
  final repository = ref.watch(scoreboardRepositoryProvider);
  return ScoreboardNotifier(repository);
});
