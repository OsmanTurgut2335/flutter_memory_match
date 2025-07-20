// lib/features/memory_card/widgets/memory_card_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mem_game/core/constants/colors/app_colors.dart';
import 'package:mem_game/core/providers/game_provider.dart';
import 'package:mem_game/data/memorycard/model/memory_card.dart';

import 'package:shimmer/shimmer.dart';
class MemoryCardWidget extends ConsumerWidget {
  const MemoryCardWidget({
    required this.card,
    required this.onTap,
    this.level = 1,
    super.key,
  });

  final MemoryCard card;
  final VoidCallback onTap;
  final int level;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isPreview = ref.watch(gameNotifierProvider)?.showingPreview ?? false;
    final showFront = isPreview || card.isFaceUp;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) {
          final rotate = Tween(begin: 0.0, end: 1).animate(animation);
          return AnimatedBuilder(
            animation: rotate,
            child: child,
            builder: (context, child) {
              final angle = rotate.value * 3.14;
              return Transform(
                transform: Matrix4.rotationY(angle),
                alignment: Alignment.center,
                child: child,
              );
            },
          );
        },
     
        child: showFront
            ? _buildCardFront(key: const ValueKey('front'))
            : _buildCardBack(key: const ValueKey('back')),
      ),
    );
  }

  Widget _buildCardFront({required Key key}) {
    return Container(
      key: key,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 2),
        boxShadow: const [
          BoxShadow(blurRadius: 4, color: Colors.black26, offset: Offset(2, 2))
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(card.content, fit: BoxFit.cover),
      ),
    );
  }

  Widget _buildCardBack({required Key key}) {
    return Shimmer.fromColors(
      baseColor: Colors.blue,
      highlightColor: Colors.lightBlueAccent,
      child: Container(
        key: key,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Colors.blue, Colors.lightBlueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: const [
            BoxShadow(blurRadius: 4, color: Colors.black26, offset: Offset(2, 2))
          ],
        ),
        child: const Center(
          child: Icon(Icons.help_outline, size: 40, color: Colors.white),
        ),
      ),
    );
  }
}
