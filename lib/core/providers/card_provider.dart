import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mem_game/data/memorycard/model/memory_card.dart';
import 'package:mem_game/features/memory_card/notifier/card_notifier.dart';


final cardNotifierProvider = StateNotifierProvider<CardNotifier, List<MemoryCard>>((ref) {
  return CardNotifier();
});
