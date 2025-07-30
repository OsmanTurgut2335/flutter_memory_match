import 'dart:async';
import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:mem_game/core/providers/dio_provider.dart';

import 'package:mem_game/core/providers/env_provider.dart';
import 'package:mem_game/data/game/model/game_state_model.dart';
import 'package:mem_game/data/shop_item/model/shop_item.dart';
import 'package:mem_game/data/user/model/user_model.dart';

class UserRepository {
  UserRepository(this.ref);
  final Ref ref;

  static const String userBoxName = 'userBox';
  static const String userKey = 'user';

Dio get _dio => ref.read(dioProvider);

  /// Saves the provided user in the Hive box with empty shop items list.
Future<void> saveUser(UserModel user) async {
  final box = Hive.box<UserModel>(userBoxName);
  await box.delete(userKey);
  await box.put(userKey, user);

  final savedUser = box.get(userKey);
  if (savedUser != null) {
    savedUser.inventory = HiveList<ShopItem>(Hive.box<ShopItem>('shopItemsBox'));
    await savedUser.save();
  } else {
    throw Exception('User could not be saved properly.');
  }
}


  UserModel? getUser() {
    final box = Hive.box<UserModel>(userBoxName);
    return box.get(userKey);
  }

  Future<void> deleteUser() async {
    final box = Hive.box<UserModel>(userBoxName);
    await box.delete(userKey);
  }

  Future<bool> deleteUserFromDb() async {
    final box = Hive.box<UserModel>(userBoxName);
    final user = box.get(userKey);
    if (user == null || user.isDummy) return false;

    final apiKey = ref.read(envConfigProvider).apiKey;
    final baseUrl = ref.read(envConfigProvider).baseUrl;

    try {
      final response = await _dio.delete(
        '$baseUrl/leaderboard/${user.username}',
      
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<UserModel> changeUsernameAndTransferGame(String newUsername) async {
    final box = Hive.box<UserModel>(userBoxName);
    final user = box.get(userKey);
    final apiKey = ref.read(envConfigProvider).apiKey;
    final baseUrl = ref.read(envConfigProvider).baseUrl;

    if (user == null) throw Exception('Kullanıcı bulunamadı.');

    late UserModel updatedUser;

    if (user.isDummy) {
      updatedUser = user.copyWith(username: newUsername);
    } else {
      final response = await _dio.put(
        '$baseUrl/leaderboard/username',
        data: {'oldUsername': user.username, 'newUsername': newUsername},
  
      );

      if (response.statusCode == 200) {
        final body = response.data as Map<String, dynamic>;
        updatedUser = user.copyWith(
          username: body['username'] as String,
          accessToken: body['accessToken'] as String,
          refreshToken: body['refreshToken'] as String,
        );
        await box.put(userKey, updatedUser);
      } else if (response.statusCode == 404) {
        throw Exception('Kullanıcı sunucuda bulunamadı.');
      } else if (response.statusCode == 403) {
        throw Exception('Sadece kendi kullanıcı adınızı değiştirebilirsiniz.');
      } else {
        throw Exception('İsim değiştirme başarısız: ${response.statusCode}');
      }
    }

    final gameBox = Hive.box<GameState>('gameBox');
    final oldKey = 'game_${user.username}';
    final newKey = 'game_${newUsername}';
    final game = gameBox.get(oldKey);

    if (game != null) {
      await gameBox.put(newKey, game);
      await gameBox.delete(oldKey);
    }

    return updatedUser;
  }

  Future<UserModel> login(String username, String password) async {
    final baseUrl = ref.read(envConfigProvider).baseUrl;

    try {
      final response = await _dio
          .post(
            '$baseUrl/auth/login',
            data: {'username': username, 'password': password},
         
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
  final user = UserModel.fromJson(response.data as Map<String, dynamic>);
        final box = Hive.box<UserModel>(userBoxName);
        await box.put(userKey, user);
        return user;
      } else {
        throw Exception('error.failed'.tr());
      }
    } on TimeoutException {
      throw TimeoutException('error.timeout'.tr());
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }
}
