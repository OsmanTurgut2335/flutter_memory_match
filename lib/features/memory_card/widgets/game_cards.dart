import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mem_game/data/game/model/game_state_model.dart';
import 'package:mem_game/features/game/viewmodel/game_notifier.dart';
import 'package:mem_game/features/memory_card/widgets/memory_card_widget.dart';

class GameCards extends StatelessWidget {
  const GameCards({required this.gameState, required this.gameNotifier, super.key});

  final GameState gameState;
  final GameNotifier gameNotifier;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final double screenWidth = size.width;
    final double screenHeight = size.height;

    const double spacing = 8.0;
    const double minCardSize = 72; // Shimmer + shadow + padding için ideal alt limit
    const double maxCardSize = 130;

    final int cardCount = gameState.cards.length;

    // En uygun sütun sayısını ve kart boyutunu bul
    int optimalColumns = 1;
    double optimalCardSize = maxCardSize;

    for (int columns = 1; columns <= 10; columns++) {
      final double cardSize = (screenWidth - (columns - 1) * spacing) / columns;

      if (cardSize < minCardSize) break;

      final int rows = (cardCount / columns).ceil();
      final double totalHeight = rows * cardSize + (rows - 1) * spacing + 16; // alt boşluk

      if (totalHeight <= screenHeight) {
        optimalColumns = columns;
        optimalCardSize = cardSize;
      }
    }

    return Padding(
      padding: const EdgeInsets.all(8),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        itemCount: cardCount,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: optimalColumns,
          mainAxisSpacing: spacing,
          crossAxisSpacing: spacing,
          childAspectRatio: 1, // kare
        ),
        itemBuilder: (context, index) {
          return SizedBox(
            width: optimalCardSize,
            height: optimalCardSize,
            child: MemoryCardWidget(
              card: gameState.cards[index],
              onTap: () => gameNotifier.onCardTap(index),
              level: gameState.level,
            ),
          );
        },
      ),
    );
  }
}
