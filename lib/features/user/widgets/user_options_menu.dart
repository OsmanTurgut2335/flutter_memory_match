import 'package:flutter/material.dart';
import 'package:mem_game/features/game/viewmodel/game_notifier.dart';
import 'package:mem_game/features/user/viewmodel/user_notifier.dart';
import 'package:mem_game/view/create_username_screen.dart';


///ui for Home Screen app bar's actions list 

class UserActionsButton extends StatelessWidget {
  const UserActionsButton({required this.notifier, required this.gameNotifier, super.key});

  final UserViewModel notifier;
  final GameNotifier gameNotifier;

  @override
  Widget build(BuildContext context) {
    return IconButton(icon: const Icon(Icons.more_vert), onPressed: () => _showActionsSheet(context));
  }

  void _showActionsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder:
          (_) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: const Text('Delete User'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _confirmDelete(context);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('Update Username'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showUpdateDialog(context);
                  },
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete User'),
            content: const Text('Are you sure you want to delete your user and all progress?'),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await notifier.deleteUser();
      await gameNotifier.exitGame();
      if (context.mounted) {
        await Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const UsernameInputScreen()));
      }
    }
  }

  Future<void> _showUpdateDialog(BuildContext context) async {
    String newUsername = '';
    await showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Update Username'),
            content: TextField(
              decoration: const InputDecoration(labelText: 'New Username'),
              onChanged: (v) => newUsername = v,
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
              ElevatedButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Save')),
            ],
          ),
    );

    if (newUsername.trim().isNotEmpty) {
      await notifier.changeUsername(newUsername.trim());
    }
  }
}
