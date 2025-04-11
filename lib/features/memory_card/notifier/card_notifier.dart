import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mem_game/data/memorycard/model/memory_card.dart';

class CardNotifier extends StateNotifier<List<MemoryCard>> {
  CardNotifier() : super([]);

 /// Generates a shuffled list of MemoryCard objects for the given level.
  /// Level 1: uses assets/card_images/level1 → 6 images → 12 cards
  /// Level 2: uses assets/card_images/level2 → 8 images → 16 cards
  /// Level 3: uses assets/card_images/level3 → 12 images → 24 cards
  List<MemoryCard> generateCardsForLevel(int level, {bool preview = false}) {
    final levelImages = switch (level) {
      1 => List<String>.generate(6, (i) => 'assets/card_images/level1/card$i.png'),
      2 => List<String>.generate(8, (i) => 'assets/card_images/level2/card$i.png'),
      3 => List<String>.generate(12, (i) => 'assets/card_images/level3/card$i.png'),
      _ => List<String>.generate(6, (i) => 'assets/card_images/level1/card$i.png'),
    };

    final allPaths = [for (var path in levelImages) path, for (var path in levelImages) path]..shuffle();

    return List<MemoryCard>.generate(
      allPaths.length,
      (index) => MemoryCard(
        id: index,
        content: allPaths[index],
        isFaceUp: preview, // 👈 Show cards face up initially if preview is true
      ),
    );
  }
  
}
