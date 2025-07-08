import 'package:flutter/material.dart';
import 'package:mem_game/data/shop_item/model/shop_item.dart';

class BoostOptionTile extends StatelessWidget {
  final String title;
  final String description;
  final int quantity;
  final bool selected;
  final VoidCallback onTap;

  const BoostOptionTile({
    super.key,
    required this.title,
    required this.description,
    required this.quantity,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Checkbox(
        value: selected,
        onChanged: (_) => onTap(),
      ),
      title: Text('$title (You have: $quantity)'),
      subtitle: Text(description),
      onTap: onTap,
    );
  }
}

Future<Map<String, bool>?> showBoostSelectionDialog(
    BuildContext context, List<ShopItem> items) async {
  bool useHealthPotion = false;
  bool useDoubleCoins = false;
  bool useExtraFlip = false;

  int healthQty = items.firstWhere(
    (i) => i.itemType == ShopItemType.healthPotion,
    orElse: () => ShopItem(userId: '', itemType: ShopItemType.healthPotion, quantity: 0),
  ).quantity;

  int doubleQty = items.firstWhere(
    (i) => i.itemType == ShopItemType.doubleCoins,
    orElse: () => ShopItem(userId: '', itemType: ShopItemType.doubleCoins, quantity: 0),
  ).quantity;

  int flipQty = items.firstWhere(
    (i) => i.itemType == ShopItemType.extraFlip,
    orElse: () => ShopItem(userId: '', itemType: ShopItemType.extraFlip, quantity: 0),
  ).quantity;

  return showDialog<Map<String, bool>>(
    context: context,
    builder: (_) {
      return StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Select Boosts'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                BoostOptionTile(
                  title: 'Health Potion',
                  description: '+1 starting health',
                  quantity: healthQty,
                  selected: useHealthPotion,
                  onTap: () => setState(() => useHealthPotion = !useHealthPotion),
                ),
                BoostOptionTile(
                  title: 'Double Coins',
                  description: '2x coin reward',
                  quantity: doubleQty,
                  selected: useDoubleCoins,
                  onTap: () => setState(() => useDoubleCoins = !useDoubleCoins),
                ),
                BoostOptionTile(
                  title: 'Extra Flip',
                  description: 'Flip one extra card at start',
                  quantity: flipQty,
                  selected: useExtraFlip,
                  onTap: () => setState(() => useExtraFlip = !useExtraFlip),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, null), child: const Text('Cancel')),
            TextButton(
              onPressed: () => Navigator.pop(context, {
                'healthPotion': useHealthPotion,
                'doubleCoins': useDoubleCoins,
                'extraFlip': useExtraFlip,
              }),
              child: const Text('Start Game'),
            ),
          ],
        ),
      );
    },
  );
}
