// lib/data/user/user_repository.dart
import 'package:hive/hive.dart';
import 'package:mem_game/data/user/model/user_model.dart';

class UserRepository {
  static const String userBoxName = 'userBox';
  static const String userKey = 'currentUser';

  /// Saves the provided user in the Hive box.
  Future<void> saveUser(UserModel user) async {
    final box = Hive.box<UserModel>(userBoxName);
    await box.put(userKey, user);
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
}
