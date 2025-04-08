import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mem_game/core/providers/add_provider.dart';
import 'package:mem_game/core/providers/game_provider.dart';
import 'package:mem_game/data/game/model/game_state_model.dart';
import 'package:mem_game/features/game/viewmodel/game_notifier.dart';
import 'package:mem_game/features/game/widgets/end_game_dialog.dart';
import 'package:mem_game/features/game/widgets/game_screen_appbar.dart';
import 'package:mem_game/features/game/widgets/stat_bubble.dart';
import 'package:mem_game/features/memory_card/widgets/game_cards.dart';

import 'package:mem_game/view/home_screen.dart';


class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({required this.resumeGame, super.key});
  final bool resumeGame;

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> with TickerProviderStateMixin, WidgetsBindingObserver {
  bool _isInitializing = false;
  bool _isPaused = false;
  late AnimationController _pauseController;
  late Animation<double> _pauseOpacity;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Controller for fade animation on pause overlay.
    _pauseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _pauseOpacity = Tween<double>(begin: 0, end: 1).animate(_pauseController);

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
      // Preload the rewarded ad.
      ref.read(rewardedAdNotifierProvider.notifier).loadAd();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pauseController.dispose();
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
    _pauseController.forward();
    ref.read(gameNotifierProvider.notifier).clearBestTime();
    ref.read(gameNotifierProvider.notifier).pauseGame();
  }

  void _resumeGame() {
    setState(() {
      _isPaused = false;
    });
    _pauseController.reverse();
    ref.read(gameNotifierProvider.notifier).resumeGame();
  }

  void _handleGameOver(GameNotifier gameNotifier) {
    showGameDialog(context: context, title: 'Game Over', gameNotifier: gameNotifier, ref: ref);
  }

  void _handleWin(GameNotifier gameNotifier) {
    showGameDialog(context: context, title: 'You Win! 🎉', gameNotifier: gameNotifier, ref: ref);
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
      _handleWin(gameNotifier);
    }

    return Scaffold(
    appBar: GameScreenAppBar(
        onPause: _pauseGame,
        onResume: _resumeGame,
        onMenuSelected: (value) async {
          if (value == 'exit') {
            await gameNotifier.exitGame();
            await Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
            );
          } else if (value == 'homescreen') {
            _pauseGame();
            await gameNotifier.saveCurrentState();
            await Navigator.of(context).pushReplacement(
              MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
            );
          }
        },
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                StatsRow(gameState: gameState),
                const SizedBox(height: 16),
                GameCards(gameState: gameState, gameNotifier: gameNotifier),
              ],
            ),
          ),
          
          if (_isPaused)
            pausedGameWidget(),
        ],
      ),
    );
  }

 
/// Pause overlay with fade animation.
  Positioned pausedGameWidget() {
    return Positioned.fill(
            child: FadeTransition(
              opacity: _pauseOpacity,
              child: ColoredBox(
                color: Colors.black.withOpacity(0.6),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Game Paused',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(onPressed: _resumeGame, child: const Text('Resume Game')),
                  ],
                ),
              ),
            ),
          );
  }
}



/// Animated stats row
class StatsRow extends StatelessWidget {
  const StatsRow({
    required this.gameState, super.key,
  });

  final GameState gameState;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      builder: (context, value, child) {
        return Opacity(opacity: value, child: child);
      },
      child:      Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        StatBubble(label: 'Moves', value: gameState.moves.toString()),
        StatBubble(label: 'Score', value: gameState.score.toString()),
        StatBubble(label: 'Time', value: gameState.currentTime.toString()),
        StatBubble(label: 'Health', value: gameState.health.toString()),
      ],
    ),
    );
  }
}
