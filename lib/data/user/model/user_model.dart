import 'package:hive/hive.dart';
import 'package:mem_game/data/shop_item/model/shop_item.dart';

part 'user_model.g.dart';

@HiveType(typeId: 1)
class UserModel extends HiveObject {
  UserModel({
    required this.username,
    this.score = 0,
    // Default health is set to 3 lives
    this.health = 3,
    this.bestTime = 0,
    this.currentTime = 0,
    this.moves = 0,
    this.coins=0,
  });

  // The player's username
  @HiveField(0)
  final String username;

  // The player's overall score
  @HiveField(1)
  final int score;

  // The number of lives the player has.
  // This value will decrease when a wrong move is made.
  @HiveField(2)
  final int health;

  // The best finish time in seconds (lower is better)
  @HiveField(3)
   int bestTime;

  // The current time (elapsed or remaining) in the game session.
  @HiveField(4)
  final int currentTime;

  // The number of moves made during the game
  @HiveField(5)
  final int moves;

  // The number of moves made during the game
  @HiveField(6, defaultValue: 0)
   int coins;
  
  /// Kullanıcının envanterindeki öğeler
  @HiveField(7)
  HiveList<ShopItem> inventory = HiveList<ShopItem>(Hive.box<ShopItem>('shopItemsBox'));

  get user => null;
  

  UserModel copyWith({
    String? username,
    int? score,
    int? health,
    int? bestTime,
    int? currentTime,
    int? moves,
    int? coins,
  }) {
    return UserModel(
      username: username ?? this.username,
      score: score ?? this.score,
      health: health ?? this.health,
      bestTime: bestTime ?? this.bestTime,
      currentTime: currentTime ?? this.currentTime,
      moves: moves ?? this.moves,
      coins: coins ?? this.coins,
    );
  }
}
