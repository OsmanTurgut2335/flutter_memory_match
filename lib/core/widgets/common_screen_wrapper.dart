import 'package:flutter/material.dart';

class CommonScreenWrapper extends StatelessWidget {
  const CommonScreenWrapper({required this.child, super.key, this.title, this.actions});
  final Widget child;
  final String? title;
  final List<Widget>? actions;

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
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: title != null ? Text(title!) : null,
          actions: actions,
        ),
        body: SafeArea(child: Padding(padding: const EdgeInsets.all(16), child: child)),
      ),
    );
  }
}
