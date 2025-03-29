import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mem_game/core/providers/game_provider.dart';

import 'package:mem_game/features/memory_card/widgets/memory_card_widget.dart';

class GameScreen extends ConsumerWidget {
  const GameScreen({required this.resumeGame, super.key});

  /// If true, resume a saved game; otherwise, start a new game.
  final bool resumeGame;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // If necessary, you could trigger initialization here:
    // ref.read(gameNotifierProvider.notifier).initializeGame(resumeGame);

    final gameState = ref.watch(gameNotifierProvider);

    if (gameState == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Memory Game')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Display game metrics.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text('Moves: ${gameState.moves}'),
                Text('Score: ${gameState.score}'),
                Text('Time: ${gameState.currentTime}'),
                Text('Health: ${gameState.health}'),
              ],
            ),
            const SizedBox(height: 16),
            // Display grid of memory cards.
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                ),
                itemCount: gameState.cards.length,
                itemBuilder: (context, index) {
                  return MemoryCardWidget(
                    card: gameState.cards[index],
                    onTap: () {
                      ref
                          .read(gameNotifierProvider.notifier)
                          .onCardTap(index);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
