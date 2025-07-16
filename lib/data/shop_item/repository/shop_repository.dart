import 'package:hive/hive.dart';
import 'package:mem_game/data/shop_item/model/shop_item.dart';
import 'package:mem_game/data/user/model/user_model.dart';
import 'package:mem_game/data/user/repository/user_repository.dart';

/// Repository for managing shop/inventory items in Hive.
class ShopRepository {
  ShopRepository(this._userRepository) : _box = Hive.box<ShopItem>('shopItemsBox');

  final Box<ShopItem> _box;
  final UserRepository _userRepository;

  UserModel? get _currentUser => _userRepository.getUser();

  /// Fetch all inventory items for the current user.
  Future<List<ShopItem>> getAllShopItems() async {
    return _box.values.where((item) => item.userId == _currentUser?.username).toList();
  }

  /// Purchase one unit of [type]. Cost should be deducted separately.
  Future<void> purchaseItem(ShopItemType type, int cost) async {
    final user = _currentUser;
    if (user == null) {
      print(' No currentUser found in Hive');
      return;
    }

    final userId = user.username;
    ShopItem? existing;
    for (final item in _box.values) {
      if (item.userId == userId && item.itemType == type) {
        existing = item;
        break;
      }
    }

    ShopItem shopItem;
    if (existing != null) {
      existing.quantity += 1;
      await existing.save();
      shopItem = existing;
    } else {
      final newItem = ShopItem(userId: userId, itemType: type, quantity: 1);
      final key = await _box.add(newItem);
      shopItem = _box.get(key)!;
    }

    // 2) Update user's inventory HiveList
    if (!user.inventory.any((item) => item.key == shopItem.key)) {
      user.inventory.add(shopItem);
    }
    await user.save();

    //  DEBUG
    print('📦 [User Inventory]');
    for (var item in user.inventory) {
      print('→ ${item.itemType} | quantity: ${item.quantity} | key: ${item.key}');
    }
  }

  /// Use one unit of [type], decrementing quantity and updating UserModel.inventory.
  Future<void> useItem(ShopItemType type) async {
    final user = _currentUser;
    if (user == null) {
      print(' No currentUser found in Hive');
      return;
    }

    final userId = user.username;

    ShopItem? existing;
    for (var item in _box.values) {
      if (item.userId == userId && item.itemType == type) {
        existing = item;
        break;
      }
    }

    if (existing != null && existing.quantity > 0) {
      existing.quantity -= 1;
      await existing.save();

      if (existing.quantity == 0) {
        user.inventory.remove(existing);
      }
      await user.save();
    }
  }
}
