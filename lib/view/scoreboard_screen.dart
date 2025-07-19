import 'package:easy_localization/easy_localization.dart';
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
        title: 'leaderboard.title'.tr(),

        child: RefreshIndicator(
          onRefresh: () async {
            await notifier.refresh();
          },
          child: asyncScores.when(
            loading:
                () => Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [Text('leaderboard.loading'.tr(), style: AppTextStyles.whiteBold18)],
                      ),
                    ),
                    const Positioned(bottom: 6, left: 0, right: 0, child: LottieBackground()),
                  ],
                ),

            error:
                (err, stack) => Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('leaderboard.error'.tr(), textAlign: TextAlign.center, style: AppTextStyles.whiteBold18),
                        ],
                      ),
                    ),
                    Positioned(
                      bottom: 24,
                      left: 0,
                      right: 0,
                      child: IconButton(
                        onPressed: notifier.refresh,
                        icon: const Icon(Icons.refresh_outlined, size: 36),
                        tooltip: 'leaderboard.retry_tooltip'.tr(), // Tooltip da çevrildi
                      ),
                    ),
                  ],
                ),

            data: (scores) {
              if (scores.isEmpty) {
                return ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 200),
                    Center(child: Text('leaderboard.no_scores'.tr(), style: AppTextStyles.whiteBold18)),
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
