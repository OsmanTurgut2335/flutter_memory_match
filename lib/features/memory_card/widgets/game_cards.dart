
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
    final  screenWidth = size.width;
    final  screenHeight = size.height;

    const  spacing = 8.0;
    const double minCardSize = 72; 
    const double maxCardSize = 130;

    final  cardCount = gameState.cards.length;


    int optimalColumns = 1;
    double optimalCardSize = maxCardSize;

    for (int columns = 1; columns <= 10; columns++) {
      final  cardSize = (screenWidth - (columns - 1) * spacing) / columns;

      if (cardSize < minCardSize) break;

      final  rows = (cardCount / columns).ceil();
      final  totalHeight = rows * cardSize + (rows - 1) * spacing + 16; // alt boşluk

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
