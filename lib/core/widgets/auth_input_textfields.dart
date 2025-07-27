import 'package:flutter/material.dart';

class AuthInputFields extends StatelessWidget {
  const AuthInputFields({
    required this.usernameController,
    required this.passwordController,
    required this.obscurePassword,
    required this.onObscureToggle,
    required this.usernameValidator,
    required this.passwordValidator,
    super.key,
  });

  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool obscurePassword;
  final void Function(bool) onObscureToggle;
  final String? Function(String?)? usernameValidator;
  final String? Function(String?)? passwordValidator;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: usernameController,
          style: _AuthInputConstants.inputTextStyle,
          decoration: const InputDecoration(
            labelText: 'Username',
            labelStyle: _AuthInputConstants.labelStyle,
            enabledBorder: _AuthInputConstants.enabledBorder,
            focusedBorder: _AuthInputConstants.focusedBorder,
          ),
          validator: usernameValidator,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: passwordController,
          obscureText: obscurePassword,
          style: _AuthInputConstants.inputTextStyle,
          decoration: InputDecoration(
            labelText: 'Password',
            labelStyle: _AuthInputConstants.labelStyle,
            enabledBorder: _AuthInputConstants.enabledBorder,
            focusedBorder: _AuthInputConstants.focusedBorder,
            suffixIcon: IconButton(
              icon: Icon(
                obscurePassword ? Icons.visibility_off : Icons.visibility,
                color: _AuthInputConstants.iconColor,
              ),
              onPressed: () => onObscureToggle(!obscurePassword),
            ),
          ),
          validator: passwordValidator,
        ),
      ],
    );
  }
}

class _AuthInputConstants {
  const _AuthInputConstants._();

  static const Color textColor = Colors.white;
  static const Color borderColor = Colors.white70;
  static const Color iconColor = Colors.white70;

  static const TextStyle inputTextStyle = TextStyle(color: textColor);
  static const TextStyle labelStyle = TextStyle(color: textColor);

  static const InputBorder enabledBorder = UnderlineInputBorder(borderSide: BorderSide(color: borderColor));

  static const InputBorder focusedBorder = UnderlineInputBorder(borderSide: BorderSide(color: textColor));
}
