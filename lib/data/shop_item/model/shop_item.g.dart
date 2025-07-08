// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shop_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ShopItemAdapter extends TypeAdapter<ShopItem> {
  @override
  final int typeId = 3;

  @override
  ShopItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ShopItem(
      userId: fields[0] as String,
      itemType: fields[1] as ShopItemType,
      quantity: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, ShopItem obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.userId)
      ..writeByte(1)
      ..write(obj.itemType)
      ..writeByte(2)
      ..write(obj.quantity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShopItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ShopItemTypeAdapter extends TypeAdapter<ShopItemType> {
  @override
  final int typeId = 4;

  @override
  ShopItemType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ShopItemType.healthPotion;
      case 1:
        return ShopItemType.extraFlip;
      case 2:
        return ShopItemType.doubleCoins;
      default:
        return ShopItemType.healthPotion;
    }
  }

  @override
  void write(BinaryWriter writer, ShopItemType obj) {
    switch (obj) {
      case ShopItemType.healthPotion:
        writer.writeByte(0);
        break;
      case ShopItemType.extraFlip:
        writer.writeByte(1);
        break;
      case ShopItemType.doubleCoins:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShopItemTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
