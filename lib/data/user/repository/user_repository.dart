// lib/data/user/user_repository.dart
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:mem_game/data/shop_item/model/shop_item.dart';
import 'package:mem_game/data/user/model/user_model.dart';

class UserRepository {
  static const String userBoxName = 'userBox';
  static const String userKey = 'currentUser';

  /// Saves the provided user in the Hive box with empty shop items list.
  Future<void> saveUser(UserModel user) async {
    final box = Hive.box<UserModel>(userBoxName);
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
  Future<void> deleteUserFromDb() async {
    final box = Hive.box<UserModel>(userBoxName);
  
    print(box.values);
    final user = box.get(userKey);
    print(user?.username);
    
    if (user == null) {
      print('Kullanıcı bulunamadı.');
      return;
    }

    final response = await http.delete(Uri.parse('http://10.0.2.2:8080/leaderboard/entry/${user.username}'));

    if (response.statusCode == 200) {
      print('Kullanıcı başarıyla silindi.');
    }
  }

  /// Changes the username of the current user.
  Future<UserModel?> changeUsername(String newUsername) async {
    final box = Hive.box<UserModel>(userBoxName);
    final currentUser = box.get(userKey);

    if (currentUser != null) {
      final updatedUser = currentUser.copyWith(username: newUsername);
      await box.put(userKey, updatedUser);
      return updatedUser;
    }
    return null;
  }
}
