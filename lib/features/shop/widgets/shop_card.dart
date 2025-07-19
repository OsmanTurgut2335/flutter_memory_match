import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class ShopCard extends StatelessWidget {
  const ShopCard({
    required this.icon,
    required this.title,
    required this.price,
    required this.quantity,
    required this.canBuy,
    required this.onBuy,
    super.key,
  });

  final IconData icon;
  final String title;
  final int price;
  final int quantity;
  final bool canBuy;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 1,
      color: Colors.white,
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
                  Text('shop.quantity'.tr(namedArgs: {'count': quantity.toString()})),
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
}
