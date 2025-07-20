import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:mem_game/core/init/hive_initializer.dart';
import 'package:mem_game/core/themes/themes.dart';
import 'package:mem_game/data/user/model/user_model.dart';
import 'package:mem_game/firebase_options.dart';
import 'package:mem_game/view/create_username_screen.dart';
import 'package:mem_game/view/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EasyLocalization.ensureInitialized();
  await initializeHive();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await MobileAds.instance.initialize();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('tr')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const ProviderScope(child: MyApp()),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final userBox = Hive.box<UserModel>('userBox');
    final hasUser = userBox.containsKey('currentUser');

    return MaterialApp(
      title: 'Memory Game',
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      home: hasUser ? const HomeScreen() : const UsernameInputScreen(),
    );
  }
}