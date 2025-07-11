import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mem_game/core/providers/scoreboard_provider.dart'; 
import 'package:mem_game/data/score/model.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncScores = ref.watch(scoreboardViewModelProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: asyncScores.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (scores) {
          if (scores.isEmpty) {
            return const Center(child: Text('No scores available.'));
          }

          return Column(
            children: [
              const HeaderRow(),
              Expanded(
                child: ListView.builder(
                  itemCount: scores.length,
                  itemBuilder: (context, index) {
                    final score = scores[index];
                    return ScoreboardListItem(score: score);
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ScoreboardListItem extends StatelessWidget {
  const ScoreboardListItem({required this.score, super.key});

  final Score score;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(flex: 2, child: Text(score.username)),
          Expanded(child: Text('${score.bestTime}', textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}

class HeaderRow extends StatelessWidget {
  const HeaderRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      color: Colors.grey[300],
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(flex: 2, child: Text('Username', style: TextStyle(fontWeight: FontWeight.bold))),
          Expanded(child: Text('Score', style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}
