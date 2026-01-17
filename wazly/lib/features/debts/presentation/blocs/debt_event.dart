import 'package:equatable/equatable.dart';
import '../../../transactions/domain/entities/transaction_entity.dart';

abstract class DebtEvent extends Equatable {
  const DebtEvent();

  @override
  List<Object?> get props => [];
}

class AddDebt extends DebtEvent {
  final TransactionEntity transaction;

  const AddDebt(this.transaction);

  @override
  List<Object?> get props => [transaction];
}

class AddSettlement extends DebtEvent {
  final TransactionEntity transaction;

  const AddSettlement(this.transaction);

  @override
  List<Object?> get props => [transaction];
}
