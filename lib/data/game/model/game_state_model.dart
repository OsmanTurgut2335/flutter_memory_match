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
    this.isPaused = false, // New field added
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

  @HiveField(5) // Added a new Hive field index
  final bool isPaused;

  /// Creates a modified copy of the game state while keeping immutability.
  GameState copyWith({
    List<MemoryCard>? cards,
    int? moves,
    int? score,
    int? currentTime,
    int? health,
    bool? isPaused, // Added for pause state management
  }) {
    return GameState(
      cards: cards ?? this.cards,
      moves: moves ?? this.moves,
      score: score ?? this.score,
      currentTime: currentTime ?? this.currentTime,
      health: health ?? this.health,
      isPaused: isPaused ?? this.isPaused,
    );
  }
}
