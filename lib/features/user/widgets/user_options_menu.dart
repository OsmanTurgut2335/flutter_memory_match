import 'package:flutter/material.dart';
import 'package:mem_game/features/user/viewmodel/user_notifier.dart';
import 'package:mem_game/view/create_username_screen.dart';


class UserPopUpMenu extends StatelessWidget {
  const UserPopUpMenu({
    super.key,
    required this.notifier,
  });

  final UserViewModel notifier;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (value) async {
        if (value == 'delete') {
          // Show a confirmation dialog for deletion.
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Delete User'),
              content: const Text(
                'Are you sure you want to delete your user and all progress?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Delete'),
                ),
              ],
            ),
          );
          if (confirmed == true) {
            // Perform deletion and navigate accordingly.
            await notifier.deleteUser();
            await Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => const UsernameInputScreen(),
              ),
            );
          }
        } else if (value == 'update') {
          // Show a dialog to update the username.
          String newUsername = '';
          await showDialog<void>(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: const Text('Update Username'),
                content: TextField(
                  decoration:
                      const InputDecoration(labelText: 'New Username'),
                  onChanged: (value) {
                    newUsername = value;
                  },
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Cancel'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Save'),
                  ),
                ],
              );
            },
          );
          if (newUsername.trim().isNotEmpty) {
            await notifier.changeUsername(newUsername.trim());
          }
        }
      },
      itemBuilder: (context) => <PopupMenuEntry<String>>[
        const PopupMenuItem<String>(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.arrow_back_outlined),
              SizedBox(width: 8),
              Text('Delete User'),
            ],
          ),
        ),
        const PopupMenuItem<String>(
          value: 'update',
          child: Row(
            children: [
              Icon(Icons.refresh_rounded),
              SizedBox(width: 8),
              Text('Update Username'),
            ],
          ),
        ),
      ],
    );
  }
}
