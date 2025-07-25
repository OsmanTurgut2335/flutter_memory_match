import 'dart:developer';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:mem_game/data/game/model/game_state_model.dart';
import 'package:mem_game/data/memorycard/model/memory_card.dart';
import 'package:mem_game/data/shop_item/model/shop_item.dart';
import 'package:mem_game/data/user/model/user_model.dart';



Future<void> initializeHive() async {
  await Hive.initFlutter();

  Hive
    ..registerAdapter(UserModelAdapter())
    ..registerAdapter(MemoryCardAdapter())
    ..registerAdapter(GameStateAdapter())
    ..registerAdapter(ShopItemAdapter())
    ..registerAdapter(ShopItemTypeAdapter());

  try {
    await Hive.openBox<ShopItem>('shopItemsBox');
    await Hive.openBox<UserModel>('userBox');
    await Hive.openBox<GameState>('gameBox');
  } catch (e, st) {
    log('Hive box açılırken hata: $e', stackTrace: st);
   
  }

  try {
    final users = Hive.box<UserModel>('userBox');
    final shop = Hive.box<ShopItem>('shopItemsBox');

    final user = users.get('currentUserKey');
    if (user != null) {
      user.inventory = HiveList(shop, objects: []);
      await user.save();
    }
  } catch (e, st) {
    log('Hive user/shop setup sırasında hata: $e', stackTrace: st);
  }
}
