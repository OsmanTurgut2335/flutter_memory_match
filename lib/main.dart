import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:mem_game/data/user/model/user_model.dart';
import 'package:mem_game/view/home_screen.dart';
import 'package:mem_game/view/create_username_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(UserModelAdapter());

  await Hive.openBox<UserModel>('userBox');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Open the user box
    final userBox = Hive.box<UserModel>('userBox');
    // Check if a user is already saved using a specific key ("currentUser")
    final hasUser = userBox.containsKey('currentUser');

    return MaterialApp(
      home: hasUser ? const HomeScreen() : const UsernameInputScreen(),
    );
  }
}
