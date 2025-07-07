import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mem_game/core/providers/ad_provider.dart';
import 'package:mem_game/features/game/viewmodel/game_notifier.dart';

import 'package:mem_game/view/home_screen.dart';

void showGameDialog({
  required BuildContext context,
  required String title,
  required GameNotifier gameNotifier,
  required WidgetRef ref,
}) {
  // Determine if the game is lost.
  final isGameLost = !gameNotifier.checkWinCondition();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        // The original dialog always shows its default actions.
        return AlertDialog(
          title: Text(title),
          content: Text(
            'Your time: ${gameNotifier.gameState?.currentTime ?? 0} seconds\n'
            'Score: ${gameNotifier.gameState?.score ?? 0}',
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          alignment: Alignment.center,
          actions: [
            if (isGameLost)
              TextButton(
                onPressed: () {
                  // Show the rewarded ad.
                  ref.read(rewardedAdNotifierProvider.notifier).showAd((reward) {
                    // When the reward is earned, add the extra life.
                    gameNotifier.addExtraLife();
                    // Schedule closing the current dialog after this frame.
                    Future.delayed(Duration.zero, () {
                      Navigator.of(context).pop();
                      // Then show a new dialog with the continue option.
                      showDialog(
                        context: context,
                        barrierDismissible: false,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Extra Life Granted!'),
                            content: const Text('Your extra life is now active.'),
                            actionsAlignment: MainAxisAlignment.center,
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
                  });
                },
                child: const Text('Watch Ad to Refresh !'),
              ),

            TextButton(
              onPressed: () async {
                Navigator.of(context,).pop();
                await gameNotifier.restartGame();
              },
              child: const Text('Play Again'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await gameNotifier.exitGame();
                await Navigator.of(
                  context,
                ).pushReplacement(MaterialPageRoute<void>(builder: (_) => const HomeScreen()));
              },
              child: const Text('Home'),
            ),
          ],
        );
      },
    );
  });
}
