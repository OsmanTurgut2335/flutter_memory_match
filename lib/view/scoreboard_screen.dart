import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mem_game/core/constants/textstyles/app_text_styles.dart';
import 'package:mem_game/core/providers/scoreboard_provider.dart';
import 'package:mem_game/core/providers/user_provider.dart';
import 'package:mem_game/core/widgets/common_screen_wrapper.dart';
import 'package:mem_game/core/widgets/lottie_background.dart';
import 'package:mem_game/data/score/model.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(scoreboardViewModelProvider);
    final notifier = ref.read(scoreboardViewModelProvider.notifier);

    return Scaffold(
      body: CommonScreenWrapper(
        title: 'leaderboard.title'.tr(),
        child: RefreshIndicator(
          onRefresh: notifier.refresh,
          child: asyncData.when(
            loading: () => const _LoadingView(),
            error: (err, stack) => const _ErrorView(),
            data: (data) {
              final top10 = data.top10;
              final userScore = data.userScore;
              final currentUsername = ref.read(userRepositoryProvider).getUser()?.username;

              final isInTop10 = userScore == null || top10.any((s) => s.username == currentUsername);

              return ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  const HeaderRow(),
                  for (final score in top10)
                    ScoreboardListItem(score: score, isCurrentUser: score.username == currentUsername),
                  if (!isInTop10) ...[const _DotsRow(), ScoreboardListItem(score: userScore, isCurrentUser: true)],
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class ScoreboardListItem extends StatelessWidget {
  const ScoreboardListItem({required this.score, required this.isCurrentUser, super.key});

  final Score score;
  final bool isCurrentUser;

  @override
  Widget build(BuildContext context) {
    final textStyle =
        isCurrentUser
            ? AppTextStyles.leaderboardScore.copyWith(fontWeight: FontWeight.bold)
            : AppTextStyles.leaderboardScore;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration:
          isCurrentUser
              ? BoxDecoration(color: Colors.yellow.withOpacity(0.2), borderRadius: BorderRadius.circular(8))
              : null,
      child: Row(
        children: [
          if (score.rank != null) Expanded(flex: 1, child: Text('${score.rank}', style: textStyle)) else Container(),

          Expanded(flex: 2, child: Text(score.username, style: textStyle)),
          Expanded(child: Text('${score.maxLevel}', style: textStyle)),
          Expanded(flex: 1, child: Text('${score.score}', textAlign: TextAlign.right, style: textStyle)),
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
      child: Row(
        children: [
          Expanded(child: Text('#', style: AppTextStyles.leaderboardHeader)),
          Expanded(flex: 3, child: Text('Username', style: AppTextStyles.leaderboardHeader)),
          Expanded(flex: 2, child: Text('Max Level', style: AppTextStyles.leaderboardHeader)),
          Expanded(flex: 2, child: Text('Score', style: AppTextStyles.leaderboardHeader, textAlign: TextAlign.right)),
        ],
      ),
    );
  }
}

class _DotsRow extends StatelessWidget {
  const _DotsRow();

  @override
  Widget build(BuildContext context) {
    return const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Center(child: Text('...')));
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [Text('leaderboard.loading'.tr(), style: AppTextStyles.whiteBold18)],
          ),
        ),
        const Positioned(bottom: 6, left: 0, right: 0, child: LottieBackground()),
      ],
    );
  }
}

class _ErrorView extends ConsumerWidget {
  const _ErrorView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(scoreboardViewModelProvider.notifier);
    return Stack(
      children: [
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [Text('leaderboard.error'.tr(), textAlign: TextAlign.center, style: AppTextStyles.whiteBold18)],
          ),
        ),
        Positioned(
          bottom: 24,
          left: 0,
          right: 0,
          child: IconButton(
            onPressed: notifier.refresh,
            icon: const Icon(Icons.refresh_outlined, size: 36),
            tooltip: 'leaderboard.retry_tooltip'.tr(),
          ),
        ),
      ],
    );
  }
}
