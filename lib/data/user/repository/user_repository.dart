import 'dart:async';
import 'package:dio/dio.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:mem_game/core/error/app_exceptions.dart';
import 'package:mem_game/core/error/dio_exception_mapper.dart';
import 'package:mem_game/core/providers/dio_provider.dart';

import 'package:mem_game/core/providers/env_provider.dart';
import 'package:mem_game/features/user/provider/user_provider.dart';

import 'package:mem_game/data/game/model/game_state_model.dart';
import 'package:mem_game/data/shop_item/model/shop_item.dart';
import 'package:mem_game/data/user/model/user_model.dart';

class UserRepository {
  UserRepository(this.ref);
  final Ref ref;

  static const String userBoxName = 'userBox';
  static const String userKey = 'currentUser';

  Dio get _dio => ref.read(dioProvider);

  String get _baseUrl => ref.read(envConfigProvider).baseUrl;

  /// Saves the provided user in the Hive box with empty shop items list.
  Future<void> saveUser(UserModel user) async {
    final box = Hive.box<UserModel>(userBoxName);
    await box.put(userKey, user);
    await box.flush();

    final savedUser = box.get(userKey);
    if (savedUser != null) {
      savedUser.inventory = HiveList<ShopItem>(Hive.box<ShopItem>('shopItemsBox'));
      await savedUser.save();
    } else {
      throw Exception('User could not be saved properly.');
    }
  }

  UserModel? getUser() {
    return Hive.box<UserModel>(userBoxName).get(userKey);
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

    try {
      final response = await _dio.delete<void>(
        '$_baseUrl/leaderboard/${user.username}',
        options: Options(validateStatus: (_) => true),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

Future<UserModel> changeUsernameAndTransferGame(String newUsername) async {
  try {
    final box = Hive.box<UserModel>(userBoxName);
    final user = box.get(userKey);

    if (user == null) throw const NotFoundException();

    final response = await _dio.put(
      '$_baseUrl/leaderboard/username',
      data: {'oldUsername': user.username, 'newUsername': newUsername},
    
    );

    if (response.statusCode != 200) {
      throw AppExceptionMapper.fromStatusCode(response.statusCode!);
    }

    final body = response.data;
    final newUsernameFromApi = body['newUsername']?.toString();
    final newAccessToken = body['accessToken']?.toString();
    final newRefreshToken = body['refreshToken']?.toString();

    if (newUsernameFromApi == null || newAccessToken == null || newRefreshToken == null) {
      throw const IncompleteResponseException();
    }

    final updatedUser = user.copyWith(
      username: newUsernameFromApi,
      accessToken: newAccessToken,
      refreshToken: newRefreshToken,
    );

    await box.put(userKey, updatedUser);
    await box.flush();

    // Transfer GameState
    final gameBox = Hive.box<GameState>('gameBox');
    final oldKey = 'game_${user.username}';
    final newKey = 'game_$newUsernameFromApi';
    final game = gameBox.get(oldKey);
    if (game != null) {
      await gameBox.delete(oldKey);
      await gameBox.put(newKey, game);
    }

    // Transfer ShopItems
    final shopBox = Hive.box<ShopItem>('shopItemsBox');
    final oldItems = shopBox.values.where((item) => item.userId == user.username).toList();

    for (final item in oldItems) {
      item.userId = newUsernameFromApi;
      await item.save();
    }

    return updatedUser;
  } on DioException catch (e) {
  
    throw AppExceptionMapper.fromDioException(e);
  }
}


  Future<void> updateCoinsToServer() async {
    final user = getUser();
    if (user == null || user.username.isEmpty) return;

    try {
      await _dio.put(
        '$_baseUrl/leaderboard/coins',
        data: {'username': user.username, 'coins': user.coins},
        options: Options(validateStatus: (_) => true),
      );
      print('[USER] Coins updated to DB: ${user.coins}');
    } catch (e) {
      print('[USER] Failed to update coins to server: $e');
    }
  }

  Future<UserModel> login(String username, String password) async {
    try {
      final response = await _dio
          .post<Map<String, dynamic>>('$_baseUrl/auth/login', data: {'username': username, 'password': password})
          .timeout(const Duration(seconds: 5));
      print('Login response: ${response.statusCode} -> ${response.data}');

      if (response.statusCode == 200) {
        final user = UserModel.fromJson(response.data as Map<String, dynamic>);
        final box = Hive.box<UserModel>(userBoxName);
        await box.put(userKey, user);
        return user;
      } else {
        throw const UnauthorizedException();
      }
    } on DioException catch (e) {
      throw AppExceptionMapper.fromDioException(e);
    } catch (_) {
      throw const TimeoutException();
    }
  }
}
