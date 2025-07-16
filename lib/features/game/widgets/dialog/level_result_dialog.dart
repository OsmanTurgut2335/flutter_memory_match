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
          Text('Level: ${gameState!.level}', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text('Time: ${gameState!.currentTime}s', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text('Score: ${gameState!.score}', style: Theme.of(context).textTheme.bodyMedium),
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
                      title: const Text('Extra Life Granted!'),
                      content: const Text('You’ve been revived. Good luck!'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop(); 
                          },
                          child: const Text('Continue'),
                        ),
                      ],
                    );
                  },
                );
              });
            },
            child: const Text('Watch Ad for Extra Life'),
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
                child: const Text('Try Again'),
              ),
            if (isWin && !isFinal)
              TextButton(
                onPressed: () {
                  onDialogClosed?.call();
                  Navigator.of(context, rootNavigator: true).pop();
                  gameNotifier.advanceLevel();
                },
                child: const Text('Next Level'),
              ),

            if (isWin && isFinal)
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  gameNotifier.exitGame();
                  Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (_) => const HomeScreen()));
                },
                child: const Text('Finish Game'),
              ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                gameNotifier.exitGame();
                Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (_) => const HomeScreen()));
              },
              child: const Text('Home'),
            ),
          ],
        ),
      ],
    );
  }
}
