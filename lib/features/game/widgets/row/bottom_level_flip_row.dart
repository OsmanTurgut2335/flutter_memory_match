import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mem_game/data/game/model/game_state_model.dart';
import 'package:mem_game/features/game/viewmodel/game_notifier.dart';

class BottomLevelFlipRow extends StatelessWidget {
  const BottomLevelFlipRow({required this.gameState, required this.gameNotifier, super.key});

  final GameState? gameState;
  final GameNotifier gameNotifier;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool canFlip = (gameState?.flipCount ?? 0) > 0;

    return Container(
      color: Colors.transparent,
      //   padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'game.level'.tr(namedArgs: {'number': (gameState?.level ?? 1).toString()}),
            style: theme.textTheme.titleMedium,
          ),
          ElevatedButton.icon(
            onPressed: canFlip ? gameNotifier.flipCardsOnButtonPress : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
            icon: const Icon(Icons.flip_camera_android_outlined),

            label: Text('game.flip_cards'.tr()),
          ),
        ],
      ),
    );
  }
}
