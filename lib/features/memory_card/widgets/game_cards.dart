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
        duration: const Duration(milliseconds: 800),
        transitionBuilder: (child, animation) {
          // Create a slide animation: the new board slides up from a little below.
          final slideAnimation = Tween<Offset>(
            begin: const Offset(0, 0.3),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOut),
          );

          // Create a scale animation: the new board scales up from 80% to full size.
          final scaleAnimation = Tween<double>(
            begin: 0.8,
            end: 1.0,
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOut),
          );

          // Create a fade animation: it fades in from 0 to full opacity.
          final fadeAnimation = Tween<double>(
            begin: 0.0,
            end: 1.0,
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOut),
          );

          return SlideTransition(
            position: slideAnimation,
            child: ScaleTransition(
              scale: scaleAnimation,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: child,
              ),
            ),
          );
        },
        // Use a key that depends on the current level so that a level change triggers the animation.
        child: GridView.builder(
          key: ValueKey(gameState.level),
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
              level: gameState.level,
            );
          },
        ),
      ),
    );
  }
}
