import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mem_game/core/providers/scoreboard_provider.dart'; // Adjust the import path if needed
import 'package:mem_game/data/score/model.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scoreboardNotifier = ref.read(scoreboardViewModelProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
      ),
      body: FutureBuilder<List<Score>>(
        future: scoreboardNotifier.fetchLeaderboard(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final scores = snapshot.data ?? [];
          if (scores.isEmpty) {
            return const Center(child: Text('No scores available.'));
          }

          return Column(
            children: [
              // Header row
              const HeaderRow(),
              // List of scores
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
  const ScoreboardListItem({
    required this.score, super.key,
  });

  final Score score;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(score.username),
          ),
          Expanded(
            child: Text(
              '${score.bestTime}',
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}

class HeaderRow extends StatelessWidget {
  const HeaderRow({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      color: Colors.grey[300],
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'Username',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              'Score',
              style: TextStyle(fontWeight: FontWeight.bold),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
