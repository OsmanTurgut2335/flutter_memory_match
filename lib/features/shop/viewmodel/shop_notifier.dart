import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mem_game/data/shop_item/model/shop_item.dart';
import 'package:mem_game/data/shop_item/repository/shop_repository.dart';

class ShopNotifier extends StateNotifier<List<ShopItem>> {
  ShopNotifier(this._repo) : super([]) {
    _loadAll();
  }
  final ShopRepository _repo;

  Future<void> loadAll() async {
    await _loadAll();
  }

  Future<void> _loadAll() async {
    // load all items from your Hive box via the repository
    final all = await _repo.getAllShopItems();
    state = all;
  }

  /// Purchase an item of [type] with given [cost].
  Future<void> purchase(ShopItemType type, int cost) async {
    // Delegate purchase logic to repository, which may add or increment the item

    await _repo.purchaseItem(type, cost);
    // Reload inventory after purchase
    await _loadAll();
  }

  /// Use one health potion: decrement quantity and internal state.
  Future<void> useHealthPotion() async {
    await _repo.useItem(ShopItemType.healthPotion);
    await _loadAll();
  }

  /// Use one extra flip: decrement quantity and internal state.
  Future<void> useExtraFlip() async {
    await _repo.useItem(ShopItemType.extraFlip);
    await _loadAll();
  }

  bool hasHealthPotion() {
    return state.any((item) => item.itemType == ShopItemType.healthPotion && item.quantity > 0);
  }
}
