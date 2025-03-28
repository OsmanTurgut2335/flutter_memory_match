import 'package:hive/hive.dart';

part 'memory_card.g.dart';

@HiveType(typeId: 0)
class MemoryCard extends HiveObject {
  MemoryCard({
    required this.id,
    required this.content,
    this.isFaceUp = false,
    this.isMatched = false,
  });
  @HiveField(0)
  final int id; // Cards identifier
  @HiveField(1)
  final String content;

  @HiveField(2)
  bool isFaceUp;

  @HiveField(3)
  bool isMatched;

  MemoryCard copyWith({bool? isFaceUp, bool? isMatched}) {
    return MemoryCard(
      id: id,
      content: content,
      isFaceUp: isFaceUp ?? this.isFaceUp,
      isMatched: isMatched ?? this.isMatched,
    );
  }
}
