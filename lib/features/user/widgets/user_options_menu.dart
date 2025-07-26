import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:mem_game/core/providers/game_provider.dart';
import 'package:mem_game/core/providers/user_provider.dart';
import 'package:mem_game/core/widgets/confirmation_dialogs.dart';
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
                /// Delete current user option
                ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: Text('options.delete'.tr()),
                  onTap: () {
                    Navigator.of(context).pop();
                    _confirmDelete(context, notifier, gameNotifier);
                  },
                ),

                ///Force reset for emergencies
                ListTile(
                  leading: const Icon(Icons.restart_alt),
                  title: Text('options.reset'.tr()),
                  onTap: () {
                    Navigator.of(context).pop();
                    _confirmReset(context, ref);
                  },
                ),

                ///Change Username Option
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
  final confirmed = await showConfirmationDialog(
    context: context,
    titleKey: 'options.delete_title',
    contentKey: 'options.delete_message',
    confirmKey: 'options.delete_button',
    cancelKey: 'options.cancel_button',
  );

  if (confirmed) {
    await notifier.deleteUser(context);
    await gameNotifier.exitGame();
    if (context.mounted) {
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const UsernameInputScreen()),
      );
    }
  }
}

 Future<void> _confirmReset(BuildContext context, WidgetRef ref) async {
  final confirmed = await showConfirmationDialog(
    context: context,
    titleKey: 'options.reset_title',
    contentKey: 'options.reset_message',
    confirmKey: 'options.reset_button',
    cancelKey: 'options.cancel_button',
  );

  if (confirmed) {
    await _forceResetApp(context, ref);
  }
}


Future<void> _showUpdateDialog(BuildContext context, UserViewModel notifier) async {
  final newUsername = await showTextInputDialog(
    context: context,
    titleKey: 'options.update_title',
    hintKey: 'options.update_hint',
    confirmKey: 'options.update_save',
    cancelKey: 'options.cancel_button',
  );

  if (newUsername != null) {
    await notifier.changeUsername(context,newUsername);
  }
}


  Future<void> _forceResetApp(BuildContext context, WidgetRef ref) async {
    final user = ref.read(userRepositoryProvider).getUser();
    if (user != null && !user.isDummy) {
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
