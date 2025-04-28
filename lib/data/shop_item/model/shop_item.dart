import 'package:hive/hive.dart';

part 'shop_item.g.dart';

/// Envanterdeki her öğe bir kullanıcıya ait,
/// bir itemType ve adet (quantity) bilgisini tutar.
@HiveType(typeId: 2)
class ShopItem extends HiveObject {              

  ShopItem({
    required this.userId,
    required this.itemType,
    this.quantity = 1,
  });
  @HiveField(0)
  String userId;                // Hangi kullanıcıya ait olduğu

  @HiveField(1)
  ShopItemType itemType;   // HealthPotion mı ExtraFlip mı

  @HiveField(2)
  int quantity;                    // Stok adedi
}

@HiveType(typeId: 3)
enum ShopItemType {
  @HiveField(0)
  healthPotion,

  @HiveField(1)
  extraFlip,
}
