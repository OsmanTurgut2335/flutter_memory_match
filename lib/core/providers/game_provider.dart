import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mem_game/core/providers/shop_provider.dart';
import 'package:mem_game/core/providers/user_provider.dart';
import 'package:mem_game/data/game/model/game_state_model.dart';
import 'package:mem_game/data/game/repository/game_repository.dart';
import 'package:mem_game/features/game/viewmodel/game_notifier.dart';

final gameNotifierProvider = StateNotifierProvider<GameNotifier, GameState?>((ref) {
  final shopRepo = ref.watch(shopRepositoryProvider);
  final userRepo = ref.watch(userRepositoryProvider);
  return GameNotifier(GameRepository(), userRepo, shopRepo);
});

final ongoingGameProvider = FutureProvider<bool>((ref) async {
  final repo = GameRepository();
  final user = ref.read(userRepositoryProvider).getUser();

  if (user == null) return false;

  return repo.hasOngoingGame(user.username);
});
