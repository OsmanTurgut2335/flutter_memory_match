import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:mem_game/core/themes/themes.dart';
import 'package:mem_game/data/game/model/game_state_model.dart';
import 'package:mem_game/data/memorycard/model/memory_card.dart';
import 'package:mem_game/data/shop_item/model/shop_item.dart';
import 'package:mem_game/data/user/model/user_model.dart';
import 'package:mem_game/firebase_options.dart';
import 'package:mem_game/view/create_username_screen.dart';
import 'package:mem_game/view/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive
    ..registerAdapter(UserModelAdapter())
    ..registerAdapter(MemoryCardAdapter())
    ..registerAdapter(GameStateAdapter())
    ..registerAdapter(ShopItemAdapter())
    ..registerAdapter(ShopItemTypeAdapter());

  await Hive.openBox<ShopItem>('shopItemsBox');
  await Hive.openBox<UserModel>('userBox');
  await Hive.openBox<GameState>('gameBox');

  final users = Hive.box<UserModel>('userBox');
  final shop = Hive.box<ShopItem>('shopItemsBox');

  final user = users.get('currentUserKey');
  if (user != null) {

    user.inventory = HiveList(shop, objects: []);
    await user.save();
  }
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  // Initialize Mobile Ads SDK
  await MobileAds.instance.initialize();
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final userBox = Hive.box<UserModel>('userBox');
    final hasUser = userBox.containsKey('currentUser');

    return MaterialApp(
      home: hasUser ? const HomeScreen() : const UsernameInputScreen(),
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
    );
  }
}
