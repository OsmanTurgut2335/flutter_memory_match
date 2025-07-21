import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:mem_game/core/providers/game_provider.dart';
import 'package:mem_game/core/providers/user_provider.dart';
import 'package:mem_game/data/game/model/game_state_model.dart';
import 'package:mem_game/data/shop_item/model/shop_item.dart';
import 'package:mem_game/data/user/model/user_model.dart';
import 'package:mem_game/features/game/viewmodel/game_notifier.dart';
import 'package:mem_game/features/user/viewmodel/user_notifier.dart';
import 'package:mem_game/view/create_username_screen.dart';

class UserActionsButton extends ConsumerWidget {
  const UserActionsButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userNotifier = ref.read(userViewModelProvider.notifier);
    final gameNotifier = ref.read(gameNotifierProvider.notifier);

    return IconButton(
      icon: const Icon(Icons.more_vert),
      onPressed: () => _showActionsSheet(context, ref, userNotifier, gameNotifier),
    );
  }

  void _showActionsSheet(BuildContext context, WidgetRef ref, UserViewModel notifier, GameNotifier gameNotifier) {
    showModalBottomSheet(
      context: context,
      builder:
          (_) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: Text('options.delete'.tr()),
                  onTap: () {
                    Navigator.of(context).pop();
                    _confirmDelete(context, notifier, gameNotifier);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.restart_alt),
                  title: Text('options.reset'.tr()),
                  onTap: () {
                    Navigator.of(context).pop();
                    _confirmReset(context, ref);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: Text('options.update'.tr()),
                  onTap: () {
                    Navigator.of(context).pop();
                    _showUpdateDialog(context, notifier);
                  },
                ),
              ],
            ),
          ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, UserViewModel notifier, GameNotifier gameNotifier) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('options.delete_title'.tr()),
            content: Text('options.delete_message'.tr()),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text('options.cancel_button'.tr())),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('options.delete_button'.tr()),
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

  Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('options.reset_title'.tr()),
            content: Text('options.reset_message'.tr()),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text('options.cancel_button'.tr())),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.of(context).pop(true),
                child: Text('options.reset_button'.tr()),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      await _forceResetApp(context, ref);
    }
  }

  Future<void> _showUpdateDialog(BuildContext context, UserViewModel notifier) async {
    String newUsername = '';
    await showDialog<void>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('options.update_title'.tr()),
            content: TextField(
              decoration: InputDecoration(labelText: 'options.update_hint'.tr()),
              onChanged: (v) => newUsername = v,
            ),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(), child: Text('options.cancel_button'.tr())),
              ElevatedButton(onPressed: () => Navigator.of(context).pop(), child: Text('options.update_save'.tr())),
            ],
          ),
    );

    if (newUsername.trim().isNotEmpty) {
      await notifier.changeUsername(newUsername.trim());
    }
  }

  Future<void> _forceResetApp(BuildContext context, WidgetRef ref) async {
    final user = ref.read(userRepositoryProvider).getUser();
    if (user != null) {
      await ref.read(userRepositoryProvider).deleteUserFromDb();
    }

    await Hive.box<UserModel>('userBox').clear();
    await Hive.box<ShopItem>('shopItemsBox').clear();
    await Hive.box<GameState>('gameBox').clear();
    await ref.read(gameNotifierProvider.notifier).exitGame();
    ref.invalidate(userViewModelProvider);

    if (context.mounted) {
      await Navigator.of(
        context,
      ).pushAndRemoveUntil(MaterialPageRoute<void>(builder: (_) => const UsernameInputScreen()), (_) => false);
    }
  }
}
