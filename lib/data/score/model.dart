import 'package:json_annotation/json_annotation.dart';

part 'model.g.dart';

@JsonSerializable()
class Score {
  Score({
    required this.username,
    required this.bestTime,
    required this.score,
    required this.maxLevel,
     this.rank,
  });

  factory Score.fromJson(Map<String, dynamic> json) => _$ScoreFromJson(json);

  final String username;
  final int bestTime;
  final int score;
  final int maxLevel;
 final int? rank;

  Map<String, dynamic> toJson() => _$ScoreToJson(this);
}

extension ScoreCopy on Score {
  Score copyWith({
    String? username,
    int? bestTime,
    int? score,
    int? maxLevel,
    int? rank,
  }) {
    return Score(
      username: username ?? this.username,
      bestTime: bestTime ?? this.bestTime,
      score: score ?? this.score,
      maxLevel: maxLevel ?? this.maxLevel,
      rank: rank ?? this.rank,
    );
  }
}
