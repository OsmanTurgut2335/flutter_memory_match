import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mem_game/core/providers/game_provider.dart';

import 'package:mem_game/features/memory_card/widgets/memory_card_widget.dart';
import 'package:mem_game/view/home_screen.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({required this.resumeGame, super.key});
  final bool resumeGame;

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> with WidgetsBindingObserver {
  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Delay the initialization until after the first frame.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifier = ref.read(gameNotifierProvider.notifier);
      if (ref.read(gameNotifierProvider) == null && !_isInitializing) {
        _isInitializing = true;
        notifier.initializeGame(widget.resumeGame).then((_) {
          if (mounted) {
            setState(() {
              _isInitializing = false;
            });
          }
        });
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      ref.read(gameNotifierProvider.notifier).saveCurrentState();
    }
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameNotifierProvider);
    final gameNotifier = ref.read(gameNotifierProvider.notifier);

    // If still initializing, show a loader.
    if (gameState == null || _isInitializing) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // Game over logic (if needed) goes here.
    if (gameState.health <= 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              title: const Text("Game Over"),
              content: Text("Your time: ${gameState.currentTime} seconds\nScore: ${gameState.score}"),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    gameNotifier.restartGame();
                  },
                  child: const Text("Restart"),
                ),
                TextButton(
                  onPressed: () async {
                    Navigator.of(context).pop();
                    await gameNotifier.exitGame();
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const HomeScreen()),
                    );
                  },
                  child: const Text("Home"),
                ),
              ],
            );
          },
        );
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Game'),
        actions: [
          IconButton(
            icon: const Icon(Icons.pause),
            onPressed: gameNotifier.pauseGame,
          ),
          IconButton(
            icon: const Icon(Icons.play_arrow),
            onPressed: gameNotifier.resumeGame,
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'exit') {
                await gameNotifier.exitGame();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              } else if (value == 'homescreen') {
                gameNotifier.pauseGame();
                await gameNotifier.saveCurrentState();
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'homescreen', child: Text('Home Screen')),
              const PopupMenuItem(value: 'exit', child: Text('Exit Game')),
            ],
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Game metrics display.
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
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  childAspectRatio: 1.0,
                ),
                itemCount: gameState.cards.length,
                itemBuilder: (context, index) {
                  return MemoryCardWidget(
                    card: gameState.cards[index],
                    onTap: () => gameNotifier.onCardTap(index),
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
