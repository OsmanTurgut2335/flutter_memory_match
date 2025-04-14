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
        return 80;
      case 3:
        return 70;
      default:
        return 100;
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
          //    (We don't scale up if there's leftover space, so the grid won't exceed target size.)
          double scaleFactorWidth = 1.0;
          double scaleFactorHeight = 1.0;

          // If the ideal grid is wider than availableWidth, compute a horizontal scale factor.
          if (idealGridWidth > availableWidth) {
            scaleFactorWidth = availableWidth / idealGridWidth;
          }
          // If the ideal grid is taller than availableHeight, compute a vertical scale factor.
          if (idealGridHeight > availableHeight) {
            scaleFactorHeight = availableHeight / idealGridHeight;
          }

          // Take the smaller factor so we don't exceed either width or height.
          final double scaleFactor = min(scaleFactorWidth, scaleFactorHeight);

          // Final cell size after scaling down if needed.
          final double cellSize = targetSize * scaleFactor;

          // Final total grid size in pixels.
          final double finalGridWidth = columns * cellSize + (columns - 1) * spacing;
          final double finalGridHeight = rows * cellSize + (rows - 1) * spacing;

          // 5) We'll place the grid at the top-left so it covers from top to bottom.
          //    If it doesn't fill horizontally, leftover space will appear on the right.
          return SizedBox(
            width: constraints.maxWidth, // fill parent horizontally
            height: constraints.maxHeight, // fill parent vertically
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  top: 0,
                  // The grid is sized at finalGridWidth/Height
                  // so it occupies from top to bottom if finalGridHeight == constraints.maxHeight
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
                        childAspectRatio: 1.0, // force squares
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
