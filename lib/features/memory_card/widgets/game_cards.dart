import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mem_game/data/game/model/game_state_model.dart';
import 'package:mem_game/features/game/viewmodel/game_notifier.dart';
import 'package:mem_game/features/memory_card/widgets/memory_card_widget.dart';

class GameCards extends StatelessWidget {
  const GameCards({required this.gameState, required this.gameNotifier, super.key});

  final GameState gameState;
  final GameNotifier gameNotifier;

  /// Returns a "target" card size (in pixels) based on the level.
  double _targetCardSize(int level) {
    switch (level) {
      case 1:
        return 100;
      case 2:
        return 100;
      case 3:
        return 100;
      default:
        return 70;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      // Use LayoutBuilder to figure out how much space is available
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double availableWidth = constraints.maxWidth;
          final double availableHeight = constraints.maxHeight;

          const double spacing = 8.0;
          final double targetSize = _targetCardSize(gameState.level);
          final int cardCount = gameState.cards.length;

          // 1) Compute how many columns can fit at the target size + spacing:
          int columns = (availableWidth / (targetSize + spacing)).floor();
          if (columns < 1) columns = 1;

          // 2) Compute how many rows are needed (round up if cards don't fit exactly).
          final int rows = (cardCount / columns).ceil();

          // 3) Calculate the "ideal" grid width/height if we used targetSize exactly.
          final double idealGridWidth = columns * targetSize + (columns - 1) * spacing;
          final double idealGridHeight = rows * targetSize + (rows - 1) * spacing;

          // 4) If the grid is taller or wider than what's available, we scale down uniformly.

          final double scaleFactorWidth = availableWidth / idealGridWidth;
          final double scaleFactorHeight = availableHeight / idealGridHeight;
          // ekran ne kadar izin veriyorsa, o oranda küçült ya da büyüt
          final double scaleFactor = min(scaleFactorWidth, scaleFactorHeight);
          final double cellSize = targetSize * scaleFactor;

          // Final total grid size in pixels.
          final double finalGridWidth = columns * cellSize + (columns - 1) * spacing;
          final double finalGridHeight = rows * cellSize + (rows - 1) * spacing;

          return SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,

                  child: SizedBox(
                    width: finalGridWidth,
                    height: finalGridHeight,
                    child: GridView.builder(
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: columns,
                        crossAxisSpacing: spacing,
                        mainAxisSpacing: spacing,
                      ),
                      itemCount: cardCount,
                      itemBuilder: (context, index) {
                        return SizedBox(
                          width: cellSize,
                          height: cellSize,
                          child: MemoryCardWidget(
                            card: gameState.cards[index],
                            onTap: () => gameNotifier.onCardTap(index),
                            level: gameState.level,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
