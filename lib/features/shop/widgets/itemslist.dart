import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mem_game/data/shop_item/model/shop_item.dart';
import 'package:mem_game/features/shop/widgets/boost_option_tile.dart';

///UI for boost ites list in the start of the game

Future<Map<String, bool>?> showBoostSelectionDialog(BuildContext context, List<ShopItem> items) async {
  bool useHealthPotion = false;
  bool useDoubleCoins = false;
  bool useExtraFlip = false;

  final healthQty =
      items
          .firstWhere(
            (i) => i.itemType == ShopItemType.healthPotion,
            orElse: () => ShopItem(userId: '', itemType: ShopItemType.healthPotion, quantity: 0),
          )
          .quantity;

  final doubleQty =
      items
          .firstWhere(
            (i) => i.itemType == ShopItemType.doubleCoins,
            orElse: () => ShopItem(userId: '', itemType: ShopItemType.doubleCoins, quantity: 0),
          )
          .quantity;

  final flipQty =
      items
          .firstWhere(
            (i) => i.itemType == ShopItemType.extraFlip,
            orElse: () => ShopItem(userId: '', itemType: ShopItemType.extraFlip, quantity: 0),
          )
          .quantity;

  return showDialog<Map<String, bool>>(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black54,
    builder: (_) {
      return StatefulBuilder(
        builder:
            (context, setState) => Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color.fromARGB(255, 120, 132, 219), Color.fromARGB(255, 219, 156, 96)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: AlertDialog(
                //  backgroundColor: const Color(0xFF3CA6A6),
                backgroundColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                contentPadding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
                actionsPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                title: Text('boost.title'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      BoostOptionTile(
                        title: 'boost.health.title'.tr(),
                        description: 'boost.health.desc'.tr(),
                        quantity: healthQty,
                        selected: useHealthPotion,
                        onTap: () => setState(() => useHealthPotion = !useHealthPotion),
                        enabled: healthQty > 0,
                      ),

                      BoostOptionTile(
                        title: 'boost.double.title'.tr(),
                        description: 'boost.double.desc'.tr(),
                        quantity: doubleQty,
                        selected: useDoubleCoins,
                        onTap: () => setState(() => useDoubleCoins = !useDoubleCoins),
                        enabled: doubleQty > 0,
                      ),

                      BoostOptionTile(
                        title: 'boost.flip.title'.tr(),
                        description: 'boost.flip.desc'.tr(),
                        quantity: flipQty,
                        selected: useExtraFlip,
                        onTap: () => setState(() => useExtraFlip = !useExtraFlip),
                        enabled: flipQty > 0,
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('boost.cancel'.tr(), style: const TextStyle(color: Colors.black87)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, {
                        'healthPotion': useHealthPotion,
                        'doubleCoins': useDoubleCoins,
                        'extraFlip': useExtraFlip,
                      });
                    },

                    child: Text('boost.start'.tr()),
                  ),
                ],
              ),
            ),
      );
    },
  );
}
