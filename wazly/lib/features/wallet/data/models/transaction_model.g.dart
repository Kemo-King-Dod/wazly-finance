// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transaction_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TransactionModelAdapter extends TypeAdapter<TransactionModel> {
  @override
  final int typeId = 0;

  @override
  TransactionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TransactionModel(
      id: fields[0] as String,
      amount: fields[1] as double,
      category: fields[2] as String,
      date: fields[3] as DateTime,
      description: fields[4] as String,
      isIncome: fields[5] as bool,
      isDebt: fields[6] as bool,
      accountId: fields[7] as String,
      linkedAccountId: fields[8] as String?,
      debtStatus: fields[9] as DebtStatus?,
      lastModifiedReason: fields[10] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, TransactionModel obj) {
    writer
      ..writeByte(14)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.amount)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.description)
      ..writeByte(5)
      ..write(obj.isIncome)
      ..writeByte(6)
      ..write(obj.isDebt)
      ..writeByte(7)
      ..write(obj.accountId)
      ..writeByte(8)
      ..write(obj.linkedAccountId)
      ..writeByte(9)
      ..write(obj.debtStatus)
      ..writeByte(10)
      ..write(obj.lastModifiedReason)
      ..writeByte(11)
      ..write(obj.dueDate)
      ..writeByte(12)
      ..write(obj.hasNotification)
      ..writeByte(13)
      ..write(obj.isSettled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
