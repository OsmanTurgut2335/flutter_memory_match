import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:mem_game/core/providers/env_provider.dart';
import 'package:mem_game/data/user/model/auth_response.dart';
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
      final auth = await _repository.login(username, password);
      state = AsyncData(UserModel(username: auth.username, token: auth.token));
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> changeUsername(BuildContext context, String newUsername) async {
    final current = state.value;
    if (current == null) return;

    try {
      final updatedUser = await _repository.changeUsername(newUsername);

      await _repository.transferGameToNewUsername(current.username, newUsername);

      state = AsyncValue.data(updatedUser);
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
      state = AsyncError(e, StackTrace.current);
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

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bir hata oluştu')));
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
    try {
      final env = _ref.read(envConfigProvider);
      final response = await http
          .post(
            Uri.parse('${env.baseUrl}/auth/register'),
            headers: {'Content-Type': 'application/json', 'x-api-key': env.apiKey},
            body: jsonEncode({'username': username, 'password': password}),
          )
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final auth = AuthResponse.fromJson(data as Map<String, dynamic>);
        final user = UserModel(username: auth.username, token: auth.token);

        await _repository.saveUser(user);

        if (context.mounted) {
          await Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (_) => const HomeScreen()));
        }
      }
    } on TimeoutException {
      onDummyFallback();
    } catch (_) {
      onDummyFallback();
    }
  }

  Future<void> logout() async {
    final box = Hive.box<UserModel>('userBox');
    final user = box.get('user');

    if (user != null) {
      await box.put('user', user.copyWith(token: ''));
      state = const AsyncValue.loading();
    }
  }
}
