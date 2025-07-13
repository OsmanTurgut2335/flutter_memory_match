// lib/features/game/widgets/game_screen_app_bar.dart
import 'package:flutter/material.dart';

class GameScreenAppBar extends StatelessWidget implements PreferredSizeWidget {
  const GameScreenAppBar({
    required this.onPause,
    required this.onResume,
    required this.onMenuSelected,
    super.key,
  });

  final VoidCallback onPause;
  final VoidCallback onResume;
  final Future<void> Function(String choice) onMenuSelected;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: const Text('Memory Game'),
      actions: [
        IconButton(
          icon: const Icon(Icons.pause),
          tooltip: 'Pause',
          onPressed: onPause,
        ),
        IconButton(
          icon: const Icon(Icons.play_arrow),
          tooltip: 'Resume',
          onPressed: onResume,
        ),
        IconButton(
          icon: const Icon(Icons.more_vert),
          tooltip: 'Menu',
          onPressed: () => _showMenuSheet(context),
        ),
      ],
    );
  }

  void _showMenuSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.home),
                title: const Text('Home Screen'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  onMenuSelected('homescreen');
                },
              ),
              ListTile(
                leading: const Icon(Icons.exit_to_app),
                title: const Text('Exit Game'),
                onTap: () {
                  Navigator.of(ctx).pop();
                  onMenuSelected('exit');
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
