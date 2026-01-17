// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settlement.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettlementAdapter extends TypeAdapter<Settlement> {
  @override
  final int typeId = 1;

  @override
  Settlement read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Settlement(
      amount: fields[0] as double,
      date: fields[1] as DateTime,
      notes: fields[2] as String?,
      type: fields[3] as String? ?? 'payment',
    );
  }

  @override
  void write(BinaryWriter writer, Settlement obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.amount)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.notes)
      ..writeByte(3)
      ..write(obj.type);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettlementAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
