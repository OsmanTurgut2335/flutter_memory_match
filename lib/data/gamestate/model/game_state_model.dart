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
  });
  // The list of memory cards in the current game. Each card stores its state (face-up, matched, etc.)
  @HiveField(0)
  final List<MemoryCard> cards;

  // The number of moves made by the player so far
  @HiveField(1)
  final int moves;

  // The current game score
  @HiveField(2)
  final int score;

  // The current elapsed (or remaining) time in the game (in seconds)
  @HiveField(3)
  final int currentTime;

  // The player's remaining health (or lives)
  @HiveField(4)
  final int health;

  // copyWith allows you to create a modified copy of the game state while keeping immutability.
  GameState copyWith({
    List<MemoryCard>? cards,
    int? moves,
    int? score,
    int? currentTime,
    int? health,
  }) {
    return GameState(
      cards: cards ?? this.cards,
      moves: moves ?? this.moves,
      score: score ?? this.score,
      currentTime: currentTime ?? this.currentTime,
      health: health ?? this.health,
    );
  }
}
