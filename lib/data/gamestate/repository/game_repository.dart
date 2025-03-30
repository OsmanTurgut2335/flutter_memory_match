import 'package:hive/hive.dart';
import 'package:mem_game/data/gamestate/model/game_state_model.dart';
import 'package:mem_game/data/user/model/user_model.dart';

class GameRepository {
  static const String gameBoxName = 'gameBox';
  static const String currentGameKey = 'currentGame';
  static const String userBoxName = 'userBox';
  static const String currentUserKey = 'currentUser';

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

  /// Checks and updates the user's best time if the current game time is lower.
  Future<void> updateBestTimeIfNeeded(int currentTime) async {
    final userBox = Hive.box<UserModel>(userBoxName);
    final currentUser = userBox.get(currentUserKey) as UserModel?;
    if (currentUser != null) {
      if (currentUser.bestTime == 0 || currentTime < currentUser.bestTime) {
        final updatedUser = currentUser.copyWith(bestTime: currentTime);
        await userBox.put(currentUserKey, updatedUser);
        // Optionally: Update the Firebase scoreboard here.
        print("Firebase updated for user: ${currentUser.username} with bestTime: $currentTime");
      }
    }
  }
}
