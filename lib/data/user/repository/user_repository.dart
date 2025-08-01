import 'dart:async';
import 'package:dio/dio.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:mem_game/core/error/app_exceptions.dart';
import 'package:mem_game/core/error/dio_exception_mapper.dart';
import 'package:mem_game/core/providers/dio_provider.dart';

import 'package:mem_game/core/providers/env_provider.dart';

import 'package:mem_game/data/game/model/game_state_model.dart';
import 'package:mem_game/data/shop_item/model/shop_item.dart';
import 'package:mem_game/data/user/model/user_model.dart';

class UserRepository {
  UserRepository(this.ref);
  final Ref ref;

  static const String userBoxName = 'userBox';
  static const String userKey = 'currentUser';

  Dio get _dio => ref.read(dioProvider);

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
    final baseUrl = ref.read(envConfigProvider).baseUrl;

    try {
      final response = await _dio.delete<void>(
        '$baseUrl/leaderboard/${user.username}',
        options: Options(validateStatus: (_) => true),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  Future<UserModel> changeUsernameAndTransferGame(String newUsername) async {
    final box = Hive.box<UserModel>(userBoxName);
    final user = box.get(userKey);

    if (user == null) throw const NotFoundException();

    final baseUrl = ref.read(envConfigProvider).baseUrl;

    final response = await _dio.put(
      '$baseUrl/leaderboard/username',
      data: {'oldUsername': user.username, 'newUsername': newUsername},
      options: Options(validateStatus: (_) => true),
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

    final gameBox = Hive.box<GameState>('gameBox');
    final oldKey = 'game_${user.username}';
    final newKey = 'game_$newUsernameFromApi';
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
          .post<Map<String, dynamic>>('$baseUrl/auth/login', data: {'username': username, 'password': password})
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final user = UserModel.fromJson(response.data as Map<String, dynamic>);
        final box = Hive.box<UserModel>(userBoxName);
        await box.put(userKey, user);
        return user;
      } else {
        throw const UnauthorizedException();
      }
    } on TimeoutException {
      throw const TimeoutException();
    } on DioException catch (e) {
      throw AppExceptionMapper.fromDioException(e);
    } catch (_) {
      throw const UnknownException();
    }
  }
}
