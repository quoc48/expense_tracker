// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'queued_receipt.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QueuedReceiptAdapter extends TypeAdapter<QueuedReceipt> {
  @override
  final int typeId = 0;

  @override
  QueuedReceipt read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QueuedReceipt(
      id: fields[0] as String,
      queuedAt: fields[1] as DateTime,
      items: (fields[2] as List).cast<QueuedItem>(),
      retryCount: fields[3] as int,
      lastRetryAt: fields[4] as DateTime?,
      errorMessage: fields[5] as String?,
      status: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, QueuedReceipt obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.queuedAt)
      ..writeByte(2)
      ..write(obj.items)
      ..writeByte(3)
      ..write(obj.retryCount)
      ..writeByte(4)
      ..write(obj.lastRetryAt)
      ..writeByte(5)
      ..write(obj.errorMessage)
      ..writeByte(6)
      ..write(obj.status);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QueuedReceiptAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
