import 'package:flutter/material.dart';
import 'package:mem_game/features/game/viewmodel/game_notifier.dart';
import 'package:mem_game/view/home_screen.dart';

void showGameDialog({
  required BuildContext context,
  required String title,
  required GameNotifier gameNotifier,
}) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(
          'Your time: ${gameNotifier.gameState?.currentTime ?? 0} seconds\n'
          'Score: ${gameNotifier.gameState?.score ?? 0}',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              gameNotifier.restartGame();
            },
            child: const Text('Play Again'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await gameNotifier.exitGame();
              await Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
              );
            },
            child: const Text('Home'),
          ),
        ],
      ),
    );
  });
}
