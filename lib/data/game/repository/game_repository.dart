import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:mem_game/core/init/env_config.dart';
import 'package:mem_game/data/game/model/game_state_model.dart';
import 'package:mem_game/data/memorycard/model/memory_card.dart';
import 'package:mem_game/data/user/model/user_model.dart';

class GameRepository {
  GameRepository(this._env);
  static const String gameBoxName = 'gameBox';
  static const String currentGameKey = 'currentGame';
  static const String userBoxName = 'userBox';
  static const String currentUserKey = 'currentUser';

  final EnvConfig _env;

  /// Loads the saved GameState from Hive.
  Future<GameState?> loadGameState(String username) async {
    final box = Hive.box<GameState>('gameBox');
    return box.get('game_$username');
  }

  /// Checks if a saved game state exists.
  Future<bool> hasOngoingGame(String username) async {
    final box = Hive.box<GameState>('gameBox');
    return box.containsKey('game_$username');
  }

  /// Saves the given [GameState] into Hive.
  Future<void> saveGameState(GameState state, String username) async {
    final box = Hive.box<GameState>('gameBox');
    await box.put('game_$username', state);
  }

  /// Deletes the saved game state.
  Future<void> deleteGameState(String username) async {
    if (username.isEmpty) return;
    final box = Hive.box<GameState>('gameBox');
    await box.delete('game_$username');
  }

  Future<void> transferGameToNewUsername(String oldUsername, String newUsername) async {
    final box = Hive.box<GameState>('gameBox');
    final oldKey = 'game_$oldUsername';
    final newKey = 'game_$newUsername';

    final game = box.get(oldKey);

    if (game != null) {
      await box.put(newKey, game);
      await box.delete(oldKey);
      print("Game transferred from $oldUsername to $newUsername");
    } else {
      print("No existing game to transfer");
    }
  }

  /// Checks and updates the user's best time and level
Future<bool> updateBestTimeAndLevelIfNeeded(int currentTime, int currentLevel) async {
  final userBox = Hive.box<UserModel>(userBoxName);
  final currentUser = userBox.get(currentUserKey);

  if (currentUser == null || currentUser.isDummy) return true; 

  final isNewBest = currentUser.bestTime == 0 || currentTime < currentUser.bestTime;

  final updatedUser = currentUser.copyWith(
    bestTime: isNewBest ? currentTime : currentUser.bestTime,
  );
  await userBox.put(currentUserKey, updatedUser);

  return _updateScoreDataInDatabase(
    username: updatedUser.username,
    bestTime: isNewBest ? currentTime : updatedUser.bestTime,
    level: currentLevel,
  );
}
Future<bool> _updateScoreDataInDatabase({
  required String username,
  required int bestTime,
  required int level,
}) async {
  try {
    final response = await http.put(
      Uri.parse('${_env.baseUrl}/leaderboard/besttime'),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': _env.apiKey,
      },
      body: jsonEncode({
        'username': username,
        'bestTime': bestTime,
        'level': level,
      }),
    );

    return response.statusCode == 200;
  } catch (e) {
    return false;
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
