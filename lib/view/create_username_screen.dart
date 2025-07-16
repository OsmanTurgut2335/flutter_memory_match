import 'dart:convert';

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

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enter Username')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Center(
            child: Column(
              children: [
                TextFormField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                  validator: (value) => value == null || value.isEmpty ? 'Please enter a username' : null,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  child: const Text('Save'),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final username = _usernameController.text.trim();

                      await ref.read(userViewModelProvider.notifier).createUser(username);

                    
                      final response = await http.post(
                   Uri.parse('http://10.0.2.2:8080/leaderboard/entry'),
                        headers: {'Content-Type': 'application/json'},
                        body: jsonEncode({'username': username, 'bestTime': 9999}),
                      );

                      if (response.statusCode == 200 || response.statusCode == 201) {
                        await Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const HomeScreen()));
                      } else {
                        print('Kayıt başarısız: ${response.statusCode}');
                      }
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
