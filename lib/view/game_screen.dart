import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mem_game/core/providers/ad_provider.dart';
import 'package:mem_game/core/providers/game_provider.dart';
import 'package:mem_game/core/providers/shop_provider.dart';
import 'package:mem_game/data/game/model/game_state_model.dart';
import 'package:mem_game/data/shop_item/model/shop_item.dart';
import 'package:mem_game/features/game/viewmodel/game_notifier.dart';
import 'package:mem_game/features/game/widgets/dialog/level_result_dialog.dart';
import 'package:mem_game/features/game/widgets/game_screen_appbar.dart';
import 'package:mem_game/features/game/widgets/score_bubble.dart';
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
  final GlobalKey<ScoreBubbleState> _scoreBubbleKey = GlobalKey<ScoreBubbleState>();

  bool _isInitializing = false;
  bool _isPaused = false;
  late AnimationController _pauseController;
  late Animation<double> _pauseOpacity;
  final bool _showScorePopup = false;
  final String _popupText = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Controller for fade animation on pause overlay.
    _pauseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _pauseOpacity = Tween<double>(begin: 0, end: 1).animate(_pauseController);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final gameNotifier = ref.read(gameNotifierProvider.notifier)
        ..onScoreIncrease = (scoreText) {
          _scoreBubbleKey.currentState?.showIncrement(scoreText);
        };

      if (!widget.resumeGame) {
        // Load shop items to ensure latest data
        final shopNotifier = ref.read(shopViewModelProvider.notifier);
        await shopNotifier.loadAll();

        final shopItems = ref.read(shopViewModelProvider);
        final hasPotion = shopItems.any((item) => item.itemType == ShopItemType.healthPotion && item.quantity > 0);

        bool usedPotion = false;
        if (hasPotion) {
          final use = await showDialog<bool>(
            context: context,
            builder:
                (_) => AlertDialog(
                  title: const Text('Health Potion'),
                  content: const Text('You have a Health Potion. Do you want to use it before the game starts?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('No')),
                    TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Yes')),
                  ],
                ),
          );

          if (use == true) {
            await shopNotifier.useHealthPotion();
            usedPotion = true;
          }
        }

        await gameNotifier.initializeGame(widget.resumeGame, bonusHealth: usedPotion ? 1 : 0);
      } else {
        // Resume existing game without health boost
        await gameNotifier.initializeGame(widget.resumeGame, bonusHealth: 0);
      }

      if (mounted) setState(() => _isInitializing = false);

      await ref.read(rewardedAdNotifierProvider.notifier).loadAd();
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

  void _handleGameOver(GameNotifier notifier) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (_) => LevelResultDialog(
              title: 'Game Over',
              gameState: notifier.gameState,
              gameNotifier: notifier,
              isWin: false,
            ),
      );
    });
  }

  void _handleWin(GameNotifier notifier) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder:
            (_) => LevelResultDialog(
              title: 'Level Complete! 🎉',
              gameState: notifier.gameState,
              gameNotifier: notifier,
              isWin: true,
            ),
      );
    });
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
            await Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
          } else if (value == 'homescreen') {
            _pauseGame();
            await gameNotifier.saveCurrentState();
            await Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
          }
        },
      ),

      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                StatsRow(gameState: gameState, scoreBubbleKey: _scoreBubbleKey),
                const SizedBox(height: 16),

                //GameCards(gameState: gameState, gameNotifier: gameNotifier),
                Expanded(child: GameCards(gameState: gameState, gameNotifier: gameNotifier)),
                const SizedBox(height: 16),

                BottomLevelFlipRow(gameState: gameState, gameNotifier: gameNotifier),
              ],
            ),
          ),

          if (_isPaused) pausedGameWidget(),

          // A popup that appears near the stats row (adjust top/right accordingly).
          if (_showScorePopup)
            Positioned(
              top: 80, // Adjust this value so it appears near your Score field.
              right: 16,
              child: AnimatedOpacity(
                opacity: _showScorePopup ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _popupText,
                    style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
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
          color: Colors.black.withValues(alpha: 0.7),
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

class BottomLevelFlipRow extends StatelessWidget {
  const BottomLevelFlipRow({required this.gameState, required this.gameNotifier, super.key});

  final GameState? gameState;
  final GameNotifier gameNotifier;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text('Level: ${gameState?.level ?? 1}', style: Theme.of(context).textTheme.titleMedium),
          ElevatedButton.icon(
            onPressed: gameState?.canRevealCards == true ? gameNotifier.flipCardsOnButtonPress : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
            ),
            icon: const Icon(Icons.flip_camera_android_outlined),
            label: const Text('Flip Cards'),
          ),
        ],
      ),
    );
  }
}

/// Animated stats row
class StatsRow extends StatelessWidget {
  const StatsRow({required this.gameState, required this.scoreBubbleKey, super.key});

  final GameState gameState;
  final GlobalKey<ScoreBubbleState> scoreBubbleKey;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        StatBubble(label: 'Moves', value: gameState.moves.toString()),
        // Use ScoreBubble here with the provided key:
        ScoreBubble(key: scoreBubbleKey, label: 'Score', value: gameState.score.toString()),
        StatBubble(label: 'Time', value: gameState.currentTime.toString()),
        StatBubble(label: 'Health', value: gameState.health.toString()),
      ],
    );
  }
}
