import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mem_game/core/constants/textstyles/app_text_styles.dart';
import 'package:mem_game/core/providers/scoreboard_provider.dart';
import 'package:mem_game/core/widgets/common_screen_wrapper.dart';
import 'package:mem_game/core/widgets/lottie_background.dart';

import 'package:mem_game/data/score/model.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncScores = ref.watch(scoreboardViewModelProvider);
    final notifier = ref.read(scoreboardViewModelProvider.notifier);

    return Scaffold(
      body: CommonScreenWrapper(
        title: 'Leaderboard',
        child: RefreshIndicator(
          onRefresh: () async {
            await notifier.refresh();
          },
          child: asyncScores.when(
            loading: () => Center(child: Text('Please Wait...', style: AppTextStyles.whiteBold18)),
            error:
                (err, stack) => ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 200),
                    Center(
                      child: Text(
                        'The database could not be accessed.\nPlease try again by scrolling or come back another time.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.whiteBold18,
                      ),
                    ),
                    const LottieBackground(),
                  ],
                ),
            data: (scores) {
              if (scores.isEmpty) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 200),
                    Center(child: Text('No scores available.', style: AppTextStyles.whiteBold18)),
                  ],
                );
              }

              return ListView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                itemCount: scores.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) return const HeaderRow();
                  final score = scores[index - 1];
                  return ScoreboardListItem(score: score);
                },
              );
            },
          ),
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
          Expanded(flex: 2, child: Text(score.username, style: AppTextStyles.leaderboardScore)),
          Expanded(child: Text('${score.bestTime}', textAlign: TextAlign.right, style: AppTextStyles.leaderboardScore)),
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
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(flex: 2, child: Text('Username', style: AppTextStyles.leaderboardHeader)),
          Expanded(child: Text('Score', style: AppTextStyles.leaderboardHeader, textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}
