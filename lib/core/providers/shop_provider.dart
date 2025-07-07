import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mem_game/core/providers/user_provider.dart';
import 'package:mem_game/data/shop_item/model/shop_item.dart';
import 'package:mem_game/data/shop_item/repository/shop_repository.dart';
import 'package:mem_game/features/shop/viewmodel/shop_notifier.dart';

final shopRepositoryProvider = Provider<ShopRepository>((ref) {
  final user = ref.watch(userViewModelProvider)!;
  return ShopRepository();
});

final shopViewModelProvider = StateNotifierProvider<ShopNotifier, List<ShopItem>>((ref) {
  final repo = ref.watch(shopRepositoryProvider);
  return ShopNotifier(repo);
});
