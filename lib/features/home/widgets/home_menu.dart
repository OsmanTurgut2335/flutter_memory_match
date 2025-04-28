import 'package:flutter/material.dart';

class HomeMenu extends StatelessWidget {
  const HomeMenu({
    required this.hasOngoingGame,
    required this.onNewGame,
    required this.onContinueGame,
    required this.onScoreboard,
    super.key,
  });

  final bool hasOngoingGame;
  final VoidCallback onNewGame;
  final VoidCallback onContinueGame;
  final VoidCallback onScoreboard;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min, // Use minimal space for the menu
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFA726), // Accent color
            foregroundColor: Colors.black87,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: onNewGame,
          child: const Text('New Game'),
        ),
        const SizedBox(height: 16),
        if (hasOngoingGame)
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFFA726),
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: onContinueGame,
            child: const Text('Continue Game'),
          ),
        const SizedBox(height: 16),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFA726),
            foregroundColor: Colors.black87,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: onScoreboard,
          child: const Text('Scoreboard'),
        ),
         ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFFA726), // Accent color
            foregroundColor: Colors.black87,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: onNewGame,
          child: const Text('Shop'),
        )
      ],
    );
  }
}
