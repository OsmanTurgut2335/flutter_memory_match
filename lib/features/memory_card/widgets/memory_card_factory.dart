//UNUSED FOR NOW
import 'package:flutter/material.dart';

/// Returns the widget for the front of a memory card.
/// It automatically pairs each image (so total cards = images.length * 2).
Widget buildMemoryCardFrontContent(int cardId, String fallbackContent, {int level = 1}) {
  // 1) Define the image lists for each level.
  const level1Images = [
    'assets/card_images/level1/card0.png',
    'assets/card_images/level1/card1.png',
    'assets/card_images/level1/card2.png',
    'assets/card_images/level1/card3.png',
    'assets/card_images/level1/card4.png',
    'assets/card_images/level1/card5.png',
  ];
  const level2Images = [
    'assets/card_images/level2/card0.png',
    'assets/card_images/level2/card1.png',
    'assets/card_images/level2/card2.png',
    'assets/card_images/level2/card3.png',
    'assets/card_images/level2/card4.png',
    'assets/card_images/level2/card5.png',
    'assets/card_images/level2/card6.png',
    // 'assets/card_images/level2/card7.png',
  ];
  const level3Images = [
    'assets/card_images/level3/card0.png',
    'assets/card_images/level3/card1.png',
    'assets/card_images/level3/card2.png',
    'assets/card_images/level3/card3.png',
    'assets/card_images/level3/card4.png',
    'assets/card_images/level3/card5.png',
    'assets/card_images/level3/card6.png',
    'assets/card_images/level3/card7.png',
    'assets/card_images/level3/card8.png',
    'assets/card_images/level3/card9.png',
    'assets/card_images/level3/card10.png',
    'assets/card_images/level3/card11.png',
  ];

  // 2) Pick the correct list based on level.
  final images = switch (level) {
    1 => level1Images,
    2 => level2Images,
    3 => level3Images,
    _ => level1Images,
  };

  final pairCount = images.length;
  final totalCards = pairCount * 2;

  // 3) If cardId is in range, map it to one of the images via modulo.
  if (cardId < totalCards) {
    final imageIndex = cardId % pairCount;
    return Image.asset(images[imageIndex], fit: BoxFit.cover);
  }

  // 4) Fallback if something is out of range.
  return Text(fallbackContent, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold));
}
