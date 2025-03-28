import 'package:hive/hive.dart';
import 'package:mem_game/data/gamestate/model/game_state_model.dart';

class GameRepository {
  static const String gameBoxName = 'gameBox';
  static const String currentGameKey = 'currentGame';

  /// Loads the saved GameState from Hive.
  Future<GameState?> loadGameState() async {
    final box = Hive.box<GameState>(gameBoxName);
    return box.get(currentGameKey);
  }

  /// Checks if a saved game state exists.
  Future<bool> hasOngoingGame() async {
    final box = Hive.box<GameState>(gameBoxName);
    return box.containsKey(currentGameKey);
  }

  /// Saves the given [GameState] into Hive.
  Future<void> saveGameState(GameState state) async {
    final box = Hive.box<GameState>(gameBoxName);
    await box.put(currentGameKey, state);
  }

  /// Deletes the saved game state.
  Future<void> deleteGameState() async {
    final box = Hive.box<GameState>(gameBoxName);
    await box.delete(currentGameKey);
  }
}
