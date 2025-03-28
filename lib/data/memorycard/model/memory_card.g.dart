// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'memory_card.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MemoryCardAdapter extends TypeAdapter<MemoryCard> {
  @override
  final int typeId = 0;

  @override
  MemoryCard read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MemoryCard(
      id: fields[0] as int,
      content: fields[1] as String,
      isFaceUp: fields[2] as bool,
      isMatched: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, MemoryCard obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.content)
      ..writeByte(2)
      ..write(obj.isFaceUp)
      ..writeByte(3)
      ..write(obj.isMatched);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MemoryCardAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
