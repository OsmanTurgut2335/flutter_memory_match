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
    final all = await _repo.getAllShopItems();
    state = all;
  }

  Future<void> purchase(ShopItemType type, int cost) async {
    await _repo.purchaseItem(type, cost);
    await _loadAll();
  }

  Future<void> useHealthPotion() async {
    await _repo.useItem(ShopItemType.healthPotion);
    await _loadAll();
  }

  Future<void> useExtraFlip() async {
    await _repo.useItem(ShopItemType.extraFlip);
    await _loadAll();
  }

  Future<void> useDoubleCoins() async {
    await _repo.useItem(ShopItemType.doubleCoins);
    await _loadAll();
  }

  bool hasHealthPotion() {
    return state.any((item) => item.itemType == ShopItemType.healthPotion && item.quantity > 0);
  }

  bool hasExtraFlip() {
    return state.any((item) => item.itemType == ShopItemType.extraFlip && item.quantity > 0);
  }

  bool hasDoubleCoins() {
    return state.any((item) => item.itemType == ShopItemType.doubleCoins && item.quantity > 0);
  }

  int quantityOf(ShopItemType type) {
    return state
        .firstWhere(
          (item) => item.itemType == type,
          orElse: () => ShopItem(userId: _repo.currentUser?.username ?? '', itemType: type, quantity: 0),
        )
        .quantity;
  }

  bool canBuy(ShopItemType type) {
    final user = _repo.currentUser;
    final price = _priceFor(type);
    return user != null && user.coins >= price;
  }

  int _priceFor(ShopItemType type) {
    switch (type) {
      case ShopItemType.healthPotion:
        return 1000;
      case ShopItemType.extraFlip:
        return 1500;
      case ShopItemType.doubleCoins:
        return 2000;
    }
  }
}
