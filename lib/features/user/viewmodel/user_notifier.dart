import 'dart:async';

import 'package:dio/dio.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

import 'package:mem_game/core/error/app_exceptions.dart';
import 'package:mem_game/core/providers/dio_provider.dart';

import 'package:mem_game/core/providers/user_provider.dart';

import 'package:mem_game/data/user/model/user_model.dart';
import 'package:mem_game/data/user/repository/user_repository.dart';
import 'package:mem_game/view/home_screen.dart';

class UserViewModel extends StateNotifier<AsyncValue<UserModel>> {
  UserViewModel(this._repository, this._ref) : super(const AsyncLoading()) {
    loadUser();
  }

  final UserRepository _repository;
  final Ref _ref;

  /// Loads the user from the repository and updates the state.
  Future<void> loadUser() async {
    try {
      final user = _repository.getUser();
      if (user != null) {
        state = AsyncValue.data(user);
      } else {
        state = AsyncError('No user found', StackTrace.current);
      }
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> changeUsername(BuildContext context, String newUsername) async {
    try {
      final updatedUser = await _repository.changeUsernameAndTransferGame(newUsername);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('username.changeSuccess'.tr())));
      }
      state = AsyncValue.data(updatedUser);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text((e is AppException) ? e.localizedMessage : e.toString())));
      }
      state = AsyncError(e, StackTrace.current);
    }
  }

  Future<void> createUser(String username, {bool isDummy = false}) async {
    state = const AsyncLoading();
    try {
      final newUser = UserModel(username: username, isDummy: isDummy);
      await _repository.saveUser(newUser);
      state = AsyncValue.data(newUser);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> updateUser(UserModel user) async {
    try {
      await _repository.saveUser(user);
      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> loginUser(BuildContext context, String username, String password) async {
    try {
      state = const AsyncLoading();
      final user = await _repository.login(username, password);
      state = AsyncData(user);
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> deleteUser(BuildContext context) async {
    try {
      final user = _repository.getUser();

      if (user != null && !user.isDummy) {
        final success = await _repository.deleteUserFromDb();

        if (!success) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Sunucudan silinemedi')));
        }
      }

      await _repository.deleteUser();
      state = const AsyncError('User deleted', StackTrace.empty);

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Kullanıcı silindi')));
    } catch (e, st) {
      state = AsyncError(e, st);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Bir hata oluştu: $e')));
    }
  }

  Future<void> purchaseCoins(int amount) async {
    final current = state.value;
    if (current == null || current.coins < amount) return;

    try {
      final updated = current.copyWith(coins: current.coins - amount);
      await _repository.saveUser(updated);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> addCoins(int amount) async {
    final current = state.value;
    if (current == null) return;

    try {
      final updated = current.copyWith(coins: current.coins + amount);
      await _repository.saveUser(updated);
      state = AsyncValue.data(updated);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> handleUserCreation({
    required BuildContext context,
    required String username,
    required String password,
    required VoidCallback onDummyFallback,
    required VoidCallback onUserExists,
    required VoidCallback onUnexpected,
  }) async {
    final dio = _ref.read(dioProvider);

    try {
      final response = await dio.post(
        '/auth/register',
        data: {'username': username, 'password': password},
        options: Options(extra: {'auth': false}),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final user = UserModel.fromJson(response.data as Map<String, dynamic>);
        await _repository.saveUser(user);

        if (context.mounted) {
          await _ref.read(userViewModelProvider.notifier).loadUser();
          await Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (_) => const HomeScreen()));
        }
      } else if (response.statusCode == 409) {
        onUserExists();
      } else {
        onUnexpected();
      }
    } on TimeoutException {
      onDummyFallback();
    } catch (e) {
      onDummyFallback();
    }
  }

  Future<void> logout() async {
    final box = Hive.box<UserModel>('userBox');
    final user = box.get('currentUser');
    await _repository.updateCoinsToServer();
    if (user != null) {
      final cleared = user.copyWith(accessToken: '', refreshToken: '');
      await box.put('currentUser', cleared);

      state = const AsyncValue.loading();
    }
  }
}
