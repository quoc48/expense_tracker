// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'queued_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QueuedItemAdapter extends TypeAdapter<QueuedItem> {
  @override
  final int typeId = 1;

  @override
  QueuedItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QueuedItem(
      description: fields[0] as String,
      amount: fields[1] as double,
      categoryNameVi: fields[2] as String,
      typeNameVi: fields[3] as String,
      date: fields[4] as DateTime,
      note: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, QueuedItem obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.description)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.categoryNameVi)
      ..writeByte(3)
      ..write(obj.typeNameVi)
      ..writeByte(4)
      ..write(obj.date)
      ..writeByte(5)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QueuedItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
