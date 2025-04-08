import 'package:flutter/material.dart';
import 'package:mem_game/data/memorycard/model/memory_card.dart';
import 'package:mem_game/features/memory_card/widgets/memory_card_factory.dart';
import 'package:shimmer/shimmer.dart';

class MemoryCardWidget extends StatelessWidget {
  const MemoryCardWidget({required this.card, required this.onTap, super.key});
  final MemoryCard card;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
              return Transform(transform: Matrix4.rotationY(angle), alignment: Alignment.center, child: child);
            },
          );
        },
        child: card.isFaceUp ? _buildCardFront() : _buildCardBack(),
      ),
    );
  }

  Widget _buildCardFront() {
    return Container(
      key: const ValueKey('front'),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 2),
        boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black26, offset: Offset(2, 2))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: buildMemoryCardFrontContent(card.id, card.content),
      ),
    );
  }

  Widget _buildCardBack() {
    return Shimmer.fromColors(
      baseColor: Colors.blue,
      highlightColor: Colors.lightBlueAccent,
      child: Container(
        key: const ValueKey('back'),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: const LinearGradient(
            colors: [Colors.blue, Colors.lightBlueAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black26, offset: Offset(2, 2))],
        ),
        child: const Center(child: Icon(Icons.help_outline, size: 40, color: Colors.white)),
      ),
    );
  }
}
