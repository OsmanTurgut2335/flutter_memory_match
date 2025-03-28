// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_state_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GameStateAdapter extends TypeAdapter<GameState> {
  @override
  final int typeId = 2;

  @override
  GameState read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GameState(
      cards: (fields[0] as List).cast<MemoryCard>(),
      moves: fields[1] as int,
      score: fields[2] as int,
      currentTime: fields[3] as int,
      health: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, GameState obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.cards)
      ..writeByte(1)
      ..write(obj.moves)
      ..writeByte(2)
      ..write(obj.score)
      ..writeByte(3)
      ..write(obj.currentTime)
      ..writeByte(4)
      ..write(obj.health);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GameStateAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
