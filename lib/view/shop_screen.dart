import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mem_game/core/constants/textstyles/app_text_styles.dart';
import 'package:mem_game/core/providers/shop_provider.dart';
import 'package:mem_game/core/providers/user_provider.dart';
import 'package:mem_game/core/widgets/common_screen_wrapper.dart';
import 'package:mem_game/data/shop_item/model/shop_item.dart';
import 'package:mem_game/features/shop/widgets/shop_card.dart';

class ShopScreen extends ConsumerWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userViewModelProvider);
    final userNotifier = ref.read(userViewModelProvider.notifier);
    final shopNotifier = ref.read(shopViewModelProvider.notifier);

    return Scaffold(
      body: CommonScreenWrapper(
        title: 'shop.title'.tr(), 
        child: userAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, st) => Center(child: Text('shop.error'.tr(namedArgs: {'error': e.toString()}))), 
          data: (user) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'shop.coins'.tr(namedArgs: {'value': user.coins.toString()}),
                  style: AppTextStyles.leaderboardHeader,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                ShopCard(
                  icon: Icons.favorite,
                  title: 'shop.health_potion'.tr(),
                  price: 1000,
                  quantity: shopNotifier.quantityOf(ShopItemType.healthPotion),
                  canBuy: shopNotifier.canBuy(ShopItemType.healthPotion),
                  onBuy: () async {
                    await userNotifier.purchaseCoins(100);
                    await shopNotifier.purchase(ShopItemType.healthPotion, 100);
                  },
                ),

                ShopCard(
                  icon: Icons.rotate_left,
                  title: 'shop.extra_flip'.tr(),
                  price: 1500,
                  quantity: shopNotifier.quantityOf(ShopItemType.extraFlip),
                  canBuy: shopNotifier.canBuy(ShopItemType.extraFlip),
                  onBuy: () async {
                    await userNotifier.purchaseCoins(150);
                    await shopNotifier.purchase(ShopItemType.extraFlip, 150);
                  },
                ),

                ShopCard(
                  icon: Icons.monetization_on,
                  title: 'shop.double_coins'.tr(),
                  price: 2000,
                  quantity: shopNotifier.quantityOf(ShopItemType.doubleCoins),
                  canBuy: shopNotifier.canBuy(ShopItemType.doubleCoins),
                  onBuy: () async {
                    await userNotifier.purchaseCoins(200);
                    await shopNotifier.purchase(ShopItemType.doubleCoins, 200);
                  },
                ),

                const Spacer(),
              ],
            );
          },
        ),
      ),
    );
  }
}
