


import 'package:json_annotation/json_annotation.dart';

part 'model.g.dart';

@JsonSerializable()
class Score {

  factory Score.fromJson(Map<String, dynamic> json) => _$ScoreFromJson(json);

  Score({required this.username, required this.bestTime});
  final String username;
  final int bestTime;
  Map<String, dynamic> toJson() => _$ScoreToJson(this);
}
