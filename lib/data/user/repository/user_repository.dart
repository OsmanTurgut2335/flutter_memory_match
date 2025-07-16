// lib/data/user/user_repository.dart
import 'dart:convert';

import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:mem_game/data/game/model/game_state_model.dart';
import 'package:mem_game/data/shop_item/model/shop_item.dart';
import 'package:mem_game/data/user/model/user_model.dart';

class UserRepository {
  static const String userBoxName = 'userBox';
  static const String userKey = 'currentUser';

  /// Saves the provided user in the Hive box with empty shop items list.
  Future<void> saveUser(UserModel user) async {
    final box = Hive.box<UserModel>(userBoxName);
    await box.delete(userKey);

    await box.put(userKey, user);

    user.inventory = HiveList<ShopItem>(Hive.box<ShopItem>('shopItemsBox'));
    await user.save();
  }

  /// Retrieves the user from the Hive box.
  UserModel? getUser() {
    final box = Hive.box<UserModel>(userBoxName);
    return box.get(userKey);
  }

  /// Deletes the user from the Hive box.
  Future<void> deleteUser() async {
    final box = Hive.box<UserModel>(userBoxName);
    await box.delete(userKey);
  }

  ///Deletes the user from relational database
  Future<void> deleteUserFromDb() async {
    final box = Hive.box<UserModel>(userBoxName);

    final user = box.get(userKey);

    if (user == null) {
      print('Kullanıcı bulunamadı.');
      return;
    }

    final response = await http.delete(Uri.parse('http://10.0.2.2:8080/leaderboard/${user.username}'));

    if (response.statusCode == 200) {
      print('Kullanıcı başarıyla silindi.');
    }
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

  /// Changes the username of the current user in the Hive box and db
  Future<UserModel?> changeUsername(String newUsername) async {
    final box = Hive.box<UserModel>(userBoxName);
    final user = box.get(userKey);

    if (user == null) {
      print('Kullanıcı bulunamadı.');
      return null;
    }

    final response = await http.put(
      Uri.parse('http://10.0.2.2:8080/leaderboard/username'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'oldUsername': user.username, 'newUsername': newUsername}),
    );

    if (response.statusCode == 200) {
      print('Kullanıcı ismi başarıyla değiştirildi');

      // Hive içindeki kullanıcıyı güncelle
      final updatedUser = UserModel(username: newUsername);
      await box.put(userKey, updatedUser);
      return updatedUser;
    } else {
      print('İsim değiştirme başarısız: ${response.statusCode}');
      return null;
    }
  }
}
