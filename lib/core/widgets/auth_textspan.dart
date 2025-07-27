import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class AuthTextLink extends StatelessWidget {

  const AuthTextLink({
    required this.normalText, required this.actionText, required this.onTap, super.key,
  });
  final String normalText;
  final String actionText;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text.rich(
        TextSpan(
          text: normalText,
          style: const TextStyle(color: Colors.white70),
          children: [ 
            TextSpan(
              text: actionText,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
              ),
              recognizer: TapGestureRecognizer()..onTap = onTap,
            ),
          ],
        ),
      ),
    );
  }
}
