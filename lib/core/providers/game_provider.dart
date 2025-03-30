import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mem_game/data/gamestate/repository/game_repository.dart';
import 'package:mem_game/features/game/viewmodel/game_notifier.dart';
import 'package:mem_game/data/gamestate/model/game_state_model.dart';

final gameNotifierProvider =
    StateNotifierProvider<GameNotifier, GameState?>((ref) {
  return GameNotifier(GameRepository());
});

final ongoingGameProvider = FutureProvider<bool>((ref) async {
  final repo = GameRepository();
  final hasGame = await repo.hasOngoingGame();

  return hasGame;
});
