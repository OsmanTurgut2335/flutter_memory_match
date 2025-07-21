// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 1;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserModel(
      username: fields[0] as String,
      score: fields[1] as int,
      health: fields[2] as int,
      bestTime: fields[3] as int,
      currentTime: fields[4] as int,
      moves: fields[5] as int,
      coins: fields[6] == null ? 0 : fields[6] as int,
      isDummy: fields[8] == null ? false : fields[8] as bool,
    )..inventory = (fields[7] as HiveList).castHiveList();
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.username)
      ..writeByte(1)
      ..write(obj.score)
      ..writeByte(2)
      ..write(obj.health)
      ..writeByte(3)
      ..write(obj.bestTime)
      ..writeByte(4)
      ..write(obj.currentTime)
      ..writeByte(5)
      ..write(obj.moves)
      ..writeByte(6)
      ..write(obj.coins)
      ..writeByte(7)
      ..write(obj.inventory)
      ..writeByte(8)
      ..write(obj.isDummy);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
