import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';


class HomeMenu extends StatelessWidget {
  const HomeMenu({
    required this.hasOngoingGame,
    required this.onNewGame,
    required this.onContinueGame,
    required this.onScoreboard,
    required this.onShop,
    super.key,
  });

  final bool hasOngoingGame;
  final VoidCallback onNewGame;
  final VoidCallback onContinueGame;
  final VoidCallback onScoreboard;
  final VoidCallback onShop;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          style: _buttonStyle,
          onPressed: onNewGame,
          child: Text('home.new_game'.tr()),
        ),
        const SizedBox(height: 16),
        if (hasOngoingGame)
          ElevatedButton(
            style: _buttonStyle,
            onPressed: onContinueGame,
            child: Text('home.continue_game'.tr()),
          ),
        const SizedBox(height: 16),
        ElevatedButton(
          style: _buttonStyle,
          onPressed: onScoreboard,
          child: Text('home.scoreboard'.tr()),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          style: _buttonStyle,
          onPressed: onShop,
          child: Text('home.shop'.tr()),
        ),
      ],
    );
  }

  ButtonStyle get _buttonStyle => ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFFA726),
        foregroundColor: Colors.black87,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      );
}
