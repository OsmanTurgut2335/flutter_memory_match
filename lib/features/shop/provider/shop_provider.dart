import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mem_game/data/shop_item/model/shop_item.dart';
import 'package:mem_game/data/shop_item/repository/shop_repository.dart';
import 'package:mem_game/features/shop/viewmodel/shop_notifier.dart';
import 'package:mem_game/features/user/provider/user_provider.dart';

final shopRepositoryProvider = Provider<ShopRepository>((ref) {
  final userRepo = ref.watch(userRepositoryProvider);
  return ShopRepository(userRepo);
});

final shopViewModelProvider = StateNotifierProvider<ShopNotifier, List<ShopItem>>((ref) {
  final repo = ref.watch(shopRepositoryProvider);
  return ShopNotifier(repo);
});
