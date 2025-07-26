import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mem_game/core/providers/ad_provider.dart';
import 'package:mem_game/data/game/model/game_state_model.dart';
import 'package:mem_game/features/game/viewmodel/game_notifier.dart';

import 'package:mem_game/view/home_screen.dart';

class LevelResultDialog extends ConsumerWidget {
  const LevelResultDialog({
    required this.title,
    required this.gameState,
    required this.gameNotifier,
    required this.isWin,
    required this.onDialogClosed,
    super.key,
  });

  final String title;
  final GameState? gameState;
  final GameNotifier gameNotifier;
  final bool isWin;
  final VoidCallback? onDialogClosed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFinal = gameState!.level == 7;

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: Center(
        child: Text(title, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${'result.level'.tr()}: ${gameState!.level}', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('${'stats.time'.tr()}: ${gameState!.currentTime}s', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('${'stats.score'.tr()}: ${gameState!.score}', style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      actions: [
        if (!isWin && !gameNotifier.hasUsedAd)
          TextButton(
            onPressed: () {
              ref.read(rewardedAdNotifierProvider.notifier).showAd((reward) {
                gameNotifier
                  ..addExtraLife()
                  ..markAdUsed();

                Navigator.of(context).pop();

                showDialog<void>(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) {
                    return AlertDialog(
                      title: Text('result.extraLifeTitle'.tr()),
                      content: Text('result.extraLifeDesc'.tr()),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: Text('result.continue'.tr()),
                        ),
                      ],
                    );
                  },
                );
              });
            },
            child: Text('result.watchAd'.tr()),
          ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isWin)
              TextButton(
                onPressed: () {
                  Navigator.of(context, rootNavigator: true).pop();
                  gameNotifier.restartGame();
                },
                child: Text('result.tryAgain'.tr()),
              ),
            if (isWin && !isFinal)
              TextButton(
                onPressed: () {
                  onDialogClosed?.call();
                  Navigator.of(context, rootNavigator: true).pop();
                  gameNotifier.advanceLevel();
                },
                child: Text('result.nextLevel'.tr()),
              ),

            if (isWin && isFinal)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  gameNotifier.exitGame();
                  Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (_) => const HomeScreen()));
                },
                child: Text('result.finishGame'.tr()),
              ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                gameNotifier.exitGame();
                Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (_) => const HomeScreen()));
              },
              child: Text('result.home'.tr()),
            ),
          ],
        ),
      ],
    );
  }
}
