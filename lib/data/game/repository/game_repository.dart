import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:mem_game/data/game/model/game_state_model.dart';
import 'package:mem_game/data/memorycard/model/memory_card.dart';
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

    
        await _updateBestTimeInFirestore(updatedUser.username, currentTime);
      }
    }
  }

  /// Updates the best time in Firestore.
  Future<void> _updateBestTimeInFirestore(String username, int bestTime) async {
    try {
      final userRef = _firestore.collection('leaderboard').doc(username);
    
      await userRef.set({'bestTime': bestTime, 'username': username}, SetOptions(merge: true));

      print('Firestore updated successfully for user: $username');
    } catch (e) {
    
      print('Error updating best time in Firestore for $username: $e');
    }
  }

  Future<void> clearBestTime() async {
    final userBox = Hive.box<UserModel>(userBoxName);
    final currentUser = userBox.get(currentUserKey);

    if (currentUser != null) {
     
      final updatedUser = currentUser.copyWith(bestTime: 0);
      await userBox.put(currentUserKey, updatedUser);

      // Reset in Firestore as well
      //    await _updateBestTimeInFirestore(updatedUser.username, 0);
    }
  }

  /// Generates a shuffled list of MemoryCard objects for the given level.
  /// Level 1: uses assets/card_images/level1 → 6 images → 12 cards
  /// Level 2: uses assets/card_images/level2 → 8 images → 16 cards and so on
 
  List<MemoryCard> generateCardsForLevel(int level, {bool preview = false}) {
    final levelImages = switch (level) {
      1 => List<String>.generate(5, (i) => 'assets/card_images/level1/card$i.png'),
      2 => List<String>.generate(6, (i) => 'assets/card_images/level2/card$i.png'),
      3 => List<String>.generate(7, (i) => 'assets/card_images/level3/card$i.png'),
      4 => List<String>.generate(8, (i) => 'assets/card_images/level4/card$i.png'),
      5 => List<String>.generate(9, (i) => 'assets/card_images/level5/card$i.png'),
      6 => List<String>.generate(10, (i) => 'assets/card_images/level6/card$i.png'),
      7 => List<String>.generate(11, (i) => 'assets/card_images/level7/card$i.png'),
      _ => List<String>.generate(5, (i) => 'assets/card_images/level1/card$i.png'),
    };

    final allPaths = [for (final path in levelImages) path, for (final path in levelImages) path]..shuffle();

    return List<MemoryCard>.generate(
      allPaths.length,
      (index) => MemoryCard(id: index, content: allPaths[index], isFaceUp: preview),
    );
  }
}
