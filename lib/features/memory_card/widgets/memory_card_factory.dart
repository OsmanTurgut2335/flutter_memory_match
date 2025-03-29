import 'package:flutter/material.dart';

/// A simple widget factory that returns a widget for the card front based on card id.
/// You can enhance this function to consider more properties if needed.
Widget buildMemoryCardFrontContent(int cardId, String fallbackContent) {
  final cardContentMap = <int, Widget>{
    0: Image.asset('assets/images/card0.png', fit: BoxFit.cover),
    1: Image.asset('assets/images/card1.png', fit: BoxFit.cover),
    2: Image.asset('assets/images/card2.png', fit: BoxFit.cover),
    3: Image.asset('assets/images/card3.png', fit: BoxFit.cover),
    // Matching pairs: you can repeat or map as needed.
    4: Image.asset('assets/images/card0.png', fit: BoxFit.cover),
    5: Image.asset('assets/images/card1.png', fit: BoxFit.cover),
    6: Image.asset('assets/images/card2.png', fit: BoxFit.cover),
    7: Image.asset('assets/images/card3.png', fit: BoxFit.cover),
  };

  // Return the mapped widget, or fallback to text if not found.
  return cardContentMap[cardId] ??
      Text(
        fallbackContent,
        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
      );
}
