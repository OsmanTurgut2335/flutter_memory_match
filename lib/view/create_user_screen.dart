import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mem_game/features/user/provider/user_provider.dart';
import 'package:mem_game/core/widgets/auth_input_textfields.dart';

import 'package:mem_game/core/widgets/auth_textspan.dart';
import 'package:mem_game/core/widgets/confirmation_dialogs.dart';
import 'package:mem_game/core/widgets/lottie_background.dart';
import 'package:mem_game/view/home_screen.dart';
import 'package:mem_game/view/login_screen.dart';

class UsernameInputScreen extends ConsumerStatefulWidget {
  const UsernameInputScreen({super.key});

  @override
  ConsumerState<UsernameInputScreen> createState() => _UsernameInputScreenState();
}

class _UsernameInputScreenState extends ConsumerState<UsernameInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent, duration: const Duration(seconds: 3)),
    );
  }

  Future<void> _handleSave() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      final username = _usernameController.text.trim();
      final password = _passwordController.text.trim();

      await ref
          .read(userViewModelProvider.notifier)
          .handleUserCreation(
            context: context,
            username: username,
            password: password,
            onDummyFallback: () => _showDummyUserDialog(context, username),
            onUserExists: () => _showSnackBar(context, 'username.exists'.tr()),
            onUnexpected: () => _showSnackBar(context, 'username.unexpected'.tr()),
          );

      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _showDummyUserDialog(BuildContext context, String username) async {
    if (!context.mounted) return;

    final shouldContinue = await showConfirmationDialog(
      context: context,
      titleKey: 'username.offlineTitle',
      contentKey: 'username.offlineDesc',
      confirmKey: 'username.continue',
      cancelKey: 'username.cancel',
      barrierDismissible: false,
    );

    if (shouldContinue) {
      await ref
          .read(userViewModelProvider.notifier)
          .createUser('guest_${DateTime.now().millisecondsSinceEpoch}', isDummy: true);
      if (context.mounted) {
        await Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (_) => const HomeScreen()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color.fromARGB(255, 123, 134, 216), Color.fromARGB(255, 214, 158, 106)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: Center(child: Text('username.title'.tr())), backgroundColor: Colors.transparent),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Spacer(),
                AuthInputFields(
                  usernameController: _usernameController,
                  passwordController: _passwordController,
                  obscurePassword: _obscurePassword,
                  onObscureToggle: (value) => setState(() => _obscurePassword = value),
                  usernameValidator: (value) {
                    if (value == null || value.isEmpty) return 'username.validation'.tr();
                    if (value.length > 20) return 'username.tooLong'.tr();
                    return null;
                  },
                  passwordValidator: (value) {
                    if (value == null || value.isEmpty) return 'password.validation'.tr();
                    if (value.length < 6) return 'password.tooShort'.tr();
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                _buildSaveButton(),
                const SizedBox(height: 24),
                AuthTextLink(
                  normalText: 'sign.account'.tr(),
                  actionText: 'sign.login'.tr(),
                  onTap: () {
                    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
                  },
                ),
                const Spacer(),
                const LottieBackground(),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSaveButton() => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      onPressed: _isLoading ? null : _handleSave,
      child:
          _isLoading
              ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
              : Text('username.save'.tr()),
    ),
  );
}
