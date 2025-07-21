import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:mem_game/data/game/model/game_state_model.dart';
import 'package:mem_game/features/game/viewmodel/game_notifier.dart';
import 'package:mem_game/features/memory_card/widgets/memory_card_widget.dart';

class GameCards extends StatelessWidget {
  const GameCards({required this.gameState, required this.gameNotifier, super.key});

  final GameState gameState;
  final GameNotifier gameNotifier;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth;

        const spacing = 8.0;
        final cards = gameState.cards;
        final cardCount = cards.length;

        // Optimize number of columns based on screen width
        var optimalColumns = 2;
        for (var i = 2; i <= 6; i++) {
          final cardSize = (availableWidth - (i - 1) * spacing) / i;
          if (cardSize >= 72) optimalColumns = i;
        }

        return SizedBox.expand(
          child: MasonryGridView.count(
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: optimalColumns,
            mainAxisSpacing: spacing,
            crossAxisSpacing: spacing,
            itemCount: cardCount,
            itemBuilder: (context, index) {
              return AspectRatio(
                aspectRatio: 1,
                child: MemoryCardWidget(
                  card: cards[index],
                  onTap: () => gameNotifier.onCardTap(index),
                  level: gameState.level,
                ),
              );
            },
          ),
        );
      },
    );
  }
}
