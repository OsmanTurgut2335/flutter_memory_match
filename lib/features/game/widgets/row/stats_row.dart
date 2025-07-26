import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:mem_game/data/game/model/game_state_model.dart';
import 'package:mem_game/features/game/widgets/score_bubble.dart';
import 'package:mem_game/features/game/widgets/stat_bubble.dart';

/// GameScreen Animated stats row
class StatsRow extends StatelessWidget {
  const StatsRow({required this.gameState, required this.scoreBubbleKey, super.key});

  final GameState gameState;
  final GlobalKey<ScoreBubbleState> scoreBubbleKey;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        StatBubble(label: 'stats.moves'.tr(), value: gameState.moves.toString()),
        ScoreBubble(key: scoreBubbleKey, label: 'stats.score'.tr(), value: gameState.score.toString()),
        StatBubble(label: 'stats.time'.tr(), value: gameState.currentTime.toString()),
        StatBubble(label: 'stats.health'.tr(), value: gameState.health.toString()),
      ],
    );
  }
}
