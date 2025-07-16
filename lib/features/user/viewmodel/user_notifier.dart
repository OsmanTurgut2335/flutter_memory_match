// lib/features/user/viewmodel/user_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mem_game/data/user/model/user_model.dart';
import 'package:mem_game/data/user/repository/user_repository.dart';

class UserViewModel extends StateNotifier<UserModel?> {
  UserViewModel(this._repository) : super(null) {
    // Load user on initialization.
    loadUser();
  }
  final UserRepository _repository;

  /// Loads the user from the repository and updates the state.
  Future<void> loadUser() async {
    final user = _repository.getUser();
    state = user;
  }

  /// Creates a new user with the provided username.
  Future<void> createUser(String username) async {
    final newUser = UserModel(username: username);
    await _repository.saveUser(newUser);
    state = newUser;
  }

  /// Updates the user and saves changes in the repository.
  Future<void> updateUser(UserModel user) async {
    await _repository.saveUser(user);
    state = user;
  }

  Future<void> changeUsername(String newUsername) async {
    final currentUser = _repository.getUser(); // Veya state'den al
    if (currentUser == null) return;

    final oldUsername = currentUser.username;

    final updatedUser = await _repository.changeUsername(newUsername);
    if (updatedUser != null) {
      await _repository.transferGameToNewUsername(oldUsername, newUsername);
      state = updatedUser;
    }
  }

  /// Deletes the user data from both hive and relational database.
  Future<void> deleteUser() async {
    await _repository.deleteUserFromDb();

    await _repository.deleteUser();

    state = null;
  }

  /// Deducts [amount] coins from the user, persists the change, and updates state.
  Future<void> purchaseCoins(int amount) async {
    final current = state;
    if (current == null) return;

    // Ensure user has enough coins
    if (current.coins < amount) return;

    // Create updated user
    final updated = current.copyWith(coins: current.coins - amount);

    await _repository.saveUser(updated);

    state = updated;
  }

  /// Sadece ekleme (subtraction yok).
  Future<void> addCoins(int amount) async {
    final current = state;
    if (current == null) return;
    final updated = current.copyWith(coins: current.coins + amount);
    await _repository.saveUser(updated);
    state = updated;
  }
}
