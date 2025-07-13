import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mem_game/core/providers/shop_provider.dart';
import 'package:mem_game/core/providers/user_provider.dart';
import 'package:mem_game/data/shop_item/model/shop_item.dart';

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    final user = ref.watch(userViewModelProvider)!;
    final userNotifier = ref.read(userViewModelProvider.notifier);
    final shopNotifier = ref.read(shopViewModelProvider.notifier);
    final shopItems = ref.watch(shopViewModelProvider);

    // Prices
    const int potionPrice = 100;
    const int flipPrice = 150;
    const int doubleCoinsPrice = 200;

    final canBuyPotion = user.coins >= potionPrice;
    final canBuyFlip = user.coins >= flipPrice;
    final canBuyDoubleCoins = user.coins >= doubleCoinsPrice;

    // Helper to get quantity
    int quantityOf(ShopItemType type) {
      return shopItems
          .firstWhere(
            (item) => item.itemType == type,
            orElse: () => ShopItem(userId: user.username, itemType: type, quantity: 0),
          )
          .quantity;
    }

    Widget buildShopCard({
      required IconData icon,
      required String title,
      required int price,
      required int quantity,
      required bool canBuy,
      required VoidCallback onBuy,
    }) {
      return Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Row(
            children: [
              Icon(icon, size: 40, color: theme.colorScheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text('You have: $quantity'),
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: canBuy ? onBuy : null,
                style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                child: Text('\$$price'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Shop')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Coins: ${user.coins}', style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
              const SizedBox(height: 24),

              // Health Potion
              buildShopCard(
                icon: Icons.favorite,
                title: 'Health Potion',
                price: potionPrice,
                quantity: quantityOf(ShopItemType.healthPotion),
                canBuy: canBuyPotion,
                onBuy: () async {
                  await userNotifier.purchaseCoins(potionPrice);
                  await shopNotifier.purchase(ShopItemType.healthPotion, potionPrice);
                },
              ),

              // Extra Flip
              buildShopCard(
                icon: Icons.rotate_left,
                title: 'Extra Flip',
                price: flipPrice,
                quantity: quantityOf(ShopItemType.extraFlip),
                canBuy: canBuyFlip,
                onBuy: () async {
                  await userNotifier.purchaseCoins(flipPrice);
                  await shopNotifier.purchase(ShopItemType.extraFlip, flipPrice);
                },
              ),

              // Double Coins
              buildShopCard(
                icon: Icons.monetization_on,
                title: 'Double Coins',
                price: doubleCoinsPrice,
                quantity: quantityOf(ShopItemType.doubleCoins),
                canBuy: canBuyDoubleCoins,
                onBuy: () async {
                  await userNotifier.purchaseCoins(doubleCoinsPrice);
                  await shopNotifier.purchase(ShopItemType.doubleCoins, doubleCoinsPrice);
                },
              ),

              const Spacer(),
              //     ElevatedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Back')),
            ],
          ),
        ),
      ),
    );
  }
}
