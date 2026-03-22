// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'card_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CardModelAdapter extends TypeAdapter<CardModel> {
  @override
  final int typeId = 0;

  @override
  CardModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CardModel(
      id: fields[0] as int,
      name: fields[1] as String,
      annualFee: fields[2] as double,
      waiverThreshold: fields[3] as double,
      cycleStart: fields[4] as DateTime,
      cycleEnd: fields[5] as DateTime,
      userId: fields[6] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CardModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.annualFee)
      ..writeByte(3)
      ..write(obj.waiverThreshold)
      ..writeByte(4)
      ..write(obj.cycleStart)
      ..writeByte(5)
      ..write(obj.cycleEnd)
      ..writeByte(6)
      ..write(obj.userId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CardModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
