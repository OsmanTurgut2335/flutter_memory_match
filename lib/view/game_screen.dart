import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mem_game/core/providers/game_provider.dart';
import 'package:mem_game/features/game/viewmodel/game_notifier.dart';
import 'package:mem_game/features/game/widgets/end_game_dialog.dart';
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
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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

  void _pauseGame() {
    setState(() {
      _isPaused = true;
    });
    ref.read(gameNotifierProvider.notifier).clearBestTime();
    ref.read(gameNotifierProvider.notifier).pauseGame();
  }

  void _resumeGame() {
    setState(() {
      _isPaused = false;
    });
    ref.read(gameNotifierProvider.notifier).resumeGame();
  }

  void _handleGameOver(GameNotifier gameNotifier) {

    showGameDialog(context: context, title: 'Game Over', gameNotifier: gameNotifier);
  }

  void _handleWin(GameNotifier gameNotifier) {

    showGameDialog(context: context, title: 'You Win! 🎉', gameNotifier: gameNotifier);
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameNotifierProvider);
    final gameNotifier = ref.read(gameNotifierProvider.notifier);

    if (gameState == null || _isInitializing) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (gameState.health <= 0) {
      _handleGameOver(gameNotifier);
    } else if (gameNotifier.checkWinCondition()) {
      // ✅ Check if game is won
      _handleWin(gameNotifier);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Game'),
        actions: [
          IconButton(icon: const Icon(Icons.pause), onPressed: _pauseGame),
          IconButton(icon: const Icon(Icons.play_arrow), onPressed: _resumeGame),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'exit') {
                await gameNotifier.exitGame();
                await Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
              } else if (value == 'homescreen') {
                _pauseGame();
                await gameNotifier.saveCurrentState();
                await Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(value: 'homescreen', child: Text('Home Screen')),
                  const PopupMenuItem(value: 'exit', child: Text('Exit Game')),
                ],
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
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
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
                    itemCount: gameState.cards.length,
                    itemBuilder: (context, index) {
                      return MemoryCardWidget(card: gameState.cards[index], onTap: () => gameNotifier.onCardTap(index));
                    },
                  ),
                ),
              ],
            ),
          ),
          if (_isPaused)
            Positioned.fill(
              child: ColoredBox(
                color: Colors.white.withOpacity(0.8),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Game Stopped', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    ElevatedButton(onPressed: _resumeGame, child: const Text('Resume Game')),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
