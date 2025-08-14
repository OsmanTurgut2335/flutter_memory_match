import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mem_game/data/game/model/game_state_model.dart';
import 'package:mem_game/features/game/viewmodel/game_notifier.dart';

class BottomLevelFlipRow extends StatelessWidget {
  const BottomLevelFlipRow({required this.gameState, required this.gameNotifier, this.hasSkipLevel = false, super.key});

  final GameState? gameState;
  final GameNotifier gameNotifier;
  final bool hasSkipLevel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canFlip = (gameState?.flipCount ?? 0) > 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'game.level'.tr(namedArgs: {'number': (gameState?.level ?? 1).toString()}),
          style: theme.textTheme.titleMedium,
        ),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: canFlip ? gameNotifier.flipCardsOnButtonPress : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
              icon: const Icon(Icons.flip_camera_android_outlined),
              label: Text('game.flip_cards'.tr()),
            ),
            if (hasSkipLevel) ...[
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: (gameNotifier.user?.skipLevelUsed ?? false)
                    ? null
                    : gameNotifier.useSkipLevelBoost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.secondary,
                  foregroundColor: theme.colorScheme.onSecondary,
                ),
                icon: const Icon(Icons.fast_forward),
                label: Text('game.skip_level'.tr()),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
