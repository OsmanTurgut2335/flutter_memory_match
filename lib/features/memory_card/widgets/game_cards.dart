// lib/features/game/widgets/gamecards.dart
import 'package:flutter/material.dart';
import 'package:mem_game/data/game/model/game_state_model.dart';
import 'package:mem_game/features/game/viewmodel/game_notifier.dart';
import 'package:mem_game/features/memory_card/widgets/memory_card_widget.dart';

class GameCards extends StatelessWidget {
  const GameCards({
    required this.gameState,
    required this.gameNotifier,
    super.key,
  });

  final GameState gameState;
  final GameNotifier gameNotifier;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: GridView.builder(
          key: ValueKey<int>(gameState.cards.length),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 150,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: gameState.cards.length,
          itemBuilder: (context, index) {
            return MemoryCardWidget(
              card: gameState.cards[index],
              onTap: () => gameNotifier.onCardTap(index),
              level: gameState.level,  // Pass level from the game state.
            );
          },
        ),
      ),
    );
  }
}
