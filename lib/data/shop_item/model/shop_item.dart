import 'package:hive/hive.dart';

part 'shop_item.g.dart';

/// Envanterdeki her öğe bir kullanıcıya ait,
/// bir itemType ve adet (quantity) bilgisini tutar.
@HiveType(typeId: 3)
class ShopItem extends HiveObject {              

  ShopItem({
    required this.userId,
    required this.itemType,
    this.quantity = 1,
  });
  @HiveField(0)
  String userId;                

  @HiveField(1)
  ShopItemType itemType;   

  @HiveField(2)
  int quantity;                    
}

@HiveType(typeId: 4)
enum ShopItemType {
  @HiveField(0)
  healthPotion,

  @HiveField(1)
  extraFlip,

   @HiveField(2)
  doubleCoins,
}
