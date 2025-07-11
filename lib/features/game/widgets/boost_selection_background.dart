import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class BoostSelectionBackground extends StatelessWidget {
  const BoostSelectionBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          /*  gradient: LinearGradient(
            colors: [Color(0xFF3F51B5), Color(0xFF2196F3)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),*/
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 300, width: 300, child: Lottie.asset('assets/lottie/background_pattern.json')),

              const SizedBox(height: 20),

              // Icon(Icons.auto_awesome, size: 64, color: Colors.white),
              const Text(
                'Preparing your game...',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w500),
              ),

              const SizedBox(height: 20),
              const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
