import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mem_game/core/providers/scoreboard_provider.dart';
import 'package:mem_game/core/widgets/lottie_background.dart';
import 'package:mem_game/data/score/model.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncScores = ref.watch(scoreboardViewModelProvider);
    final notifier = ref.read(scoreboardViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: RefreshIndicator(
        onRefresh: () async {
          await notifier.refresh();
        },
        child: asyncScores.when(
          loading: () => const Center(child: Text('Please Wait...', style: TextStyle(fontSize: 16))),
          error:
              (err, stack) => ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [
                  SizedBox(height: 200),
                  Center(
                    child: Text(
                      'The database could not be accessed.Please try again by scrolling or come back another time',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                  LottieBackground(),
                ],
              ),
          data: (scores) {
            if (scores.isEmpty) {
              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: const [SizedBox(height: 200), Center(child: Text('No scores available.'))],
              );
            }

            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: scores.length + 1, // +1 for the header
              itemBuilder: (context, index) {
                if (index == 0) return const HeaderRow();
                final score = scores[index - 1];
                return ScoreboardListItem(score: score);
              },
            );
          },
        ),
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
