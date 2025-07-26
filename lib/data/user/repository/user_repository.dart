// lib/data/user/user_repository.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:mem_game/core/init/env_config.dart';
import 'package:mem_game/core/providers/env_provider.dart';
import 'package:mem_game/data/game/model/game_state_model.dart';
import 'package:mem_game/data/shop_item/model/shop_item.dart';
import 'package:mem_game/data/user/model/user_model.dart';

class UserRepository {
  UserRepository(this.ref);
  final Ref ref;

  static const String userBoxName = 'userBox';
  static const String userKey = 'user';

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

Future<bool> deleteUserFromDb() async {
  final box = Hive.box<UserModel>(userBoxName);
  final user = box.get(userKey);

  if (user == null || user.isDummy) {
    return false;
  }

  final apiKey = ref.read(envConfigProvider).apiKey;
  final baseUrl = ref.read(envConfigProvider).baseUrl;

  try {
    final response = await http.delete(
      Uri.parse('$baseUrl/leaderboard/${user.username}'),
      headers: {'x-api-key': apiKey},
    );

    return response.statusCode == 200;
  } catch (_) {
    return false;
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
Future<UserModel> changeUsername(String newUsername) async {
  final box = Hive.box<UserModel>(userBoxName);
  final user = box.get(userKey);

  final apiKey = ref.read(envConfigProvider).apiKey;
  final baseUrl = ref.read(envConfigProvider).baseUrl;

  if (user == null) {
    throw Exception('Kullanıcı bulunamadı.');
  }

  if (user.isDummy) {
    final updatedUser = user.copyWith(username: newUsername);
    await box.put(userKey, updatedUser);
    return updatedUser;
  }

  final response = await http.put(
    Uri.parse('$baseUrl/leaderboard/username'),
    headers: {
      'Content-Type': 'application/json',
      'x-api-key': apiKey,
    },
    body: jsonEncode({
      'oldUsername': user.username,
      'newUsername': newUsername,
    }),
  );

  if (response.statusCode == 200) {
    final updatedUser = user.copyWith(username: newUsername);
    await box.put(userKey, updatedUser);
    return updatedUser;
  } else if (response.statusCode == 404) {
    throw Exception('Kullanıcı sunucuda bulunamadı.');
  } else {
    throw Exception('İsim değiştirme başarısız: ${response.statusCode}');
  }
}


}
