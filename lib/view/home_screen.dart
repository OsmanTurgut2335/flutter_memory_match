
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mem_game/core/providers/game_provider.dart';
import 'package:mem_game/core/providers/user_provider.dart';
import 'package:mem_game/data/game/repository/game_repository.dart';

import 'package:mem_game/features/user/widgets/user_options_menu.dart';
import 'package:mem_game/view/game_screen.dart';
import 'package:mem_game/view/scoreboard_screen.dart';


class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  Future<bool> _hasOngoingGame() async {
    // Use the GameRepository to check for an ongoing game.
    final gameRepo = GameRepository();
    return gameRepo.hasOngoingGame();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the current user from the user provider.
    final user = ref.watch(userViewModelProvider);
    final notifier = ref.read(userViewModelProvider.notifier);
    final gameNotifier = ref.read(gameNotifierProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Game Home'),
        actions: [
          UserPopUpMenu(
            notifier: notifier,
            gameNotifier: gameNotifier,
          )
        ],
      ),
      body: Center(
        child: user == null
            ? const Text('No user found. Please set up your username.')
            : FutureBuilder<bool>(
                future: _hasOngoingGame(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }

                  final hasOngoingGame = snapshot.data ?? false;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () async {
                          // Clear any existing game state
                          await ref.read(gameNotifierProvider.notifier).exitGame();
                          // Now, create a new game state.
                          await ref.read(gameNotifierProvider.notifier).restartGame();
                          // Navigate to GameScreen with resumeGame: false.
                          await Navigator.of(context).pushReplacement(
                            MaterialPageRoute(
                              builder: (_) => const GameScreen(resumeGame: false),
                            ),
                          );
                        },
                        child: const Text('New Game'),
                      ),
                      const SizedBox(height: 16),
                      if (hasOngoingGame)
                        ElevatedButton(
                          onPressed: () {
                            // Continue the saved game.
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => const GameScreen(resumeGame: true),
                              ),
                            );
                          },
                          child: const Text('Continue Game'),
                        ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          // Navigate to the leaderboard (scoreboard) screen.
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const LeaderboardScreen(),
                            ),
                          );
                        },
                        child: const Text('Scoreboard'),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}
