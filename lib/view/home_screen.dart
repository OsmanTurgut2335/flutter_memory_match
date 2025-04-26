import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:mem_game/core/painters/wave_painter.dart';
import 'package:mem_game/core/providers/add_provider.dart';
import 'package:mem_game/core/providers/game_provider.dart';
import 'package:mem_game/core/providers/user_provider.dart';
import 'package:mem_game/data/game/repository/game_repository.dart';
import 'package:mem_game/features/home/widgets/home_menu.dart';
import 'package:mem_game/features/user/widgets/user_options_menu.dart';
import 'package:mem_game/view/game_screen.dart';
import 'package:mem_game/view/scoreboard_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _lottieController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _lottieController = AnimationController(vsync: this);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final gameNotifier = ref.read(gameNotifierProvider.notifier)..onScoreIncrease = (scoreText) {};

      if (ref.read(gameNotifierProvider) == null) {
        gameNotifier.initializeGame(false);
      }
      ref.read(rewardedAdNotifierProvider.notifier).loadAd();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _lottieController.dispose();
    super.dispose();
  }

  Future<bool> _hasOngoingGame() async {
    final gameRepo = GameRepository();
    return gameRepo.hasOngoingGame();
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userViewModelProvider);
    final gameNotifier = ref.read(gameNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Game Home'),
        actions: [UserActionsButton(notifier: ref.read(userViewModelProvider.notifier), gameNotifier: gameNotifier)],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF4C5BD4), // Indigo-blue
              Color(0xFFD68C45), // Warm accent
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Wave overlay at the top
            const SizedBox(
              height: 150,
              width: double.infinity,
              child: CustomPaint(painter: WavePainter(color: Colors.white)),
            ),
            // Main content
            Center(
              child:
                  user == null
                      ? const Text(
                        'No user found. Please set up your username.',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      )
                      : FutureBuilder<bool>(
                        future: _hasOngoingGame(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }
                          final hasOngoingGame = snapshot.data ?? false;

                          return HomeMenu(
                            hasOngoingGame: hasOngoingGame,
                            onNewGame: () async {
                              await ref.read(gameNotifierProvider.notifier).exitGame();
                              await ref.read(gameNotifierProvider.notifier).restartGame();
                              await Navigator.of(
                                context,
                              ).pushReplacement(MaterialPageRoute(builder: (_) => const GameScreen(resumeGame: false)));
                            },
                            onContinueGame: () {
                              gameNotifier.pauseGame();
                              Navigator.of(
                                context,
                              ).pushReplacement(MaterialPageRoute(builder: (_) => const GameScreen(resumeGame: true)));
                            },
                            onScoreboard: () {
                              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LeaderboardScreen()));
                            },
                          );
                        },
                      ),
            ),
            // Lottie animation at the bottom
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SizedBox(
                  width: 150,
                  height: 150,
                  child: Lottie.asset(
                    'assets/lottie/background_pattern.json',
                    controller: _lottieController,
                    fit: BoxFit.contain,
                    onLoaded: (composition) {
                      _lottieController
                        ..duration = composition.duration * 2
                        ..repeat();
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
