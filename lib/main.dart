import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:mem_game/data/game/model/game_state_model.dart';
import 'package:mem_game/data/memorycard/model/memory_card.dart';
import 'package:mem_game/data/user/model/user_model.dart';
import 'package:mem_game/firebase_options.dart'; // Make sure this file exists
import 'package:mem_game/view/create_username_screen.dart';
import 'package:mem_game/view/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive
    ..registerAdapter(UserModelAdapter())
    ..registerAdapter(MemoryCardAdapter())
    ..registerAdapter(GameStateAdapter());
  // Open both boxes:
  await Hive.openBox<UserModel>('userBox');
  await Hive.openBox<GameState>('gameBox');
   
     await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final userBox = Hive.box<UserModel>('userBox');
    final hasUser = userBox.containsKey('currentUser');

    return MaterialApp(home: hasUser ? const HomeScreen() : const UsernameInputScreen());
  }
}
