import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class LottieBackground extends StatefulWidget {
  const LottieBackground({super.key});

  @override
  State<LottieBackground> createState() => _LottieBackgroundState();
}

class _LottieBackgroundState extends State<LottieBackground> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: SizedBox(
          width: 150,
          height: 150,
          child: Lottie.asset(
            'assets/lottie/background_pattern.json',
            controller: _controller,
            fit: BoxFit.contain,
            onLoaded: (composition) {
              _controller
                ..duration = composition.duration * 2
                ..repeat();
            },
          ),
        ),
      ),
    );
  }
}
