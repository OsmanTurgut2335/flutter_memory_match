import 'package:hive/hive.dart';
import 'package:mem_game/data/memorycard/model/memory_card.dart';

part 'game_state_model.g.dart';

@HiveType(typeId: 2)
class GameState extends HiveObject {
  GameState({
    required this.cards,
    this.moves = 0,
    this.score = 0,
    this.currentTime = 0,
    this.health = 3,
    this.isPaused = false,
    this.level = 1,
    this.showingPreview = false,
    this.flipCount = 1,
    this.doubleCoins = false,
  });

  @HiveField(0)
  final List<MemoryCard> cards;

  @HiveField(1)
  final int moves;

  @HiveField(2)
  final int score;

  @HiveField(3)
  final int currentTime;

  @HiveField(4)
  final int health;

  @HiveField(5)
  final bool isPaused;

  @HiveField(6)
  final int level;

  @HiveField(7)
  final bool showingPreview;

  @HiveField(9)
  final bool doubleCoins;

  @HiveField(8)
  final int flipCount;

  GameState copyWith({
    List<MemoryCard>? cards,
    int? moves,
    int? score,
    int? currentTime,
    int? health,
    bool? isPaused,
    int? level,
    bool? showingPreview,
    int? flipCount,
    bool? doubleCoins,
  }) {
    return GameState(
      cards: cards ?? this.cards,
      moves: moves ?? this.moves,
      score: score ?? this.score,
      currentTime: currentTime ?? this.currentTime,
      health: health ?? this.health,
      isPaused: isPaused ?? this.isPaused,
      level: level ?? this.level,
      showingPreview: showingPreview ?? this.showingPreview,
      flipCount: flipCount ?? this.flipCount,
      doubleCoins: doubleCoins ?? this.doubleCoins,
    );
  }
}
