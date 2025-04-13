import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mem_game/core/providers/add_provider.dart';
import 'package:mem_game/features/game/viewmodel/game_notifier.dart';
import 'package:mem_game/view/home_screen.dart';

class LevelResultDialog extends ConsumerWidget {
  const LevelResultDialog({required this.title, required this.gameNotifier, required this.isWin, super.key});

  final String title;
  final GameNotifier gameNotifier;
  final bool isWin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = gameNotifier.gameState!;
    final isFinal = stats.level == 3;

    return AlertDialog(
      // Give the dialog rounded corners (optional)
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      // Use your theme's surface color or define a custom one
      backgroundColor: Theme.of(context).colorScheme.surface,

      // Title
      title: Center(
        child: Text(
          title,
          // Use a style from your ThemeData; fallback to default if null
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            // If you need to override color, e.g. color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // Content
      content: Column(
        // Minimize the height to just what the children need
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Level: ${stats.level}', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8), // spacing
          Text('Time: ${stats.currentTime}s', style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text('Score: ${stats.score}', style: Theme.of(context).textTheme.bodyMedium),
        ],
      ),

      // Set how the row of actions is laid out horizontally
      actionsPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      // Removing actionsAlignment if you plan to use a Row of custom layout
      actions: [
        // Show 'Watch Ad...' only if the user lost and hasn't used an ad
         if (!isWin)
     TextButton(
    onPressed: () {
      ref.read(rewardedAdNotifierProvider.notifier).showAd((reward) {
        gameNotifier..addExtraLife()
        ..markAdUsed();  
        Navigator.of(context,rootNavigator: true).pop();
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
