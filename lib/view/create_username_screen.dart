import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mem_game/core/providers/user_provider.dart';


import 'package:mem_game/view/home_screen.dart';

class UsernameInputScreen extends ConsumerStatefulWidget {
  const UsernameInputScreen({super.key});

  @override
  ConsumerState<UsernameInputScreen> createState() =>
      _UsernameInputScreenState();
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
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(labelText: 'Username'),
                validator: (value) =>
                    value == null || value.isEmpty ? 'Please enter a username' : null,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                child: const Text('Save'),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    // Use the controller's text
                    final username = _usernameController.text.trim();
                    ref.read(userViewModelProvider.notifier).createUser(username).then(
                      (_) {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                        );
                      },
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}


