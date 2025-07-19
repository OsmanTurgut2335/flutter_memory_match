import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mem_game/core/providers/ad_provider.dart';
import 'package:mem_game/core/providers/game_provider.dart';
import 'package:mem_game/core/providers/shop_provider.dart';
import 'package:mem_game/features/game/viewmodel/game_notifier.dart';
import 'package:mem_game/features/game/widgets/boost_selection_background.dart';
import 'package:mem_game/features/game/widgets/dialog/level_result_dialog.dart';
import 'package:mem_game/features/game/widgets/game_screen_appbar.dart';
import 'package:mem_game/features/game/widgets/paused_game_overlay.dart';
import 'package:mem_game/features/game/widgets/row/bottom_level_flip_row.dart';
import 'package:mem_game/features/game/widgets/row/stats_row.dart';
import 'package:mem_game/features/game/widgets/score_bubble.dart';
import 'package:mem_game/features/memory_card/widgets/game_cards.dart';
import 'package:mem_game/features/shop/widgets/itemslist.dart';

import 'package:mem_game/view/home_screen.dart';

class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({required this.resumeGame, super.key});
  final bool resumeGame;

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> with TickerProviderStateMixin, WidgetsBindingObserver {
  final GlobalKey<ScoreBubbleState> _scoreBubbleKey = GlobalKey<ScoreBubbleState>();

  bool _isPaused = false;
  bool _isDialogOpen = false;

  late AnimationController _pauseController;
  late Animation<double> _pauseOpacity;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _pauseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _pauseOpacity = Tween<double>(begin: 0, end: 1).animate(_pauseController);

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final gameNotifier = ref.read(gameNotifierProvider.notifier);

      // Callbacks
      gameNotifier
        ..onScoreIncrease = (scoreText) {
          _scoreBubbleKey.currentState?.showIncrement(scoreText);
        }
        ..onGameResult = (result) {
          if (_isDialogOpen) return;
          _isDialogOpen = true;

          WidgetsBinding.instance.addPostFrameCallback((_) {
            showDialog<void>(
              context: context,
              barrierDismissible: false,
              builder:
                  (BuildContext context) => LevelResultDialog(
                    title: result == GameResult.win ? 'game.level_complete'.tr() : 'game.game_over'.tr(),

                    gameState: gameNotifier.gameState,
                    gameNotifier: gameNotifier,
                    isWin: result == GameResult.win,
                    onDialogClosed: () {
                      _isDialogOpen = false;
                    },
                  ),
            );
            _isDialogOpen = false;
          });
        };

      if (widget.resumeGame) {
        await gameNotifier.initializeGame(true);
        return;
      }

      final shopItems = ref.read(shopViewModelProvider);
      final selectedBoosts = await showBoostSelectionDialog(context, shopItems);
      if (selectedBoosts == null) await gameNotifier.initializeGame(false);

      final shopNotifier = ref.read(shopViewModelProvider.notifier);

      final usedHealth = selectedBoosts?['healthPotion'] == true;
      final usedDouble = selectedBoosts?['doubleCoins'] == true;
      final usedFlip = selectedBoosts?['extraFlip'] == true;

      if (usedHealth) await shopNotifier.useHealthPotion();
      if (usedDouble) await shopNotifier.useDoubleCoins();
      if (usedFlip) await shopNotifier.useExtraFlip();

      await gameNotifier.initializeGame(
        false,
        bonusHealth: usedHealth ? 1 : 0,
        doubleCoins: usedDouble,
        extraFlipCount: usedFlip ? 1 : 0,
      );

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

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameNotifierProvider);
    final gameNotifier = ref.read(gameNotifierProvider.notifier);

    if (gameState == null) {
      return const BoostSelectionBackground();
    }

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color.fromARGB(255, 120, 132, 219), Color.fromARGB(255, 219, 156, 96)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        appBar: GameScreenAppBar(
          onPause: _pauseGame,
          onResume: _resumeGame,
          onMenuSelected: (value) async {
            if (value == 'exit') {
              await gameNotifier.exitGame();
              await Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (_) => const HomeScreen()));
            } else if (value == 'homescreen') {
              _pauseGame();
              await gameNotifier.saveCurrentState();
              await Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (_) => const HomeScreen()));
            }
          },
        ),
        body: SafeArea(
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    StatsRow(gameState: gameState, scoreBubbleKey: _scoreBubbleKey),
                    const SizedBox(height: 16),
                    Expanded(child: GameCards(gameState: gameState, gameNotifier: gameNotifier)),
                    //  const SizedBox(height: 16),
                    const Spacer(),
                    BottomLevelFlipRow(gameState: gameState, gameNotifier: gameNotifier),
                  ],
                ),
              ),
              if (_isPaused) PausedGameOverlay(opacity: _pauseOpacity, onResume: _resumeGame),
            ],
          ),
        ),
      ),
    );
  }
}
