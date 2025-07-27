import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mem_game/core/providers/user_provider.dart';
import 'package:mem_game/core/widgets/auth_input_textfields.dart';

import 'package:mem_game/core/widgets/lottie_background.dart';
import 'package:mem_game/view/create_username_screen.dart';
import 'package:mem_game/view/home_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    try {
      await ref.read(userViewModelProvider.notifier).loginUser(context, username, password);
      if (mounted) {
        await Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    } catch (e) {
      _showError('Login failed: ${e.toString()}');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF7B86D8), Color(0xFFD69E6A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Login'), backgroundColor: Colors.transparent),
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
                  obscurePassword: _obscureText,
                  onObscureToggle: (value) => setState(() => _obscureText = value),
                  usernameValidator: (value) => value == null || value.isEmpty ? 'Enter your username' : null,
                  passwordValidator:
                      (value) => value == null || value.length < 6 ? 'Enter at least 6 characters' : null,
                ),
                const SizedBox(height: 24),
                _buildLoginButton(),
                const SizedBox(height: 24),
                Text.rich(
                  TextSpan(
                    text: 'Hesabınız yok mu? ',
                    style: const TextStyle(color: Colors.white70),
                    children: [
                      TextSpan(
                        text: 'Kayıt olun',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                        recognizer:
                            TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.of(
                                  context,
                                ).pushReplacement(MaterialPageRoute(builder: (_) => const UsernameInputScreen()));
                              },
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                const LottieBackground(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() => SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: _isLoading ? null : _handleLogin,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.orange,
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Login'),
    ),
  );
}
