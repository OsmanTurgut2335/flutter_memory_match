import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mem_game/core/painters/wave_painter.dart';
import 'package:mem_game/core/providers/ad_provider.dart';
import 'package:mem_game/core/providers/env_provider.dart';
import 'package:mem_game/core/providers/game_provider.dart';
import 'package:mem_game/core/providers/user_provider.dart';
import 'package:mem_game/core/widgets/lottie_background.dart';
import 'package:mem_game/data/game/repository/game_repository.dart';
import 'package:mem_game/features/home/widgets/home_menu.dart';
import 'package:mem_game/features/user/widgets/user_options_menu.dart';
import 'package:mem_game/view/game_screen.dart';
import 'package:mem_game/view/scoreboard_screen.dart';
import 'package:mem_game/view/shop_screen.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final gameNotifier = ref.read(gameNotifierProvider.notifier)..onScoreIncrease = (scoreText) {};

 
      final user = ref.read(userRepositoryProvider).getUser();
      final gameRepo = GameRepository(ref.watch(envConfigProvider));
      final bool hasHiveGame;
      if (user != null) {
        hasHiveGame = await gameRepo.hasOngoingGame(user.username);
      } else {
        hasHiveGame = false;
      }

      if (!hasHiveGame) {
      
        if (ref.read(gameNotifierProvider) != null) {
          await gameNotifier.exitGame();
        }
      }

      await ref.read(rewardedAdNotifierProvider.notifier).loadAd();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _lottieController.dispose();
    super.dispose();
  }

  Future<bool> _hasOngoingGame() async {
      final gameRepo = GameRepository(ref.watch(envConfigProvider));
    final user = ref.read(userRepositoryProvider).getUser();

    if (user == null) return false;

    return gameRepo.hasOngoingGame(user.username);
  }

  @override
  Widget build(BuildContext context) {
    ref..watch(userViewModelProvider)
    ..read(gameNotifierProvider.notifier);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4C5BD4), Color(0xFFD68C45)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,

          title: Text('memoryHome'.tr()),
          actions: const [UserActionsButton()],
        ),
        body: Stack(
          children: [
           
            const SizedBox(
              height: 150,
              width: double.infinity,
              child: CustomPaint(painter: WavePainter(color: Colors.white)),
            ),
            // Main content
            Center(
              child:
               FutureBuilder<bool>(
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

                              await Navigator.of(context).pushReplacement(
                                MaterialPageRoute<void>(builder: (_) => const GameScreen(resumeGame: false)),
                              );
                            },
                            onContinueGame: () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute<void>(builder: (_) => const GameScreen(resumeGame: true)),
                              );
                            },
                            onScoreboard: () {
                              Navigator.of(
                                context,
                              ).push(MaterialPageRoute<void>(builder: (_) => const LeaderboardScreen()));
                            },
                            onShop: () {
                              Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const ShopScreen()));
                            },
                          );
                        },
                      ),
            ),
            const LottieBackground(),
          ],
        ),
      ),
    );
  }
}
