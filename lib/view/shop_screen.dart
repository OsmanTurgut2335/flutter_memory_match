import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mem_game/core/providers/shop_provider.dart';
import 'package:mem_game/core/providers/user_provider.dart';
import 'package:mem_game/data/shop_item/model/shop_item.dart';

///TODO ADD WATCH AD FOR 20 COİNS FEATURE

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    // Kullanıcı ve notifier'lar
    final user = ref.watch(userViewModelProvider)!;
    final userNotifier = ref.read(userViewModelProvider.notifier);
    final shopNotifier = ref.read(shopViewModelProvider.notifier);
    final shopItems = ref.watch(shopViewModelProvider);

    const int potionPrice = 100;
    final canBuy = user.coins >= potionPrice;

    // Health potion varsa adedini bulalım
    final healthPotion = shopItems.firstWhere(
      (item) => item.itemType == ShopItemType.healthPotion,
      orElse: () => ShopItem(userId: user.username, itemType: ShopItemType.healthPotion, quantity: 0),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Shop')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Coins: ${user.coins}', style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
            const SizedBox(height: 24),

            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.favorite, size: 40, color: theme.colorScheme.primary),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Health Potion', style: theme.textTheme.titleMedium),
                          const SizedBox(height: 4),
                          Text('You have: ${healthPotion.quantity}'),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed:
                          canBuy
                              ? () async {
                                await userNotifier.purchaseCoins(potionPrice);
                                await shopNotifier.purchase(ShopItemType.healthPotion, potionPrice);
                              }
                              : null,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      child: Text('\$$potionPrice'),
                    ),
                  ],
                ),
              ),
            ),

            const Spacer(),
            ElevatedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Back')),
          ],
        ),
      ),
    );
  }
}
