// lib/features/game/widgets/game_screen_app_bar.dart
import 'package:flutter/material.dart';

class GameScreenAppBar extends StatelessWidget implements PreferredSizeWidget {

  const GameScreenAppBar({
    Key? key,
    required this.onPause,
    required this.onResume,
    required this.onMenuSelected,
  }) : super(key: key);
  final VoidCallback onPause;
  final VoidCallback onResume;
  final Future<void> Function(String value) onMenuSelected;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Memory Game'),
      actions: [
        IconButton(
          icon: const Icon(Icons.pause),
          onPressed: onPause,
        ),
        IconButton(
          icon: const Icon(Icons.play_arrow),
          onPressed: onResume,
        ),
        PopupMenuButton<String>(
          onSelected: onMenuSelected,
          itemBuilder: (context) => const [
            PopupMenuItem(
              value: 'homescreen',
              child: Text('Home Screen'),
            ),
            PopupMenuItem(
              value: 'exit',
              child: Text('Exit Game'),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
