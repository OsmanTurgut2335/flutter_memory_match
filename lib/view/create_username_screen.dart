import 'dart:async';
import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mem_game/core/providers/user_provider.dart';
import 'package:mem_game/view/home_screen.dart';

class UsernameInputScreen extends ConsumerStatefulWidget {
  const UsernameInputScreen({super.key});

  @override
  ConsumerState<UsernameInputScreen> createState() => _UsernameInputScreenState();
}

class _UsernameInputScreenState extends ConsumerState<UsernameInputScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  void _showSnackBar(BuildContext context, String message) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent, duration: const Duration(seconds: 3)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF4C5BD4), Color(0xFFD68C45)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        appBar: AppBar(title: Text('username.title'.tr())),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  controller: _usernameController,
                  decoration: InputDecoration(labelText: 'username.label'.tr()),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'username.validation'.tr();
                    if (value.length > 20) return 'username.tooLong'.tr();
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed:
                      _isLoading
                          ? null
                          : () async {
                            if (_formKey.currentState!.validate()) {
                              setState(() => _isLoading = true);

                              final username = _usernameController.text.trim();

                              try {
                                final response = await http
                                    .post(
                                      Uri.parse('http://10.0.2.2:8080/leaderboard/entry'),
                                      headers: {'Content-Type': 'application/json'},
                                      body: jsonEncode({'username': username, 'bestTime': 9999}),
                                    )
                                    .timeout(const Duration(seconds: 5));

                                if (response.statusCode == 200 || response.statusCode == 201) {
                                  await ref.read(userViewModelProvider.notifier).createUser(username);
                                  if (context.mounted) {
                                    await Navigator.of(
                                      context,
                                    ).pushReplacement(MaterialPageRoute<void>(builder: (_) => const HomeScreen()));
                                  }
                                } else if (response.statusCode == 409) {
                                  _showSnackBar(context, 'username.exists'.tr());
                                } else {
                                  _showSnackBar(context, 'username.unexpected'.tr());
                                }
                              } on TimeoutException {
                                _showSnackBar(context, 'username.timeout'.tr());
                              } catch (_) {
                                _showSnackBar(context, 'username.failed'.tr());
                              } finally {
                                if (mounted) setState(() => _isLoading = false);
                              }
                            }
                          },
                  child:
                      _isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                          : Text('username.save'.tr()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
