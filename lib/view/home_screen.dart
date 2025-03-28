import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Example main screen showing game options
    return Scaffold(
      appBar: AppBar(title: Text('Memory Game')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome to Memory Game'),
            ElevatedButton(
              child: Text('New Game'),
              onPressed: () {
                // Start a new game (reset game state, etc.)
              },
            ),
            ElevatedButton(
              child: Text('Continue Game'),
              onPressed: () {
                // Continue saved game
              },
            ),
            ElevatedButton(
              child: Text('Scoreboard'),
              onPressed: () {
                // Navigate to global scoreboard screen
              },
            ),
          ],
        ),
      ),
    );
  }
}
