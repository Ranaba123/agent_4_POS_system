// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'debtor.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DebtorAdapter extends TypeAdapter<Debtor> {
  @override
  final int typeId = 0;

  @override
  Debtor read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Debtor(
      id: fields[0] as String?,
      name: fields[1] as String,
      phone: fields[2] as String?,
      amount: fields[3] as double,
      dateAdded: fields[4] as DateTime,
      dueDate: fields[5] as DateTime?,
      notes: fields[6] as String?,
      isPaid: fields[7] as bool,
      settlements: (fields[8] as List?)?.cast<Settlement>(),
    );
  }

  @override
  void write(BinaryWriter writer, Debtor obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.phone)
      ..writeByte(3)
      ..write(obj.amount)
      ..writeByte(4)
      ..write(obj.dateAdded)
      ..writeByte(5)
      ..write(obj.dueDate)
      ..writeByte(6)
      ..write(obj.notes)
      ..writeByte(7)
      ..write(obj.isPaid)
      ..writeByte(8)
      ..write(obj.settlements);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DebtorAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
