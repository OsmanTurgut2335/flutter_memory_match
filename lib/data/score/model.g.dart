// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Score _$ScoreFromJson(Map<String, dynamic> json) => Score(
      username: json['username'] as String,
      bestTime: (json['bestTime'] as num).toInt(),
      score: (json['score'] as num).toInt(),
      maxLevel: (json['maxLevel'] as num).toInt(),
      rank: (json['rank'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ScoreToJson(Score instance) => <String, dynamic>{
      'username': instance.username,
      'bestTime': instance.bestTime,
      'score': instance.score,
      'maxLevel': instance.maxLevel,
      'rank': instance.rank,
    };
