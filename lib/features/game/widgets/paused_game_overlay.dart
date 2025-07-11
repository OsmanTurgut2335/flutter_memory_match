  import 'package:flutter/material.dart';

/// GameScreen pause overlay with fade animation.
class PausedGameOverlay extends StatelessWidget {
  final Animation<double> opacity;
  final VoidCallback onResume;

  const PausedGameOverlay({
    super.key,
    required this.opacity,
    required this.onResume,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: FadeTransition(
        opacity: opacity,
        child: ColoredBox(
          color: Colors.black.withAlpha(180),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Game Paused', style: TextStyle(fontSize: 28, color: Colors.white)),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: onResume, child: const Text('Resume Game')),
            ],
          ),
        ),
      ),
    );
  }
}