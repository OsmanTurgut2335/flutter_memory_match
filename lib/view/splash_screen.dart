import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive/hive.dart';
import 'package:lottie/lottie.dart';
import 'package:mem_game/core/init/hive_initializer.dart';
import 'package:mem_game/data/user/model/user_model.dart';
import 'package:mem_game/view/create_username_screen.dart';
import 'package:mem_game/view/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initApp();
  }

  Future<void> _initApp() async {
    try {
      await initializeHive();
      //await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
      await MobileAds.instance.initialize();

      final userBox = Hive.box<UserModel>('userBox');
      final hasUser = userBox.containsKey('currentUserKey');

      final nextScreen = hasUser ? const HomeScreen() : const UsernameInputScreen();

      // init tamam → ana ekrana geç
      if (mounted) {
        await Navigator.of(context).pushReplacement(MaterialPageRoute<void>(builder: (_) => nextScreen));
      }
    } catch (e, st) {
      log('Init error: $e', stackTrace: st);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4C5BD4), Color(0xFFD68C45)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset('assets/lottie/background_pattern.json', width: 150, height: 150),
              const SizedBox(height: 20),
              const Text(
                'Loading...',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
