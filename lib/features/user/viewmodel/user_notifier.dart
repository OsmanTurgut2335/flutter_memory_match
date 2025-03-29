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

  /// Deletes the user data.
  Future<void> deleteUser() async {
    await _repository.deleteUser();
    state = null;
  }
}
