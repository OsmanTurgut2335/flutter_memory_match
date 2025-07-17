import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mem_game/data/user/model/user_model.dart';
import 'package:mem_game/data/user/repository/user_repository.dart';

class UserViewModel extends StateNotifier<AsyncValue<UserModel>> {
  UserViewModel(this._repository) : super(const AsyncLoading()) {
    loadUser();
  }

  final UserRepository _repository;

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

  Future<void> createUser(String username) async {
    state = const AsyncLoading();
    try {
      final newUser = UserModel(username: username);
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

  Future<void> changeUsername(String newUsername) async {
    final current = state.value;
    if (current == null) return;

    try {
      final updatedUser = await _repository.changeUsername(newUsername);
      if (updatedUser != null) {
        await _repository.transferGameToNewUsername(current.username, newUsername);
        state = AsyncValue.data(updatedUser);
      }
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> deleteUser() async {
    try {
      await _repository.deleteUserFromDb();
      await _repository.deleteUser();
      state = const AsyncError('User deleted', StackTrace.empty);
    } catch (e, st) {
      state = AsyncError(e, st);
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
}
