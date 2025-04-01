import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:mem_game/data/gamestate/model/game_state_model.dart';
import 'package:mem_game/data/user/model/user_model.dart';

class GameRepository {
  static const String gameBoxName = 'gameBox';
  static const String currentGameKey = 'currentGame';
  static const String userBoxName = 'userBox';
  static const String currentUserKey = 'currentUser';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

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

  /// Checks and updates the user's best time locally and on Firestore.
  Future<void> updateBestTimeIfNeeded(int currentTime) async {
    final userBox = Hive.box<UserModel>(userBoxName);
    final currentUser = userBox.get(currentUserKey);

    if (currentUser != null) {
      if (currentUser.bestTime == 0 || currentTime < currentUser.bestTime) {
        final updatedUser = currentUser.copyWith(bestTime: currentTime);
        await userBox.put(currentUserKey, updatedUser);

        // Update Firestore as well
        await _updateBestTimeInFirestore(updatedUser.username, currentTime);
      }
    }
  }

  /// Updates the best time in Firestore.
  Future<void> _updateBestTimeInFirestore(String username, int bestTime) async {
    final userRef = _firestore.collection('leaderboard').doc(username);
    await userRef.set({'bestTime': bestTime, 'username': username}, SetOptions(merge: true));
  }

  Future<void> clearBestTime() async {
    final userBox = Hive.box<UserModel>(userBoxName);
    final currentUser = userBox.get(currentUserKey);

    if (currentUser != null) {
      // Set bestTime to 0 in local storage
      final updatedUser = currentUser.copyWith(bestTime: 0);
      await userBox.put(currentUserKey, updatedUser);

      // Reset in Firestore as well
      //    await _updateBestTimeInFirestore(updatedUser.username, 0);
    }
  }
}
