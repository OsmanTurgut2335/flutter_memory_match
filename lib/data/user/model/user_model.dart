import 'package:hive/hive.dart';
import 'package:mem_game/data/shop_item/model/shop_item.dart';

part 'user_model.g.dart';

@HiveType(typeId: 1)
class UserModel extends HiveObject {
  UserModel({
    required this.username,
    this.score = 0,
    this.health = 3,
    this.bestTime = -1,
    this.currentTime = 0,
    this.moves = 0,
    this.coins = 0,
    this.isDummy = false,
    this.accessToken,
    this.refreshToken,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      username: json['username'] as String,
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
    );
  }

  @HiveField(0)
  final String username;

  @HiveField(1)
  final int score;

  @HiveField(2)
  final int health;

  @HiveField(3)
  int bestTime;

  @HiveField(4)
  final int currentTime;

  @HiveField(5)
  final int moves;

  @HiveField(6, defaultValue: 0)
  int coins;

  @HiveField(7)
  HiveList<ShopItem> inventory = HiveList<ShopItem>(Hive.box<ShopItem>('shopItemsBox'));

  @HiveField(8, defaultValue: false)
  final bool isDummy;

  @HiveField(9)
  final String? accessToken;

  @HiveField(10)
  final String? refreshToken;

  Null get user => null;

  UserModel copyWith({
    String? username,
    int? score,
    int? health,
    int? bestTime,
    int? currentTime,
    int? moves,
    int? coins,
    bool? isDummy,
    String? accessToken,
    String? refreshToken,
  }) {
    return UserModel(
      username: username ?? this.username,
      score: score ?? this.score,
      health: health ?? this.health,
      bestTime: bestTime ?? this.bestTime,
      currentTime: currentTime ?? this.currentTime,
      moves: moves ?? this.moves,
      coins: coins ?? this.coins,
      isDummy: isDummy ?? this.isDummy,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
    );
  }

  Map<String, dynamic> toJson() => {'username': username, 'accessToken': accessToken, 'refreshToken': refreshToken};
}
