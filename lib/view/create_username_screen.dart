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
  String _username = '';

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
              usernameTextField(),
              const SizedBox(height: 16),
              SaveUserButton(formKey: _formKey, ref: ref, username: _username),
            ],
          ),
        ),
      ),
    );
  }

  TextFormField usernameTextField() {
    return TextFormField(
      decoration: const InputDecoration(labelText: 'Username'),
      validator:
          (value) =>
              value == null || value.isEmpty ? 'Please enter a username' : null,
      onSaved: (value) => _username = value!,
    );
  }
}

class SaveUserButton extends StatelessWidget {
  const SaveUserButton({
    required GlobalKey<FormState> formKey,
    required this.ref,
    required String username,
    super.key,
  }) : _formKey = formKey,
       _username = username;

  final GlobalKey<FormState> _formKey;
  final WidgetRef ref;
  final String _username;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      child: const Text('Save'),
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          _formKey.currentState!.save();

          ref.read(userNotifierProvider.notifier).createUser(_username).then((
            _,
          ) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const HomeScreen()),
            );
          });
        }
      },
    );
  }
}
