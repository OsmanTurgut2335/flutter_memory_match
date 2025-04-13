import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mem_game/data/memorycard/model/memory_card.dart';

class CardNotifier extends StateNotifier<List<MemoryCard>> {
  CardNotifier() : super([]);
}
