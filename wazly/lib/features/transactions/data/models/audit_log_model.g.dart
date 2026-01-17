// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_log_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AuditLogModelAdapter extends TypeAdapter<AuditLogModel> {
  @override
  final int typeId = 3;

  @override
  AuditLogModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AuditLogModel(
      id: fields[0] as String,
      transactionId: fields[1] as String,
      oldAmount: fields[2] as double,
      newAmount: fields[3] as double,
      reason: fields[4] as String,
      timestamp: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, AuditLogModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.transactionId)
      ..writeByte(2)
      ..write(obj.oldAmount)
      ..writeByte(3)
      ..write(obj.newAmount)
      ..writeByte(4)
      ..write(obj.reason)
      ..writeByte(5)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AuditLogModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
